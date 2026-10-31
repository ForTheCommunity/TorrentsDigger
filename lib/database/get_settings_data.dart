import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';

// void getSettingsValues() async {
//   Map<String, String> settings_kv = await getSettingsKv();
//   var _ = settings_kv.length;
//   // TODO LATER
// }

Future<String?> getAppRootDir() async {
  // getting Platform Specific App Root Dir
  // from Settings KeyValue Store(Sqlite Database).
  String? appRootDirPath = await getASettingsKv(key: "app_root_dir");
  return appRootDirPath;
}

Future<void> saveDomainCookie(String domain, String cookies) async {
  final cleanDomain = domain.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

  await insertOrUpdateKv(key: "cf_cookie_$cleanDomain", value: cookies);
  await insertOrUpdateKv(key: "cf_cookie_www.$cleanDomain", value: cookies);
}

Future<String?> getDomainCookie(String domain) async {
  final cleanDomain = domain.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
  final val = await getASettingsKv(key: "cf_cookie_$cleanDomain");

  return val;
}

Future<void> clearDomainCookie(String domain) async {
  final cleanDomain = domain.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
  await insertOrUpdateKv(key: "cf_cookie_$cleanDomain", value: "");
  await insertOrUpdateKv(key: "cf_cookie_www.$cleanDomain", value: "");
}

Future<void> setAppUserAgent(String ua) async {
  await insertOrUpdateKv(key: "app_user_agent", value: ua);
}

Future<String> getAppUserAgent() async {
  final customUa = await getASettingsKv(key: "app_user_agent");
  if (customUa != null && customUa.trim().isNotEmpty) {
    return customUa;
  }
  const defaultUa =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36";
  return defaultUa;
}
