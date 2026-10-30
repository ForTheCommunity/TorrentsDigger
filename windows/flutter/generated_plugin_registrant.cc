//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <url_launcher_windows/url_launcher_windows.h>
#include <webview_all_windows/webview_all_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WebviewAllWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewAllWindowsPlugin"));
}
