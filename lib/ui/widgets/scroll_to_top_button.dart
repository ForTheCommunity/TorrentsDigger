import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showOffset;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.showOffset = 800.0,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final isVisible =
        widget.scrollController.hasClients &&
        widget.scrollController.offset >= widget.showOffset;
    if (isVisible != _isVisible) {
      setState(() {
        _isVisible = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    return FloatingActionButton(
      backgroundColor: context.appColors.scrollToTopButtonBackgroundColor,
      mini: true,
      heroTag: null,
      onPressed: () => widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.slowMiddle,
      ),
      child: Icon(
        Icons.keyboard_double_arrow_up,
        color: context.appColors.scrollToTopButtonIconColor,
      ),
    );
  }
}
