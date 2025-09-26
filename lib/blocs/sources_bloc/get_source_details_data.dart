import 'package:torrents_digger/src/rust/api/app.dart';

Future<Map<String, InternalSourceDetails>> initialSourceDetailsData() async {
  return await fetchSourceDetails();
}
