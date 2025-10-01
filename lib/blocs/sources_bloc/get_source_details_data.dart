import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

Future<Map<String, InternalSourceDetails>> initialSourceDetailsData() async {
  return await fetchSourceDetails();
}
