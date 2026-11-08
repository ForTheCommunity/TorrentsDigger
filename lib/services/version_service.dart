import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:torrents_digger/database/get_settings_data.dart';

const String kAppFallbackVersion = 'v1.3.0+30';
const String kGitLabTagsApiUrl =
    'https://gitlab.com/api/v4/projects/73090806/repository/tags';
const String kGitHubTagsApiUrl =
    'https://api.github.com/repos/ForTheCommunity/TorrentsDigger/tags';

/// Returns the currently installed application version string, e.g. "v1.3.0+30".
/// It first attempts to load Flutter's built-in `version.json` asset (generated from pubspec.yaml).
/// If unavailable, it falls back to [kAppFallbackVersion].
Future<String> getAppCurrentVersion() async {
  try {
    final jsonStr = await rootBundle.loadString('version.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    final version = data['version'];
    final build = data['build_number'];
    if (version != null && version.toString().isNotEmpty) {
      if (build != null && build.toString().isNotEmpty) {
        return 'v$version+$build';
      }
      return 'v$version';
    }
  } catch (_) {}
  return kAppFallbackVersion;
}

class AppVersionNumber implements Comparable<AppVersionNumber> {
  final int major;
  final int minor;
  final int patch;
  final int build;
  final String raw;

  const AppVersionNumber({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
    required this.raw,
  });

  static AppVersionNumber? tryParse(String str) {
    final regex = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');
    final match = regex.firstMatch(str.trim());
    if (match == null) return null;
    return AppVersionNumber(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      build: match.group(4) != null ? int.parse(match.group(4)!) : 0,
      raw: str.trim(),
    );
  }

  @override
  int compareTo(AppVersionNumber other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return build.compareTo(other.build);
  }

  bool isNewerThan(AppVersionNumber current) => compareTo(current) > 0;
}

/// Checks whether an application update is available by querying upstream repository tags.
///
/// Returns:
/// - `0`: A newer version is available.
/// - `1`: Currently running the latest (or newer) version.
///
/// Throws an exception on network failure.
Future<int> checkNewUpdate() async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 8);

  try {
    String? responseBody;
    try {
      responseBody = await _fetchString(client, Uri.parse(kGitLabTagsApiUrl));
    } catch (_) {
      // Fallback to GitHub mirror tags API
      try {
        responseBody = await _fetchString(client, Uri.parse(kGitHubTagsApiUrl));
      } catch (_) {
        rethrow;
      }
    }

    final dynamic decoded = jsonDecode(responseBody);
    if (decoded is! List) {
      throw const FormatException('Expected JSON array of tags');
    }

    final tagRegex = RegExp(r'^v?\d+\.\d+\.\d+\+\d+$');

    String? latestValidTagName;
    for (final item in decoded) {
      if (item is Map && item['name'] is String) {
        final name = item['name'] as String;
        if (tagRegex.hasMatch(name.trim())) {
          latestValidTagName = name.trim();
          break;
        }
      }
    }

    if (latestValidTagName == null) {
      throw Exception('No valid version tags found');
    }

    final currentVersion = await getAppCurrentVersion();

    // If exact strings match, we are definitely on the latest version
    if (latestValidTagName == currentVersion.trim()) {
      return 1;
    }

    // Semantic comparison
    final latestParsed = AppVersionNumber.tryParse(latestValidTagName);
    final currentParsed = AppVersionNumber.tryParse(currentVersion);

    if (latestParsed != null && currentParsed != null) {
      if (latestParsed.isNewerThan(currentParsed)) {
        return 0; // newer version available
      } else {
        return 1; // current version is equal or newer
      }
    }

    // Fallback if parsing fails
    return latestValidTagName != currentVersion.trim() ? 0 : 1;
  } finally {
    client.close();
  }
}

Future<String> _fetchString(HttpClient client, Uri uri) async {
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
