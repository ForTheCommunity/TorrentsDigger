import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_all/webview_all.dart';

class SourceWebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const SourceWebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<SourceWebViewScreen> createState() => _SourceWebViewScreenState();
}

class _SourceWebViewScreenState extends State<SourceWebViewScreen> {
  WebViewController? _controller;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();

  bool _isLoading = true;
  double _progress = 0.0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  late String _currentUrl;
  late String _pageTitle;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title ?? widget.url;
    _initWebView();
  }

  Future<void> _initWebView() async {
    final controller = WebViewController();
    _controller = controller;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
                if (progress >= 100) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageFinished: (url) async {
            if (mounted) {
              final title = await controller.getTitle();
              final canBack = await controller.canGoBack();
              final canForward = await controller.canGoForward();
              setState(() {
                _isLoading = false;
                _currentUrl = url;
                if (title != null && title.trim().isNotEmpty) {
                  _pageTitle = title;
                }
                _canGoBack = canBack;
                _canGoForward = canForward;
              });
            }
            _syncCookies(url);
          },
          onUrlChange: (change) {
            if (change.url != null && mounted) {
              setState(() {
                _currentUrl = change.url!;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept magnet URIs and open in torrent client
            if (request.url.startsWith('magnet:')) {
              openUrl(urlType: UrlType.magentLink, url: request.url);
              createSnackBar(
                message: "Opening magnet link in torrent client...",
                duration: 2,
              );
              return NavigationDecision.prevent;
            }
            // Intercept Matrix links and open in external browser / matrix app
            if (request.url.startsWith('matrix:') ||
                request.url.contains('matrix.to')) {
              openUrl(
                urlType: UrlType.normalLink,
                forceExternal: true,
                url: request.url,
              );
              createSnackBar(
                message: "Opening Matrix link in external browser...",
                duration: 2,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Apply custom User-Agent if configured
    try {
      final ua = await getAppUserAgent();
      if (ua.isNotEmpty) {
        await controller.setUserAgent(ua);
      }
    } catch (_) {}

    // Apply stored cookies for the target domain
    final targetUri = Uri.tryParse(widget.url);
    if (targetUri != null) {
      try {
        final domain = targetUri.host;
        final savedCookies = await getDomainCookie(domain);
        if (savedCookies != null && savedCookies.isNotEmpty) {
          for (final pair in savedCookies.split(';')) {
            final parts = pair.trim().split('=');
            if (parts.length >= 2) {
              final name = parts[0].trim();
              final value = parts.sublist(1).join('=').trim();
              if (name.isNotEmpty) {
                await _cookieManager.setCookie(
                  WebViewCookie(name: name, value: value, domain: domain),
                );
              }
            }
          }
        }
      } catch (_) {}
    }

    if (targetUri != null) {
      await controller.loadRequest(targetUri);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncCookies(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final cookies = await _cookieManager.getCookies(domain: uri);
      if (cookies.isNotEmpty) {
        final cookieMap = <String, String>{};
        for (final c in cookies) {
          cookieMap[c.name] = c.value;
        }
        final cookieHeader = cookieMap.entries
            .map((e) => '${e.key}=${e.value}')
            .join('; ');
        await saveDomainCookie(uri.host, cookieHeader);
      }
    } catch (_) {}
  }

  Future<void> _openExternal() async {
    String target = _currentUrl;
    try {
      final current = await _controller?.currentUrl();
      if (current != null && current.isNotEmpty) {
        target = current;
      }
    } catch (_) {}

    final uri = Uri.tryParse(target);
    if (uri != null) {
      try {
        createSnackBar(
          message: "Opening in external browser...",
          duration: 2,
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        createSnackBar(message: "Unable to open in browser: $e", duration: 3);
      }
    }
  }

  Future<void> _copyUrl() async {
    String target = _currentUrl;
    try {
      final current = await _controller?.currentUrl();
      if (current != null && current.isNotEmpty) {
        target = current;
      }
    } catch (_) {}

    await Clipboard.setData(ClipboardData(text: target));
    createSnackBar(message: "URL copied to clipboard", duration: 2);
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(_currentUrl);
    final domain = uri?.host ?? _currentUrl;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_controller != null && await _controller!.canGoBack()) {
          await _controller!.goBack();
          final canBack = await _controller!.canGoBack();
          final canForward = await _controller!.canGoForward();
          if (mounted) {
            setState(() {
              _canGoBack = canBack;
              _canGoForward = canForward;
            });
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.appColors.scaffoldColor,
        appBar: AppBar(
          backgroundColor: context.appColors.appBarBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: context.appColors.appBarBackButtonIconColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _pageTitle,
                style: TextStyle(
                  color: context.appColors.appBarTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                domain,
                style: TextStyle(
                  color: context.appColors.appBarTextColor.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 18,
                color: _canGoBack
                    ? context.appColors.appBarTextColor
                    : context.appColors.appBarTextColor.withValues(alpha: 0.3),
              ),
              tooltip: 'Go Back',
              onPressed: _canGoBack
                  ? () async {
                      if (_controller != null &&
                          await _controller!.canGoBack()) {
                        await _controller!.goBack();
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _canGoForward
                    ? context.appColors.appBarTextColor
                    : context.appColors.appBarTextColor.withValues(alpha: 0.3),
              ),
              tooltip: 'Go Forward',
              onPressed: _canGoForward
                  ? () async {
                      if (_controller != null &&
                          await _controller!.canGoForward()) {
                        await _controller!.goForward();
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: context.appColors.appBarTextColor,
              ),
              tooltip: 'Reload',
              onPressed: () {
                _controller?.reload();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
                size: 20,
                color: context.appColors.appBarTextColor,
              ),
              tooltip: 'Copy Link',
              onPressed: _copyUrl,
            ),
            IconButton(
              icon: Icon(
                Icons.open_in_browser_rounded,
                size: 21,
                color: context.appColors.appBarTextColor,
              ),
              tooltip: 'Open in External Browser',
              onPressed: _openExternal,
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2.5),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    color: context.appColors.circularProgressIndicatorColor,
                    backgroundColor:
                        context.appColors.textFormFieldInactiveColor,
                    minHeight: 2.5,
                  ),
                )
              : null,
        ),
        body: _controller == null
            ? Center(
                child: CircularProgressIndicator(
                  color: context.appColors.circularProgressIndicatorColor,
                ),
              )
            : WebViewWidget(controller: _controller!),
      ),
    );
  }
}
