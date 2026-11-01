import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/database/initialize.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

const String databaseFileName = "torrents_digger.database";

Future<void> importDatabase() async {
  try {
    PlatformFile? file = await FilePicker.pickFile(
      dialogTitle: "Import Database",
    );

    if (file == null) {
      return; // User canceled
    }

    String importedFileName = file.name;

    // Database file name should contain 'torrents_digger' and extension should be 'database'
    if (importedFileName.contains('torrents_digger') &&
        file.extension == 'database') {
      Directory databaseDir = await getApplicationSupportDirectory();
      File databaseFile = File("${databaseDir.path}/$databaseFileName");

      // Reading database file
      Uint8List databaseFileData = await file.readAsBytes();

      // Writing file to internal scoped storage
      await databaseFile.writeAsBytes(databaseFileData);
      createSnackBar(message: "Database imported...", duration: 2);
      // try migration if db is old.
      await tryMigrateDatabase2Latest();
    } else {
      createSnackBar(
        message: "Invalid File Picked.\nPick a Valid Database File.",
        duration: 5,
      );
    }
  } catch (e) {
    createSnackBar(
      message: "Unable to Import Database.\nError: ${e.toString()}",
      duration: 5,
    );
  }
}

Future<void> exportDatabase() async {
  try {
    Directory databaseDir = await getApplicationSupportDirectory();
    File databaseFile = File("${databaseDir.path}/$databaseFileName");

    if (!await databaseFile.exists()) {
      createSnackBar(
        message: "Database file does not exist to export.",
        duration: 4,
      );
      return;
    }

    Uint8List bytes = await databaseFile.readAsBytes();

    Uri? result = await FilePicker.saveFile(
      dialogTitle: "Export Database",
      fileName: databaseFileName,
      bytes: bytes,
    );

    if (result != null) {
      createSnackBar(
        message: "Database File Exported.",
        duration: 3,
      );
    }
  } catch (e) {
    createSnackBar(
      message: "Failed To Export Database File !!!\nError : ${e.toString()}",
      duration: 5,
    );
  }
}
