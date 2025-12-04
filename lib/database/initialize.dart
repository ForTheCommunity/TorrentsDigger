import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/src/rust/api/database/initialize.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

Future<void> initializeDatabase() async {
  Directory platformSpecificDatabaseDirectory;

  if (Platform.isLinux) {
    final homeDirectory = Platform.environment['HOME'] ?? '.';
    platformSpecificDatabaseDirectory = Directory(homeDirectory);
    await platformSpecificDatabaseDirectory.create(recursive: true);
  } else if (Platform.isAndroid) {
    platformSpecificDatabaseDirectory =
        await getApplicationDocumentsDirectory();
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
