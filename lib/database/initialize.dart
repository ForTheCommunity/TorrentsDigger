import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/src/rust/api/database/initialize.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

Future<void> initializeDatabase() async {
  Directory platformSpecificDatabaseDirectory;

  if (Platform.isLinux) {
    // ignore: non_constant_identifier_names
    var XDGDatadir = await (await getApplicationSupportDirectory()).create(
      recursive: true,
    );
    platformSpecificDatabaseDirectory = XDGDatadir;
  } else if (Platform.isAndroid) {
    // fix new db path.
    // path of database is changed from Version 1.2.1.
    await fixDatabase();
    platformSpecificDatabaseDirectory = await getApplicationSupportDirectory();
    platformSpecificDatabaseDirectory.create(recursive: true);
  } else if (Platform.isWindows) {
    platformSpecificDatabaseDirectory = await getApplicationSupportDirectory();
    platformSpecificDatabaseDirectory.create(recursive: true);
  } else {
    throw UnsupportedError('Unsupported platform');
  }
  try {
    await initializeTorrentsDiggerDatabase(
      torrentsDiggerDatabaseDirectory: platformSpecificDatabaseDirectory.path,
    );
  } catch (e) {
    createSnackBar(message: "Error : $e", duration: 5);
  }
}

// fixing database for android..
Future<void> fixDatabase() async {
  // Old App Root Path
  Directory oldAppRootPath = await getApplicationDocumentsDirectory();
  String oldDBPath =
      "${oldAppRootPath.path}/.torrents_digger/torrents_digger.database";

  // New App Root Path
  Directory newAppRootPath = await getApplicationSupportDirectory();
  String newDBPath = "${newAppRootPath.path}/torrents_digger.database";

  // if db is in old path and if new db path is empty
  // then moving old db to new path...
  if (await File(oldDBPath).exists() && !await File(newDBPath).exists()) {
    // creating new path (Fail Safe)
    newAppRootPath.create(recursive: true);
    // copying db to new path
    await File(oldDBPath).copy(newDBPath);
  }
}
