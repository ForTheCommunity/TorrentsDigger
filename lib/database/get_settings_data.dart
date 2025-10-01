import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';

void getSettingsValues() async {
  Map<String, String> settings_kv = await getSettingsKv();
  var _ = settings_kv.length;
  // TODO LATER
}
