import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/services/version_service.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

const String kGitLabReleasesUrl =
    'https://gitlab.com/ForTheCommunity/torrentsdigger/-/releases';
const String kGitLabChangelogUrl =
    'https://gitlab.com/ForTheCommunity/torrentsdigger/-/raw/main/CHANGELOG.md?ref_type=heads';
const String kGitHubChangelogUrl =
    'https://raw.githubusercontent.com/ForTheCommunity/TorrentsDigger/refs/heads/main/CHANGELOG.md';
const String kFlathubUrl =
    'https://flathub.org/apps/io.gitlab.ForTheCommunity.torrentsdigger';
const String kFDroidUrl =
    'https://f-droid.org/packages/org.forthecommunity.torrentsdigger';
const String kGitHubReleasesUrl =
    'https://github.com/ForTheCommunity/TorrentsDigger/releases';

enum InstallSourceGuess {
  flatpak,
  appImage,
  fDroidOrApk,
  windows,
  linuxGeneral,
  other,
}

InstallSourceGuess detectInstallSource() {
  if (Platform.isLinux) {
    if (Platform.environment.containsKey('FLATPAK_ID') ||
        Platform.environment.containsKey('FLATPAK_SANDBOX_DIR')) {
      return InstallSourceGuess.flatpak;
    }
    if (Platform.environment.containsKey('APPIMAGE')) {
      return InstallSourceGuess.appImage;
    }
    return InstallSourceGuess.linuxGeneral;
  }
  if (Platform.isAndroid) {
    return InstallSourceGuess.fDroidOrApk;
  }
  if (Platform.isWindows) {
    return InstallSourceGuess.windows;
  }
  return InstallSourceGuess.other;
}

class ChangelogEntry {
  final String version;
  final String? date;
  final List<String> bulletPoints;

  const ChangelogEntry({
    required this.version,
    this.date,
    required this.bulletPoints,
  });
}

Future<String> fetchChangelogContent() async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 8);
  try {
    try {
      return await _fetchUrl(client, Uri.parse(kGitLabChangelogUrl));
    } catch (_) {
      // Fallback to GitHub raw URL
      return await _fetchUrl(client, Uri.parse(kGitHubChangelogUrl));
    }
  } finally {
    client.close();
  }
}

Future<String> _fetchUrl(HttpClient client, Uri uri) async {
  final userAgent = await getAppUserAgent();
  final request = await client.getUrl(uri);
  request.followRedirects = true;
  request.maxRedirects = 5;
  request.headers.set(
    HttpHeaders.userAgentHeader,
    userAgent,
  );
  final response = await request.close().timeout(const Duration(seconds: 8));
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return await response.transform(utf8.decoder).join();
  }
  throw HttpException('HTTP status ${response.statusCode}');
}

String _cleanVersion(String v) {
  final match = RegExp(r'(\d+(?:\.\d+)+)').firstMatch(v);
  return match != null ? match.group(1)! : v.trim();
}

List<ChangelogEntry> parseChangelog(
  String markdown, {
  String? currentVersion,
}) {
  final pattern = RegExp(
    r'^##\s*\[?([0-9a-zA-Z\.\-]+)\]?(?:\s*-\s*([0-9\-]+))?',
    multiLine: true,
  );
  final matches = pattern.allMatches(markdown).toList();
  if (matches.isEmpty) return [];

  final String? installedClean =
      currentVersion != null ? _cleanVersion(currentVersion) : null;

  final List<ChangelogEntry> entries = [];

  for (int i = 0; i < matches.length; i++) {
    final match = matches[i];
    final version = match.group(1) ?? '';
    final date = match.group(2);
    final versionClean = _cleanVersion(version);

    if (installedClean != null && versionClean == installedClean) {
      if (entries.isNotEmpty) {
        break;
      }
    }

    final int start = match.end;
    final int end =
        (i + 1 < matches.length) ? matches[i + 1].start : markdown.length;
    final rawSection = markdown.substring(start, end).trim();

    final List<String> bulletPoints = [];
    for (final line in rawSection.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('```')) continue;

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        bulletPoints.add(trimmed.substring(2).trim());
      } else if (trimmed.startsWith('### ')) {
        bulletPoints.add('__${trimmed.substring(4).trim()}__');
      } else if (!trimmed.startsWith('#')) {
        bulletPoints.add(trimmed);
      }
    }

    if (bulletPoints.isNotEmpty) {
      entries.add(
        ChangelogEntry(
          version: version,
          date: date,
          bulletPoints: bulletPoints,
        ),
      );
    }

    if (installedClean != null &&
        versionClean == installedClean &&
        entries.isNotEmpty) {
      break;
    }

    if (entries.length >= 3) break;
  }

  return entries;
}

Future<void> showUpdateDialog(
  BuildContext context, {
  String? currentVersion,
}) async {
  final version = currentVersion ?? await getAppCurrentVersion();
  if (!context.mounted) return;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return UpdateAvailableDialog(currentVersion: version);
    },
  );
}

class UpdateAvailableDialog extends StatefulWidget {
  final String? currentVersion;

  const UpdateAvailableDialog({super.key, this.currentVersion});

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  int _selectedTabIndex = 0; // 0 = What's New, 1 = Where to Update
  bool _isLoading = true;
  String? _errorMessage;
  List<ChangelogEntry> _entries = [];
  late final InstallSourceGuess _detectedSource;
  final ScrollController _changelogScrollController = ScrollController();
  final ScrollController _guideScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _detectedSource = detectInstallSource();
    _loadChangelog();
  }

  @override
  void dispose() {
    _changelogScrollController.dispose();
    _guideScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChangelog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final markdown = await fetchChangelogContent();
      final parsed = parseChangelog(
        markdown,
        currentVersion: widget.currentVersion,
      );
      if (mounted) {
        setState(() {
          _entries = parsed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String get _detectedSourceLabel {
    if (Platform.isAndroid) {
      return 'Android (F-Droid)';
    }
    if (Platform.isWindows) {
      return 'Windows';
    }
    if (Platform.isMacOS) {
      return 'macOS';
    }
    if (Platform.isIOS) {
      return 'iOS';
    }
    switch (_detectedSource) {
      case InstallSourceGuess.flatpak:
        return 'Linux (Flatpak)';
      case InstallSourceGuess.appImage:
        return 'Linux (AppImage)';
      default:
        return 'Linux';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accentColor = colors.aboutDialogIconColor;
    final latestVersion = _entries.isNotEmpty ? _entries.first.version : null;

    return AlertDialog(
      backgroundColor: colors.aboutDialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rocket Icon Container
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 26,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              'Update Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.cardPrimaryTextColor,
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Version Chips Row
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                if (widget.currentVersion != null &&
                    widget.currentVersion!.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cardColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.cardSecondaryTextColor.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Installed: ${widget.currentVersion}',
                      style: TextStyle(
                        color: colors.cardSecondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (latestVersion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.new_releases_rounded,
                          size: 11.5,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Latest: v$latestVersion',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.cardSecondaryTextColor.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: Text(
                    'Platform: $_detectedSourceLabel',
                    style: TextStyle(
                      color: colors.cardSecondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Selector: [ What's New ] | [ How to Update ]
            Container(
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      index: 0,
                      icon: Icons.auto_awesome_rounded,
                      label: "What's New",
                      colors: colors,
                      accentColor: accentColor,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      index: 1,
                      icon: Icons.downloading_rounded,
                      label: "Where to Update",
                      colors: colors,
                      accentColor: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tab Content Box
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
                ),
              ),
              child: _selectedTabIndex == 0
                  ? _buildChangelogContent(colors, accentColor)
                  : _buildWhereToUpdateContent(colors, accentColor),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: colors.cardSecondaryTextColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
              ),
              child: const Text('Later'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.proxySaveButtonBackgroundColor,
                foregroundColor: colors.proxySaveButtonTextColor,
                side: BorderSide(
                  color: colors.proxySaveButtonBorderColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
              ),
              icon: Icon(
                _selectedTabIndex == 0
                    ? Icons.downloading_rounded
                    : Icons.auto_awesome_rounded,
                size: 15,
              ),
              label: Text(
                _selectedTabIndex == 0 ? 'Where to update' : "What's New",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedTabIndex = _selectedTabIndex == 0 ? 1 : 0;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required dynamic colors,
    required Color accentColor,
  }) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: accentColor.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? accentColor : colors.cardSecondaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colors.cardPrimaryTextColor
                    : colors.cardSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangelogContent(dynamic colors, Color accentColor) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressBarWidget(),
            ),
            const SizedBox(height: 10),
            Text(
              "Fetching what's new...",
              style: TextStyle(
                color: colors.cardSecondaryTextColor,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'A new release of Torrents Digger is available with updated sources, performance improvements, and bug fixes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.cardSecondaryTextColor,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: accentColor,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Retry changelog', style: TextStyle(fontSize: 12)),
                onPressed: _loadChangelog,
              ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _changelogScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _changelogScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in _entries) ...[
              if (_entries.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'v${entry.version}${entry.date != null ? " (${entry.date})" : ""}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              for (final point in entry.bulletPoints) ...[
                if (point.startsWith('__') && point.endsWith('__'))
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: Text(
                      point.replaceAll('__', '').toUpperCase(),
                      style: TextStyle(
                        color: colors.cardSecondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              color: colors.cardPrimaryTextColor,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
            const SizedBox(height: 12),
            // Quick switcher banner to update guide
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getBannerHelpText(),
                        style: TextStyle(
                          color: colors.cardPrimaryTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBannerHelpText() {
    if (Platform.isAndroid) {
      return 'Update via F-Droid or download the latest APK from GitLab.';
    }
    if (Platform.isLinux) {
      return 'Update via Flathub, AppMan, or download AppImage/.flatpak/.tar from GitLab.';
    }
    if (Platform.isWindows) {
      return 'Download the latest .exe installer from GitLab releases.';
    }
    return 'Tap here to see update instructions for your platform.';
  }

  String _getWhereToUpdateHeaderText() {
    if (Platform.isAndroid) {
      return 'Update via F-Droid or direct APK download:';
    }
    if (Platform.isLinux) {
      return 'Update from Flathub or GitLab releases:';
    }
    if (Platform.isWindows) {
      return 'Download latest .exe from GitLab releases:';
    }
    return 'Choose your installation source below to update:';
  }

  Widget _buildWhereToUpdateContent(dynamic colors, Color accentColor) {
    return Scrollbar(
      controller: _guideScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _guideScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getWhereToUpdateHeaderText(),
              style: TextStyle(
                color: colors.cardSecondaryTextColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),

            if (Platform.isAndroid) ...[
              // 1. F-Droid
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.android_rounded,
                title: 'F-Droid',
                isDetected: true,
                description:
                    'Torrents Digger is distributed on Android via F-Droid. Update directly within the F-Droid client app.\n\nNote: Upstream release tags usually take 1–3 days to be built and signed by F-Droid servers.',
                linkActionText: 'Open F-Droid Package',
                linkUrl: kFDroidUrl,
              ),

              // 2. Direct APK download from GitLab releases
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.install_mobile_rounded,
                title: 'Direct APK (GitLab Releases)',
                isDetected: false,
                description:
                    'Download the latest standalone .apk file directly from the GitLab releases page for immediate installation without waiting for store sync.',
                linkActionText: 'Download APK from GitLab',
                linkUrl: kGitLabReleasesUrl,
              ),
            ] else if (Platform.isLinux) ...[
              // 1. Flathub (Flatpak)
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.inventory_2_outlined,
                title: 'Flathub (Flatpak)',
                isDetected: _detectedSource == InstallSourceGuess.flatpak,
                description:
                    'If you installed Torrents Digger from Flathub, update it using your desktop Software Center or run this terminal command:',
                command:
                    'flatpak update io.gitlab.ForTheCommunity.torrentsdigger',
                linkActionText: 'Open Flathub Page',
                linkUrl: kFlathubUrl,
              ),

              // 2. AppMan / AM (Linux Package Manager)
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.terminal_rounded,
                title: 'AppMan / AM (Linux Package Manager)',
                isDetected: false,
                description:
                    'If you installed Torrents Digger using AppMan or AM, run this command to update:',
                command: 'appman update torrents_digger',
              ),

              // 3. AppImage, .flatpak file, or Linux bundle (.tar) from GitLab releases
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.cloud_download_outlined,
                title: 'GitLab Releases (AppImage / .flatpak / .tar)',
                isDetected: _detectedSource == InstallSourceGuess.appImage,
                description:
                    'Download standalone AppImage, offline .flatpak file, or Linux bundle (.tar) directly from the GitLab releases page.',
                linkActionText: 'Download from GitLab Releases',
                linkUrl: kGitLabReleasesUrl,
              ),
            ] else if (Platform.isWindows) ...[
              // Windows: download latest .exe from GitLab releases page
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.window_rounded,
                title: 'GitLab Releases (.exe)',
                isDetected: true,
                description:
                    'Download the latest .exe installer / executable directly from the GitLab releases page.',
                linkActionText: 'Download .exe from GitLab',
                linkUrl: kGitLabReleasesUrl,
              ),
            ] else ...[
              // macOS / Other platforms
              _buildSourceCard(
                colors: colors,
                accentColor: accentColor,
                icon: Icons.cloud_download_outlined,
                title: 'GitLab Releases',
                isDetected: true,
                description:
                    'Download the latest release package directly from official GitLab releases.',
                linkActionText: 'Open GitLab Releases',
                linkUrl: kGitLabReleasesUrl,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required dynamic colors,
    required Color accentColor,
    required IconData icon,
    required String title,
    required bool isDetected,
    required String description,
    String? command,
    String? linkActionText,
    String? linkUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.aboutDialogBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDetected
              ? accentColor.withValues(alpha: 0.6)
              : colors.cardSecondaryTextColor.withValues(alpha: 0.15),
          width: isDetected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.cardPrimaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isDetected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Detected',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: colors.cardSecondaryTextColor,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (command != null) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      command,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: colors.cardPrimaryTextColor,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: command));
                      createSnackBar(
                        message: 'Command copied to clipboard',
                        duration: 2,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13.5,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (linkActionText != null && linkUrl != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => openUrl(
                  urlType: UrlType.normalLink,
                  url: linkUrl,
                  forceExternal: true,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        linkActionText,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 11.5,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
