import 'dart:io';

import 'package:diskovery/models/folder_info.dart';

class DiskScanner {
  Future<FolderInfo> getFolderInfo(String folderpath) async {
    var dir = Directory(folderpath);
    bool isFolderExist = await dir.exists();
    if (!isFolderExist) {
      throw Exception("Folder doesn't exist");
    }

    int totalSize = 0;
    await dir.list(recursive: true, followLinks: false).forEach((FileSystemEntity entity) async {
      if (entity is File) {
        totalSize += entity.lengthSync();
      }
    });

    return FolderInfo(path: folderpath, totalSize: totalSize);
  }
}