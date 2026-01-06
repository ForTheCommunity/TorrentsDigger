import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:torrents_digger/database/get_settings_data.dart';

Future<void> hydrationSetup() async {
  // Hydration Point.
  String? appRootDirPath = await getAppRootDir();
  Directory hydrationDir;

  if (appRootDirPath != null) {
    var hPath = path.join(appRootDirPath, ".torrents_digger", "hydration");
    hydrationDir = Directory(hPath);
  } else {
    // fallback hydration point
    hydrationDir = await getApplicationSupportDirectory();
  }

  // Hydration Setup
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(hydrationDir.path),
  );
}
