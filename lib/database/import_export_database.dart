import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

void exportDatabaseLinux() {
  final rootPath = Platform.environment['HOME'] ?? '.';
  Directory rootDirPath = Directory(rootPath);
  String databasePath =
      "${rootDirPath.path}/.torrents_digger/torrents_digger.database";
  createSnackBar(
    message:
        "Database is in Path :\n$databasePath\n Database Path Copied to Clipboard",
    duration: 10,
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

  //   // getting path to the Downloads Directory..
  final downloadDirPath = await ExternalPath.getExternalStoragePublicDirectory(
    ExternalPath.DIRECTORY_DOWNLOAD,
  );
  File file = File("$downloadDirPath/$databaseFileName");

  // Check if the file exists in private storage
  if (await internalScopedStorageDatabaseFilePath.exists()) {
    //  Reading database file from internal scoped storage
    List<int> databaseFileData = await internalScopedStorageDatabaseFilePath
        .readAsBytes();

    // Writing file to shared storage
    await file.writeAsBytes(databaseFileData);

    createSnackBar(
      message:
          "Database Exported at Internal Storage \nPath : Internal Storage/$downloadDirPath/$databaseFileName",
      duration: 15,
    );
  } else {
    createSnackBar(
      message: "Database Not Found in Internal Scoped Storage",
      duration: 15,
    );
  }
}

void import_database_android() async {
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
    //  Reading database file
    List<int> databaseFileData = await file.readAsBytes();

    // Writing file to shared storage
    await internalScopedStorageDatabaseFilePath.writeAsBytes(databaseFileData);
  } else {
    createSnackBar(message: "Failed to Pick database File", duration: 10);
  }
}

void importDatabaseLinux() {
  final rootPath = Platform.environment['HOME'] ?? '.';
  Directory rootDirPath = Directory(rootPath);
  String databasePath = "${rootDirPath.path}/.torrents_digger";
  createSnackBar(
    message: "Place your Database file in Path :\n$databasePath",
    duration: 10,
  );
}
