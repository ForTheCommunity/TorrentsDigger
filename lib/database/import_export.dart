import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

const String databaseFileName = "torrents_digger.database";

void importDatabaseDesktop() async {
  String? rootPath = await getAppRootDir();

  if (rootPath != null) {
    createSnackBar(
      message:
          "Put Database is in Path :\n$rootPath\n Path Copied to Clipboard",
      duration: 5,
    );
    Clipboard.setData(ClipboardData(text: rootPath));
  } else if (rootPath == null) {
    createSnackBar(message: "app_root_dir is null !!!", duration: 10);
  } else {
    createSnackBar(message: "Something Went Wrong !!!", duration: 10);
  }
}

void exportDatabaseDesktop() async {
  String? rootPath = await getAppRootDir();

  if (rootPath != null) {
    String databasePath = "$rootPath/$databaseFileName";
    createSnackBar(
      message:
          "Database is in Path :\n$databasePath\n Path Copied to Clipboard",
      duration: 5,
    );
    Clipboard.setData(ClipboardData(text: databasePath));
  } else if (rootPath == null) {
    createSnackBar(message: "app_root_dir is null !!!", duration: 10);
  } else {
    createSnackBar(message: "Something Went Wrong !!!", duration: 10);
  }
}

void exportDatabaseAndroid() async {
  Directory databaseDir = await getApplicationSupportDirectory();
  File databaseFile = File("${databaseDir.path}/$databaseFileName");

  try {
    final params = SaveFileDialogParams(sourceFilePath: databaseFile.path);
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
  Directory databaseDir = await getApplicationSupportDirectory();
  File databaseFile = File("${databaseDir.path}/$databaseFileName");

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
        await databaseFile.writeAsBytes(databaseFileData);
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
