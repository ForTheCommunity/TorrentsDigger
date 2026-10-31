import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:webview_all/webview_all.dart';

class CloudflareSolverDialog extends StatefulWidget {
  final String challengeUrl;
  final VoidCallback onSolved;

  const CloudflareSolverDialog({
    super.key,
    required this.challengeUrl,
    required this.onSolved,
  });

  static bool _isShowing = false;

  static Future<bool?> show(BuildContext context, String challengeUrl) async {
    if (_isShowing) return null;
    _isShowing = true;
    try {
      return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Container(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          decoration: BoxDecoration(
            color: sheetContext.appColors.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: CloudflareSolverDialog(
            challengeUrl: challengeUrl,
            onSolved: () {
              // Challenge solved, dismiss modal bottom sheet
              if (Navigator.of(sheetContext).canPop()) {
                Navigator.of(sheetContext).pop(true);
              }
            },
          ),
        ),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<CloudflareSolverDialog> createState() => _CloudflareSolverDialogState();
}

class _CloudflareSolverDialogState extends State<CloudflareSolverDialog> {
  WebViewController? _controller;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  Timer? _pollTimer;
  bool _isLoading = true;
  bool _isSaving = false;
  String _statusText = 'Please complete the verification if prompted';
  late Uri _targetUri;

  @override
  void initState() {
    super.initState();
    _targetUri = Uri.parse(widget.challengeUrl);
    _initWebView();

    // Periodic check to capture Turnstile completion as soon as cf_clearance is issued
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _autoCheckSolved('poll_timer');
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncUserAgent() async {
    try {
      final realUa = await _controller?.getUserAgent();
      if (realUa != null && realUa.isNotEmpty) {
        // Detected native WebView UA: $realUa
        await setAppUserAgent(realUa);
      }
    } catch (_) {
      // Could not query native UA
    }
  }

  Future<void> _initWebView() async {
    // Clear existing cookies so old expired tokens don't falsely trigger solve
    try {
      await _cookieManager.clearCookies();
    } catch (_) {}

    // Initializing WebView for target URI
    final WebViewController controller = WebViewController();
    _controller = controller;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        // WebView console: [${message.level.name}] ${message.message}
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // Page started loading: $url
            if (mounted) {
              setState(() {
                _isLoading = true;
                _statusText = 'Loading $url...';
              });
            }
          },
          onPageFinished: (url) async {
            // Page finished loading: $url
            if (mounted) {
              setState(() {
                _isLoading = false;
                _statusText = 'Checking verification status...';
              });
            }
            await _syncUserAgent();
            await _autoCheckSolved('onPageFinished: $url');
            if (mounted && !_isSaving) {
              setState(() {
                _statusText = 'Please complete the verification if prompted';
              });
            }
          },
          onWebResourceError: (error) {
            // Resource load error: code=${error.errorCode}, desc=${error.description}
          },
          onUrlChange: (change) {
            // URL changed: ${change.url}
            if (change.url != null) {
              _autoCheckSolved('onUrlChange: ${change.url}');
            }
          },
        ),
      );

    await _syncUserAgent();
    await controller.loadRequest(_targetUri);

    if (mounted) {
      setState(() {});
    }
  }

  Future<Map<String, String>> _extractCookies() async {
    List<WebViewCookie> cookies = [];
    try {
      cookies = await _cookieManager.getCookies(domain: _targetUri);
    } catch (_) {
      // CookieManager.getCookies(domain) error
    }

    if (cookies.isEmpty) {
      try {
        final rootUri = Uri.parse('${_targetUri.scheme}://${_targetUri.host}/');
        cookies = await _cookieManager.getCookies(domain: rootUri);
      } catch (_) {
        // CookieManager.getCookies(rootUri) error
      }
    }

    String? jsCookies;
    try {
      final res = await _controller?.runJavaScriptReturningResult(
        'document.cookie',
      );
      jsCookies = res?.toString().replaceAll('"', '').trim();
    } catch (_) {
      // Could not run JS document.cookie
    }

    final cookieMap = <String, String>{};
    for (final c in cookies) {
      if (!c.name.startsWith('cf_chl_')) {
        cookieMap[c.name] = c.value;
      }
    }

    if (jsCookies != null && jsCookies.isNotEmpty) {
      for (final part in jsCookies.split(';')) {
        final split = part.split('=');
        if (split.length >= 2) {
          final k = split[0].trim();
          final v = split.sublist(1).join('=').trim();
          if (k.isNotEmpty &&
              !k.startsWith('cf_chl_') &&
              !cookieMap.containsKey(k)) {
            cookieMap[k] = v;
          }
        }
      }
    }

    return cookieMap;
  }

  Future<void> _autoCheckSolved([String? source]) async {
    if (_isSaving) return;

    try {
      final cookieMap = await _extractCookies();
      final hasClearance = cookieMap.containsKey('cf_clearance');

      if (hasClearance) {
        // Verify that the page is not still sitting on the Cloudflare challenge page
        String? title;
        try {
          title = await _controller?.getTitle();
        } catch (_) {}

        final isStillChallenging = title != null && (
          title.toLowerCase().contains('just a moment') ||
          title.toLowerCase().contains('attention required') ||
          title.toLowerCase().contains('checking your browser')
        );

        if (isStillChallenging) {
          return;
        }

        _pollTimer?.cancel();
        createSnackBar(message: 'Verification successful!', duration: 2);
        await _saveAndFinish(cookieMap);
      }
    } catch (_) {
      // Auto-check error
    }
  }

  Future<void> _saveAndFinish(Map<String, String> cookieMap) async {
    if (_isSaving) return;
    _isSaving = true;
    _pollTimer?.cancel();

    if (mounted) {
      setState(() {
        _statusText = 'Verified! Closing...';
      });
    }

    try {
      final cookieHeader = cookieMap.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');
      final domain = _targetUri.host;

      await _syncUserAgent();
      // Saving cookies for domain
      await saveDomainCookie(domain, cookieHeader);

      if (mounted) {
        widget.onSolved();
      }
    } catch (e) {
      createSnackBar(message: 'Error saving cookies: $e', duration: 5);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _statusText = 'Error saving cookies: $e';
        });
      }
    }
  }

  Future<void> _submitManualVerification() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _statusText = 'Extracting clearance cookies...';
    });

    try {
      // Manual Done tapped
      final cookieMap = await _extractCookies();

      if (cookieMap.isEmpty || !cookieMap.containsKey('cf_clearance')) {
        createSnackBar(
          message:
              'No clearance cookie found yet. Please complete the verification checkbox first.',
          duration: 3,
        );
        if (mounted) {
          setState(() {
            _isSaving = false;
            _statusText = 'No clearance cookie found yet. Please complete verification first.';
          });
        }
        return;
      }

      _pollTimer?.cancel();
      await _saveAndFinish(cookieMap);
    } catch (e) {
      createSnackBar(message: 'Error during verification: $e', duration: 5);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _statusText = 'Error saving cookies: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.appColors.textFormFieldInactiveColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: context.appColors.circularProgressIndicatorColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloudflare Verification',
                      style: TextStyle(
                        color: context.appColors.generalTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: context.appColors.generalTextColor.withOpacity(
                          0.7,
                        ),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Reload Page',
                icon: Icon(
                  Icons.refresh,
                  color: context.appColors.generalTextColor,
                  size: 20,
                ),
                onPressed: () {
                  _controller?.reload();
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      context.appColors.circularProgressIndicatorColor,
                  foregroundColor: context.appColors.scaffoldColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: _isSaving
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.appColors.scaffoldColor,
                        ),
                      )
                    : const Icon(Icons.check, size: 16),
                label: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isSaving ? null : _submitManualVerification,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.appColors.generalTextColor,
                ),
                onPressed: () {
                  // Dialog closed by user
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          LinearProgressIndicator(
            color: context.appColors.circularProgressIndicatorColor,
            backgroundColor: context.appColors.textFormFieldInactiveColor,
            minHeight: 2,
          ),
        Expanded(
          child: _controller == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.appColors.circularProgressIndicatorColor,
                  ),
                )
              : WebViewWidget(controller: _controller!),
        ),
      ],
    );
  }
}
