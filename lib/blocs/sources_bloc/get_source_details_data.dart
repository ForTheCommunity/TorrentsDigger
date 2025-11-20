import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

Future<List<InternalSource>> initialSourceDetailsData() async {
  return await fetchSourceDetails();
}
