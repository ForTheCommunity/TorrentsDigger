import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';

enum ActiveScreen { search, customs, bookmarks, settings, none }

class FloatingActionsButtons extends StatefulWidget {
  final bool scrollToTop;
  final bool enableAddTorrent;
  final bool enableCustoms;
  final bool enableBookmarks;
  final bool enableSettings;
  final ActiveScreen activeScreen;
  final ScrollController? scrollController;
  final bool hasTorrents;
  final double showScrollToTopOffset;

  const FloatingActionsButtons({
    super.key,
    this.scrollToTop = true,
    this.enableAddTorrent = false,
    this.enableCustoms = true,
    this.enableBookmarks = true,
    this.enableSettings = true,
    this.activeScreen = ActiveScreen.none,
    this.scrollController,
    this.hasTorrents = false,
    this.showScrollToTopOffset = 80.0,
  });

  @override
  State<FloatingActionsButtons> createState() => _FloatingActionsButtonsState();
}

class _FloatingActionsButtonsState extends State<FloatingActionsButtons> {
  bool _isScrolledDown = false;
  ScrollController? _attachedController;

  @override
  void initState() {
    super.initState();
    _updateControllerListener(widget.scrollController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkScroll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.scrollController == null) {
      final primary = PrimaryScrollController.maybeOf(context);
      _updateControllerListener(primary);
    }
  }

  @override
  void didUpdateWidget(covariant FloatingActionsButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _updateControllerListener(widget.scrollController);
    }
    _checkScroll();
  }

  @override
  void dispose() {
    _attachedController?.removeListener(_checkScroll);
    super.dispose();
  }

  void _updateControllerListener(ScrollController? newController) {
    if (_attachedController != newController) {
      _attachedController?.removeListener(_checkScroll);
      _attachedController = newController;
      _attachedController?.addListener(_checkScroll);
    }
  }

  void _checkScroll() {
    final controller =
        _attachedController ??
        widget.scrollController ??
        PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      final bool isScrolled = controller.offset > widget.showScrollToTopOffset;
      if (isScrolled != _isScrolledDown) {
        setState(() {
          _isScrolledDown = isScrolled;
        });
      }
    } else if (_isScrolledDown) {
      setState(() {
        _isScrolledDown = false;
      });
    }
  }

  void _scrollToTop() {
    final controller =
        _attachedController ??
        widget.scrollController ??
        PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool showScrollToTop =
        widget.scrollToTop && widget.hasTorrents && _isScrolledDown;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.bookmarksSidebarDividerColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search / Main screen
            _buildDockButton(
              context: context,
              icon: Icons.search,
              tooltip: "Search",
              isActive: widget.activeScreen == ActiveScreen.search,
              onPressed: () {
                if (widget.activeScreen == ActiveScreen.search) {
                  _scrollToTop();
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RoutesName.mainScreen,
                    (route) => false,
                  );
                }
              },
            ),

            if (widget.enableCustoms) ...[
              const SizedBox(width: 4),
              _buildDockButton(
                context: context,
                icon: Icons.dashboard_customize_outlined,
                tooltip: "Custom Sources",
                isActive: widget.activeScreen == ActiveScreen.customs,
                onPressed: () {
                  if (widget.activeScreen == ActiveScreen.customs) {
                    _scrollToTop();
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutesName.customsScreen,
                      (route) => route.isFirst,
                    );
                  }
                },
              ),
            ],

            if (widget.enableBookmarks) ...[
              const SizedBox(width: 4),
              _buildDockButton(
                context: context,
                icon: Icons.bookmarks_rounded,
                tooltip: "Bookmarks",
                isActive: widget.activeScreen == ActiveScreen.bookmarks,
                onPressed: () {
                  if (widget.activeScreen == ActiveScreen.bookmarks) {
                    _scrollToTop();
                  } else {
                    Navigator.pushNamed(context, RoutesName.bookmarksScreen);
                  }
                },
              ),
            ],

            if (widget.enableAddTorrent) ...[
              const SizedBox(width: 4),
              _buildDockButton(
                context: context,
                icon: Icons.add_outlined,
                tooltip: "Add Torrent",
                isActive: false,
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.addTorrentScreen);
                },
              ),
            ],

            if (widget.enableSettings) ...[
              const SizedBox(width: 4),
              _buildDockButton(
                context: context,
                icon: Icons.settings_outlined,
                tooltip: "Settings",
                isActive: widget.activeScreen == ActiveScreen.settings,
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.settingsScreen);
                },
              ),
            ],

            if (showScrollToTop) ...[
              Container(
                height: 20,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: colors.bookmarksSidebarDividerColor,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 20),
                tooltip: "Scroll to Top",
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: colors.bookmarksSidebarSelectedTileTextColor,
                onPressed: _scrollToTop,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDockButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final colors = context.appColors;

    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: colors.bookmarksSidebarSelectedTileBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.bookmarksSidebarSelectedTileBorderColor
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            )
          : null,
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        splashRadius: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        color: isActive
            ? colors.bookmarksSidebarSelectedTileTextColor
            : colors.cardSecondaryTextColor,
        onPressed: onPressed,
      ),
    );
  }
}
