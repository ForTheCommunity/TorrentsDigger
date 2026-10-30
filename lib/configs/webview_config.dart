import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_all_linux/webview_all_linux.dart';
import 'package:path/path.dart' as path;
import 'package:webview_all_windows/webview_all_windows.dart';

Future<void> webviewConfig() async {
  if (Platform.isLinux) {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final cacheDir = await getApplicationCacheDirectory();
      await LinuxWebViewController.ensureEnvironment(
        userDataPath: path.join(supportDir.path, "WebKit"),
        cachePath: path.join(cacheDir.path, "WebKit"),
      );
    } catch (e) {
      debugPrint('Failed to initialize Linux WebView environment: $e');
    }
  } else if (Platform.isWindows) {
    try {
      final supportDir = await getApplicationSupportDirectory();
      await WindowsWebViewController.ensureEnvironment(
        userDataPath: path.join(supportDir.path, "WebView2"),
      );
    } catch (e) {
      debugPrint('Failed to initialize Windows WebView environment: $e');
    }
  }
}
