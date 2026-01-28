import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

void exportDatabaseDesktop() {
  final rootPath = Platform.environment['HOME'] ?? '.';
  Directory rootDirPath = Directory(rootPath);
  String databasePath =
      "${rootDirPath.path}/.torrents_digger/torrents_digger.database";
  createSnackBar(
    message:
        "Database is in Path :\n$databasePath\n Database Path Copied to Clipboard",
    duration: 5,
  );
  Clipboard.setData(ClipboardData(text: databasePath));
}

void exportDatabaseAndroid() async {
  // database file/folder name
  String databaseFileName = "torrents_digger.database";
  String internalScopedStoragedatabaseDirName = ".torrents_digger";

  // Internal Scoped Storage Dir
  Directory androidDocumentsDirectory =
      await getApplicationDocumentsDirectory();
  File internalScopedStorageDatabaseFilePath = File(
    "${androidDocumentsDirectory.path}/$internalScopedStoragedatabaseDirName/$databaseFileName",
  );

  try {
    final params = SaveFileDialogParams(
      sourceFilePath: internalScopedStorageDatabaseFilePath.path,
    );
    final filePath = await FlutterFileDialog.saveFile(params: params);

    if (filePath != null) {
      createSnackBar(
        message: "Database File Exported.\nPath -> $filePath",
        duration: 5,
      );
    } else {
      createSnackBar(message: "Failed to export Database.", duration: 5);
    }
  } catch (e) {
    createSnackBar(
      message: "Failed To Export Database File !!!\nError : ${e.toString()}",
      duration: 5,
    );
  }
}

void importDatabaseAndroid() async {
  // database file/folder name
  String databaseFileName = "torrents_digger.database";
  String internalScopedStoragedatabaseDirName = ".torrents_digger";

  // Internal Scoped Storage Dir
  Directory androidDocumentsDirectory =
      await getApplicationDocumentsDirectory();
  File internalScopedStorageDatabaseFilePath = File(
    "${androidDocumentsDirectory.path}/$internalScopedStoragedatabaseDirName/$databaseFileName",
  );

  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);

    String importedFileName = file.path.split('/').last;

    // Database file name should contain databaseFileName
    if (importedFileName.contains(databaseFileName)) {
      //  Reading database file
      List<int> databaseFileData = await file.readAsBytes();

      try {
        // Writing file to internal scoped storage
        await internalScopedStorageDatabaseFilePath.writeAsBytes(
          databaseFileData,
        );
        createSnackBar(message: "Database imported...", duration: 2);
      } catch (e) {
        createSnackBar(
          message: "Unable to Import Database.\nError: ${e.toString}",
          duration: 5,
        );
      }
    } else {
      createSnackBar(
        message: "Invalid File Picked.\nPick a Valid Database File.",
        duration: 5,
      );
    }
  } else {
    createSnackBar(message: "Failed to Pick database File", duration: 2);
  }
}

void importDatabaseDesktop() {
  final rootPath = Platform.environment['HOME'] ?? '.';
  Directory rootDirPath = Directory(rootPath);
  String databasePath = "${rootDirPath.path}/.torrents_digger";
  createSnackBar(
    message: "Place your Database file in Path :\n$databasePath",
    duration: 5,
  );
}
