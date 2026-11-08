import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/themes/app_theme.dart';
import 'package:torrents_digger/ui/widgets/chip_grid_widgets.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/expandable_torrent_card.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class AddTorrentScreen extends StatefulWidget {
  const AddTorrentScreen({super.key});

  @override
  State<AddTorrentScreen> createState() => _AddTorrentScreenState();
}

class _AddTorrentScreenState extends State<AddTorrentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Wizard active step: 0 = Details, 1 = Organize, 2 = Metadata
  int _wizardStep = 0;

  late final TextEditingController _nameController;
  late final TextEditingController _infoHashController;
  late final TextEditingController _magnetController;
  late final TextEditingController _sizeNumberController;
  late final TextEditingController _dateController;
  late final TextEditingController _seedersController;
  late final TextEditingController _leechersController;
  late final TextEditingController _downloadsController;
  late final TextEditingController _sourceUrlController;

  String _selectedSizeUnit = 'GB';
  final List<String> _sizeUnits = ['MB', 'GB', 'TB', 'KB'];

  int _selectedCategoryID = 0;
  final Set<int> _selectedTagIds = {};

  bool _isSaving = false;
  bool _isPreviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _infoHashController = TextEditingController();
    _magnetController = TextEditingController();
    _sizeNumberController = TextEditingController();
    _dateController = TextEditingController();
    _seedersController = TextEditingController();
    _leechersController = TextEditingController();
    _downloadsController = TextEditingController();
    _sourceUrlController = TextEditingController();

    _nameController.addListener(_onFieldChanged);
    _sizeNumberController.addListener(_onFieldChanged);
    _infoHashController.addListener(_onFieldChanged);
    _dateController.addListener(_onFieldChanged);
    _seedersController.addListener(_onFieldChanged);
    _leechersController.addListener(_onFieldChanged);
    _downloadsController.addListener(_onFieldChanged);
    _sourceUrlController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted && _wizardStep == 2) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _sizeNumberController.removeListener(_onFieldChanged);
    _infoHashController.removeListener(_onFieldChanged);
    _dateController.removeListener(_onFieldChanged);
    _seedersController.removeListener(_onFieldChanged);
    _leechersController.removeListener(_onFieldChanged);
    _downloadsController.removeListener(_onFieldChanged);
    _sourceUrlController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _infoHashController.dispose();
    _magnetController.dispose();
    _sizeNumberController.dispose();
    _dateController.dispose();
    _seedersController.dispose();
    _leechersController.dispose();
    _downloadsController.dispose();
    _sourceUrlController.dispose();
    super.dispose();
  }

  void _updateMagnetLinkFromHash(String hash) {
    final cleanHash = hash.trim();
    if (cleanHash.isEmpty) {
      _magnetController.text = '';
    } else {
      _magnetController.text = 'magnet:?xt=urn:btih:$cleanHash';
    }
  }

  bool _isValidInfoHash(String hash) {
    final clean = hash.trim();
    return RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(clean) ||
        RegExp(r'^[a-zA-Z2-7]{32}$').hasMatch(clean);
  }

  bool _isHashInDatabase(String hash) {
    final clean = hash.trim().toLowerCase();
    if (clean.isEmpty) return false;
    final state = context.read<BookmarkedIhBloc>().state;
    return state.maybeWhen(
      loaded: (hashes) => hashes.any((h) => h.trim().toLowerCase() == clean),
      orElse: () => false,
    );
  }

  Future<bool> _isInfoHashAlreadyInDatabase(String infoHash) async {
    final clean = infoHash.trim().toLowerCase();
    if (clean.isEmpty) return false;

    // 1. Check in-memory state
    if (_isHashInDatabase(clean)) return true;

    // 2. Direct database query check
    try {
      final dbHashes = await getAllInfoHashes();
      return dbHashes.any((h) => h.trim().toLowerCase() == clean);
    } catch (_) {
      return false;
    }
  }

  Future<({bool success, bool isAlreadyAvailable, String message})>
  _parseAndAutofill(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return (
        success: false,
        isAlreadyAvailable: false,
        message: "Clipboard text is empty.",
      );
    }

    String? extractedHash;

    // 1. Check if input is a Magnet Link
    if (trimmed.toLowerCase().startsWith('magnet:?')) {
      final hashMatch = RegExp(
        r'xt=urn:btih:([a-zA-Z0-9]+)',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (hashMatch == null) {
        return (
          success: false,
          isAlreadyAvailable: false,
          message:
              "Invalid magnet link: missing 'xt=urn:btih:' info hash parameter.",
        );
      }

      final hash = hashMatch.group(1)!;
      if (!_isValidInfoHash(hash)) {
        return (
          success: false,
          isAlreadyAvailable: false,
          message:
              "Invalid info hash inside magnet link ($hash). Must be 40-char hex or 32-char Base32.",
        );
      }

      extractedHash = hash;

      // Valid magnet link - fill fields!
      _magnetController.text = trimmed;
      _infoHashController.text = hash;

      // Extract dn (display name) if present
      final dnMatch = RegExp(r'dn=([^&]+)').firstMatch(trimmed);
      if (dnMatch != null) {
        try {
          final decodedName = Uri.decodeComponent(
            dnMatch.group(1)!.replaceAll('+', ' '),
          );
          if (decodedName.trim().isNotEmpty) {
            _nameController.text = decodedName.trim();
          }
        } catch (_) {
          _nameController.text = dnMatch.group(1)!.replaceAll('+', ' ');
        }
      }

      // Extract xl parameter (size in bytes if provided)
      final xlMatch = RegExp(r'xl=(\d+)').firstMatch(trimmed);
      if (xlMatch != null) {
        final bytes = int.tryParse(xlMatch.group(1)!);
        if (bytes != null && bytes > 0) {
          if (bytes >= 1024 * 1024 * 1024) {
            final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
            _sizeNumberController.text = gb;
            _selectedSizeUnit = 'GB';
          } else {
            final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
            _sizeNumberController.text = mb;
            _selectedSizeUnit = 'MB';
          }
        }
      }
    } else if (_isValidInfoHash(trimmed)) {
      extractedHash = trimmed;
      _infoHashController.text = trimmed;
      _updateMagnetLinkFromHash(trimmed);
    } else {
      return (
        success: false,
        isAlreadyAvailable: false,
        message:
            "Clipboard is neither a valid magnet link nor a 40-char info hash.",
      );
    }

    // Check if the info hash is already bookmarked in database
    final alreadyExists = await _isInfoHashAlreadyInDatabase(extractedHash);
    if (alreadyExists) {
      final shortHash = extractedHash.length > 10
          ? '${extractedHash.substring(0, 10)}...'
          : extractedHash;
      return (
        success: true,
        isAlreadyAvailable: true,
        message:
            "⚠️ Torrent with info hash '$shortHash' is ALREADY bookmarked in your database!",
      );
    }

    return (
      success: true,
      isAlreadyAvailable: false,
      message: trimmed.toLowerCase().startsWith('magnet:?')
          ? "Valid magnet link! Autofilled torrent details."
          : "Valid info hash ($extractedHash)! Magnet link generated.",
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text == null || text.trim().isEmpty) {
      createSnackBar(message: "Clipboard is empty", duration: 2);
      return;
    }

    final result = await _parseAndAutofill(text.trim());
    if (result.success) {
      setState(() {});
      createSnackBar(
        message: result.message,
        duration: result.isAlreadyAvailable ? 5 : 3,
      );
    } else {
      createSnackBar(message: result.message, duration: 5);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary:
                  context.appColors.bookmarksSidebarSelectedTileBorderColor,
              surface: context.appColors.cardColor,
              onSurface: context.appColors.generalTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dateController.text = formatted;
      });
    }
  }

  String _formatSize() {
    final number = _sizeNumberController.text.trim();
    if (number.isEmpty) return "";
    return "$number $_selectedSizeUnit";
  }

  void _onNextStepPressed() {
    if (_wizardStep == 0) {
      // Validate step 0 required fields before proceeding
      if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
        return;
      }
    }
    if (_wizardStep < 2) {
      setState(() => _wizardStep++);
    }
  }

  void _onStepHeaderTapped(int stepIndex) {
    if (stepIndex > _wizardStep && _wizardStep == 0) {
      if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
        return;
      }
    }
    setState(() => _wizardStep = stepIndex);
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final name = _nameController.text.trim();
        final hash = _infoHashController.text.trim();

        // Prevent duplicate bookmark insertion
        final alreadyExists = await _isInfoHashAlreadyInDatabase(hash);
        if (alreadyExists) {
          createSnackBar(
            message: "This torrent is already bookmarked in your database.",
            duration: 4,
          );
          if (mounted) setState(() => _isSaving = false);
          return;
        }

        final magnet = _magnetController.text.trim().isEmpty
            ? 'magnet:?xt=urn:btih:$hash'
            : _magnetController.text.trim();
        final size = _formatSize();
        final date = _dateController.text.trim().isEmpty
            ? "N/A"
            : _dateController.text.trim();
        final seeders = _seedersController.text.trim().isEmpty
            ? "N/A"
            : _seedersController.text.trim();
        final leechers = _leechersController.text.trim().isEmpty
            ? "N/A"
            : _leechersController.text.trim();
        final downloads = _downloadsController.text.trim().isEmpty
            ? "N/A"
            : _downloadsController.text.trim();
        final sourceUrl = _sourceUrlController.text.trim().isEmpty
            ? null
            : _sourceUrlController.text.trim();

        await bookmarkTorrentManually(
          torrentName: name,
          infoHash: hash,
          magnetLink: magnet,
          torrentSize: size,
          creationDate: date,
          seeders: seeders,
          leechers: leechers,
          totalDownloads: downloads,
          sourceUrl: sourceUrl,
          categoryId: _selectedCategoryID,
          tagIds: _selectedTagIds.toList(),
        );

        if (!mounted) return;

        context.read<BookmarkedIhBloc>().add(
          BookmarkedIhEvent.addInfoHash(infoHash: hash),
        );
        context.read<BookmarkBloc>().add(
          const BookmarkEvent.loadBookmarks(
            categoryID: 65535,
            tagID: 65535,
            limit: 10,
            offset: 0,
          ),
        );

        Navigator.pop(context);
        createSnackBar(message: "Torrent added successfully!", duration: 2);
      } catch (e) {
        createSnackBar(message: "Error adding torrent: $e", duration: 8);
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final colors = context.appColors;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: colors.addTorrentManuallyFormTextFieldLabelTextColor,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: colors.addTorrentManuallyFormTextFieldLabelTextColor.withValues(
          alpha: 0.5,
        ),
        fontSize: 13,
      ),
      filled: true,
      fillColor: colors.cardColor.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.addTorrentManuallyFormTextFieldInActiveBorderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.addTorrentManuallyFormTextFieldInActiveBorderColor
              .withValues(alpha: 0.7),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.addTorrentManuallyFormTextFieldActiveBorderColor,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.addTorrentManuallyFormTextFieldErrorMessageColor,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.addTorrentManuallyFormTextFieldErrorMessageColor,
          width: 1.8,
        ),
      ),
      errorStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: colors.addTorrentManuallyFormTextFieldErrorMessageColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Torrent',
          style: TextStyle(
            color: colors.appBarTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper indicator header
            _buildStepperHeader(colors),

            // Wizard Step Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_wizardStep == 0) ...[
                        _buildQuickPasteBanner(colors),
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          colors: colors,
                          icon: Icons.title_rounded,
                          title: "Step 1: Core Torrent Info",
                          subtitle: "Name, Info Hash, and file size",
                          children: [
                            _buildNameField(context),
                            const SizedBox(height: 14),
                            _buildInfoHashField(context),
                            const SizedBox(height: 14),
                            _buildMagnetField(context),
                            const SizedBox(height: 14),
                            _buildSizeRow(context),
                          ],
                        ),
                      ] else if (_wizardStep == 1) ...[
                        _buildSectionCard(
                          colors: colors,
                          icon: Icons.bookmarks_rounded,
                          title: "Step 2: Category & Tags",
                          subtitle: "Organize for instant filtering and search",
                          children: [
                            _buildCategorySelector(context, colors),
                            const SizedBox(height: 20),
                            _buildTagsSelector(context, colors),
                          ],
                        ),
                      ] else ...[
                        _buildSectionCard(
                          colors: colors,
                          icon: Icons.speed_rounded,
                          title: "Step 3: Optional Statistics",
                          subtitle: "Peer stats, upload date, and source link",
                          children: [
                            _buildDateField(context),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _buildSeedersField(context)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildLeechersField(context)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _buildDownloadsField(context)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildSourceUrlField(context)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLivePreviewCard(colors),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Wizard Bottom Navigation Bar
            _buildBottomNav(colors),
          ],
        ),
      ),
    );
  }

  // --- Stepper Header ---
  Widget _buildStepperHeader(AppTheme colors) {
    final stepTitles = ["Details", "Organize", "Metadata"];
    final stepIcons = [
      Icons.description_outlined,
      Icons.category_outlined,
      Icons.analytics_outlined,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isCurrent = _wizardStep == index;
          final isDone = _wizardStep > index;
          final accentColor = colors.bookmarksSidebarSelectedTileBorderColor;

          return Expanded(
            child: InkWell(
              onTap: () => _onStepHeaderTapped(index),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: isDone
                        ? accentColor
                        : isCurrent
                        ? accentColor.withValues(alpha: 0.25)
                        : colors.cardSecondaryTextColor.withValues(alpha: 0.12),
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Icon(
                            stepIcons[index],
                            size: 13,
                            color: isCurrent
                                ? accentColor
                                : colors.cardSecondaryTextColor,
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stepTitles[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent || isDone
                          ? colors.cardPrimaryTextColor
                          : colors.cardSecondaryTextColor,
                    ),
                  ),
                  if (index < 2) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colors.cardSecondaryTextColor.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNav(AppTheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardColor,
        border: Border(
          top: BorderSide(
            color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_wizardStep > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: colors.cardSecondaryTextColor.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => setState(() => _wizardStep--),
                child: Text(
                  "Back",
                  style: TextStyle(
                    color: colors.cardSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_wizardStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _wizardStep < 2
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          colors.bookmarksSidebarSelectedTileBorderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _onNextStepPressed,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next Step",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                : _buildSubmitButton(colors),
          ),
        ],
      ),
    );
  }

  // --- Components ---
  Widget _buildQuickPasteBanner(AppTheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.bookmarksSidebarSelectedTileBorderColor.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.bookmarksSidebarSelectedTileBorderColor.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_fix_high_rounded,
            size: 20,
            color: colors.bookmarksSidebarSelectedTileBorderColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Paste & Autofill",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.cardPrimaryTextColor,
                  ),
                ),
                Text(
                  "Paste a magnet link or hash to fill automatically",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.cardSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: colors.bookmarksSidebarSelectedTileBorderColor
                  .withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _pasteFromClipboard,
            icon: const Icon(Icons.paste_rounded, size: 15),
            label: const Text(
              "Paste",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required AppTheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.bookmarksSidebarSelectedTileBorderColor
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: colors.bookmarksSidebarSelectedTileBorderColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.cardPrimaryTextColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.cardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Torrent Name *',
        hintText: 'e.g. Ubuntu Desktop 24.04 LTS',
        prefixIcon: const Icon(Icons.title_rounded, size: 20),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return "Torrent Name is required";
        }
        return null;
      },
    );
  }

  Widget _buildInfoHashField(BuildContext context) {
    return TextFormField(
      controller: _infoHashController,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Info Hash *',
        hintText: '40-char hex (e.g. 3b245504fb5f...)',
        prefixIcon: const Icon(Icons.tag_rounded, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.paste_rounded, size: 18),
          tooltip: 'Paste Hash',
          onPressed: () async {
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            final text = data?.text?.trim();
            if (text != null && text.isNotEmpty) {
              if (_isValidInfoHash(text)) {
                final alreadyExists = await _isInfoHashAlreadyInDatabase(text);
                setState(() {
                  _infoHashController.text = text;
                  _updateMagnetLinkFromHash(text);
                });
                if (alreadyExists) {
                  createSnackBar(
                    message:
                        "⚠️ This info hash is ALREADY in your bookmarks database!",
                    duration: 5,
                  );
                } else {
                  createSnackBar(
                    message: "Valid info hash pasted!",
                    duration: 2,
                  );
                }
              } else {
                createSnackBar(
                  message: "Clipboard text is not a valid 40-char info hash",
                  duration: 3,
                );
              }
            } else {
              createSnackBar(message: "Clipboard is empty", duration: 2);
            }
          },
        ),
      ),
      onChanged: (val) {
        _updateMagnetLinkFromHash(val);
      },
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return "Info Hash is required";
        }
        final trimmed = val.trim();
        if (!_isValidInfoHash(trimmed)) {
          return "Must be 40-char hex or 32-char Base32 info hash";
        }
        if (_isHashInDatabase(trimmed)) {
          return "This torrent is already bookmarked in your database";
        }
        return null;
      },
    );
  }

  Widget _buildMagnetField(BuildContext context) {
    return TextFormField(
      controller: _magnetController,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Magnet Link',
        hintText: 'Auto-generated from Info Hash',
        prefixIcon: const Icon(Icons.link_rounded, size: 20),
      ),
      onChanged: (val) {
        final match = RegExp(
          r'xt=urn:btih:([a-zA-Z0-9]+)',
          caseSensitive: false,
        ).firstMatch(val);
        if (match != null) {
          _infoHashController.text = match.group(1)!;
        }
      },
      validator: (val) {
        if (val == null || val.trim().isEmpty) return null;
        final trimmed = val.trim();
        if (!trimmed.toLowerCase().startsWith('magnet:?')) {
          return "Must start with magnet:?";
        }
        final match = RegExp(
          r'xt=urn:btih:([a-zA-Z0-9]+)',
          caseSensitive: false,
        ).firstMatch(trimmed);
        if (match == null) {
          return "Missing 'xt=urn:btih:' info hash";
        }
        if (!_isValidInfoHash(match.group(1)!)) {
          return "Contains an invalid info hash";
        }
        return null;
      },
    );
  }

  Widget _buildSizeRow(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: TextFormField(
            controller: _sizeNumberController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: colors.addTorrentManuallyFormInputTextColor,
            ),
            decoration: _buildInputDecoration(
              context: context,
              labelText: 'Size *',
              hintText: 'e.g. 1.5 or 700',
              prefixIcon: const Icon(Icons.data_usage_rounded, size: 20),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Size is required";
              }
              final numVal = double.tryParse(val.trim());
              if (numVal == null || numVal <= 0) {
                return "Enter a valid positive number";
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.cardColor.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.addTorrentManuallyFormTextFieldInActiveBorderColor
                    .withValues(alpha: 0.7),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSizeUnit,
                isExpanded: true,
                dropdownColor: colors.cardColor,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: colors.bookmarksSidebarSelectedTileBorderColor,
                ),
                items: _sizeUnits.map((u) {
                  return DropdownMenuItem(
                    value: u,
                    child: Text(
                      u,
                      style: TextStyle(
                        color: colors.cardPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSizeUnit = val);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context, AppTheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Category",
              style: TextStyle(
                color: colors.cardPrimaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            ActionChip(
              avatar: Icon(
                Icons.add_rounded,
                size: 16,
                color: colors.bookmarkCategoryIconColor,
              ),
              label: Text(
                'New Category',
                style: TextStyle(
                  color: colors.bookmarkCategoryIconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: colors.bookmarkCategoryIconColor.withValues(
                alpha: 0.12,
              ),
              side: BorderSide(
                color: colors.bookmarkCategoryIconColor.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                createItemDialog(
                  context,
                  title: "New Category",
                  hintText: "Category Name",
                  emptyErrorMessage: "Category Name can't be empty...",
                  onCreate: (name) => context.read<CategoryBloc>().add(
                    CategoryEvent.create(newCategoryName: name),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressBarWidget()),
              loaded: (categoriesList) {
                final filtered = categoriesList
                    .where((c) => c.id != 65535)
                    .toList();

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filtered.map((category) {
                    final isSelected = _selectedCategoryID == category.id;
                    return FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      selectedColor:
                          colors.addTorrentManuallyFormSelectedCategoryBGColor,
                      checkmarkColor:
                          colors.addTorrentManuallyFormCheckmarkColor,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? colors
                                  .addTorrentManuallyFormSelectedCategoryNameTextColor
                            : colors
                                  .addTorrentManuallyFormUnSelectedCategoryNameTextColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategoryID = category.id;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagsSelector(BuildContext context, AppTheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tags",
              style: TextStyle(
                color: colors.cardPrimaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            ActionChip(
              avatar: Icon(
                Icons.add_rounded,
                size: 16,
                color: colors.bookmarksStatsIconColor,
              ),
              label: Text(
                'New Tag',
                style: TextStyle(
                  color: colors.bookmarksStatsIconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: colors.bookmarksStatsIconColor.withValues(
                alpha: 0.12,
              ),
              side: BorderSide(
                color: colors.bookmarksStatsIconColor.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                createItemDialog(
                  context,
                  title: "New Tag",
                  hintText: "Tag Name",
                  emptyErrorMessage: "Tag Name can't be empty...",
                  onCreate: (name) => context.read<TagsBloc>().add(
                    TagsEvent.create(newTagName: name),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressBarWidget()),
              loaded: (tagsList) {
                final filtered = tagsList.where((t) => t.id != 65535).toList();

                if (filtered.isEmpty) {
                  return Text(
                    "No tags created yet. Tap '+ New Tag' above to add one.",
                    style: TextStyle(
                      color: colors.cardSecondaryTextColor,
                      fontSize: 12.5,
                    ),
                  );
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filtered.map((tag) {
                    final isSelected = _selectedTagIds.contains(tag.id);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor:
                          colors.addTorrentManuallyFormSelectedTagBGColor,
                      checkmarkColor:
                          colors.addTorrentManuallyFormCheckmarkColor,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? colors
                                  .addTorrentManuallyFormSelectedTagNameTextColor
                            : colors
                                  .addTorrentManuallyFormUnSelectedTagNameTextColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Creation Date (YYYY-MM-DD)',
        hintText: 'e.g. 2026-05-13',
        prefixIcon: const Icon(Icons.event_rounded, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_rounded, size: 18),
          tooltip: 'Select Date',
          onPressed: _pickDate,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (!dateRegex.hasMatch(value.trim())) {
          return 'Use format: YYYY-MM-DD (e.g. 2026-05-13)';
        }
        return null;
      },
    );
  }

  Widget _buildSeedersField(BuildContext context) {
    return TextFormField(
      controller: _seedersController,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Seeders',
        hintText: 'e.g. 150',
        prefixIcon: const Icon(Icons.arrow_upward_rounded, size: 18),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return null;
        if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
          return 'Must be an integer';
        }
        return null;
      },
    );
  }

  Widget _buildLeechersField(BuildContext context) {
    return TextFormField(
      controller: _leechersController,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Leechers',
        hintText: 'e.g. 25',
        prefixIcon: const Icon(Icons.arrow_downward_rounded, size: 18),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return null;
        if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
          return 'Must be an integer';
        }
        return null;
      },
    );
  }

  Widget _buildDownloadsField(BuildContext context) {
    return TextFormField(
      controller: _downloadsController,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Downloads',
        hintText: 'e.g. 1200',
        prefixIcon: const Icon(Icons.download_done_rounded, size: 18),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return null;
        if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
          return 'Must be an integer';
        }
        return null;
      },
    );
  }

  Widget _buildSourceUrlField(BuildContext context) {
    return TextFormField(
      controller: _sourceUrlController,
      keyboardType: TextInputType.url,
      style: TextStyle(
        color: context.appColors.addTorrentManuallyFormInputTextColor,
      ),
      decoration: _buildInputDecoration(
        context: context,
        labelText: 'Source URL',
        hintText: 'https://...',
        prefixIcon: const Icon(Icons.language_rounded, size: 18),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return null;
        final uri = Uri.tryParse(val.trim());
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          return 'Enter a valid URL';
        }
        return null;
      },
    );
  }

  Widget _buildLivePreviewCard(AppTheme colors) {
    final name = _nameController.text.trim().isEmpty
        ? 'Untitled Torrent'
        : _nameController.text.trim();
    final hash = _infoHashController.text.trim().isEmpty
        ? '0000000000000000000000000000000000000000'
        : _infoHashController.text.trim();
    final magnet = _magnetController.text.trim().isEmpty
        ? 'magnet:?xt=urn:btih:$hash'
        : _magnetController.text.trim();
    final size = _formatSize().isEmpty ? '0 B' : _formatSize();
    final date = _dateController.text.trim().isEmpty
        ? ''
        : _dateController.text.trim();
    final seeders = _seedersController.text.trim().isEmpty
        ? '0'
        : _seedersController.text.trim();
    final leechers = _leechersController.text.trim().isEmpty
        ? '0'
        : _leechersController.text.trim();
    final downloads = _downloadsController.text.trim().isEmpty
        ? '0'
        : _downloadsController.text.trim();
    final sourceUrl = _sourceUrlController.text.trim().isEmpty
        ? null
        : _sourceUrlController.text.trim();

    final previewTorrent = InternalTorrent(
      infoHash: hash,
      name: name,
      magnet: magnet,
      size: size,
      date: date,
      seeders: seeders,
      leechers: leechers,
      totalDownloads: downloads,
      sourceUrl: sourceUrl,
    );

    // Selected Category name
    String categoryName = 'None';
    final categoryState = context.read<CategoryBloc>().state;
    categoryState.whenOrNull(
      loaded: (cats) {
        final matching = cats.where((c) => c.id == _selectedCategoryID);
        if (matching.isNotEmpty) categoryName = matching.first.name;
      },
    );

    // Selected Tag names
    final List<String> selectedTagNames = [];
    final tagState = context.read<TagsBloc>().state;
    tagState.whenOrNull(
      loaded: (tags) {
        for (final tag in tags) {
          if (_selectedTagIds.contains(tag.id)) {
            selectedTagNames.add(tag.name);
          }
        }
      },
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.bookmarksSidebarSelectedTileBorderColor.withValues(
            alpha: 0.35,
          ),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with View Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.bookmarksSidebarSelectedTileBorderColor
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.preview_rounded,
                  size: 18,
                  color: colors.bookmarksSidebarSelectedTileBorderColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bookmark Preview",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: colors.cardPrimaryTextColor,
                      ),
                    ),
                    Text(
                      "Live preview of how it looks in your library",
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.cardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // View Switcher: Row vs Expanded
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.cardSecondaryTextColor.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPreviewToggleOption(
                      icon: Icons.view_headline_rounded,
                      label: "Compact",
                      isSelected: !_isPreviewExpanded,
                      colors: colors,
                      onTap: () {
                        setState(() => _isPreviewExpanded = false);
                      },
                    ),
                    const SizedBox(width: 3),
                    _buildPreviewToggleOption(
                      icon: Icons.crop_landscape_rounded,
                      label: "Expanded",
                      isSelected: _isPreviewExpanded,
                      colors: colors,
                      onTap: () {
                        setState(() => _isPreviewExpanded = true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Organization target tags (Category & Tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: colors.cardSecondaryTextColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_special_rounded,
                  size: 14,
                  color: colors.bookmarksSidebarSelectedTileBorderColor,
                ),
                const SizedBox(width: 6),
                Text(
                  "Assigned to: ",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colors.cardSecondaryTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bookmarkCategoryIconColor.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: colors.bookmarkCategoryIconColor,
                    ),
                  ),
                ),
                if (selectedTagNames.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: selectedTagNames.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.bookmarksStatsIconColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "#$tag",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.bookmarksStatsIconColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // The Live Expandable Torrent Card
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpandableTorrentCard(
              key: ValueKey(
                'preview_${previewTorrent.infoHash}_${previewTorrent.name}_${previewTorrent.size}_${previewTorrent.seeders}_${previewTorrent.leechers}_$_isPreviewExpanded',
              ),
              torrent: previewTorrent,
              forceExpanded: _isPreviewExpanded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewToggleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required AppTheme colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.bookmarksSidebarSelectedTileBorderColor.withValues(
                  alpha: 0.22,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected
              ? Border.all(
                  color: colors.bookmarksSidebarSelectedTileBorderColor
                      .withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? colors.bookmarksSidebarSelectedTileBorderColor
                  : colors.cardSecondaryTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
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

  Widget _buildSubmitButton(AppTheme colors) {
    return ElevatedButton(
      onPressed: _isSaving ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor:
            colors.addTorrentManuallyFormAddTorrentButtonBackgroundColor,
        side: BorderSide(
          color: colors.addTorrentManuallyFormAddTorrentButtonBorderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressBarWidget(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_add_rounded,
                  size: 20,
                  color: colors.addTorrentManuallyFormAddTorrentButtonTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Torrent',
                  style: TextStyle(
                    color:
                        colors.addTorrentManuallyFormAddTorrentButtonTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
