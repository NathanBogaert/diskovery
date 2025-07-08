import 'dart:io';

import 'package:diskovery/models/folder_info.dart';

typedef ProgressCallback = void Function({
  required String currentPath,
  required int processedFiles,
  required int totalFiles,
  required int totalSize,
});

class DiskScanner {
  Future<FolderInfo> getFolderInfo(
    String folderPath, 
    ProgressCallback? onProgress
  ) async {
    var dir = Directory(folderPath);
    bool isFolderExist = await dir.exists();
    if (!isFolderExist) {
      throw Exception("Folder doesn't exist");
    }

    final stopwatch = Stopwatch()..start();

    final allFiles = await dir
      .list(recursive: true, followLinks: false)
      .where((entity) => entity is File)
      .toList();
    final totalFiles = allFiles.length;

    int totalSize = 0;
    int processedFiles = 0;

    for (final entity in allFiles) {
      if (entity is File) {
        totalSize += await entity.length();
        processedFiles++;
        if (onProgress != null) {
          onProgress(
            currentPath: entity.path,
            processedFiles: processedFiles,
            totalFiles: totalFiles,
            totalSize: totalSize,
          );
        }
      }
    }

    stopwatch.stop();

    return FolderInfo(path: folderPath, totalSize: totalSize, duration: stopwatch.elapsed);
  }
}