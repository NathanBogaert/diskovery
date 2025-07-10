import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:diskovery/models/folder_node.dart';
import 'package:diskovery/models/folder_scan_progress.dart';
import 'package:diskovery/utils/debug_print.dart';

class DiskScanner {
  Future<FolderNode> scanFolderIsolate(
    String folderPath,
    void Function(FolderScanProgress) onProgress,
  ) async {
    final scanReceivePort = ReceivePort();
    final completer = Completer<FolderNode>();

    await Isolate.spawn(
      _scanFolder, 
      [folderPath, scanReceivePort.sendPort]
    );

    late StreamSubscription sub;
    sub = scanReceivePort.listen((message) {
      if (message is FolderScanProgress) {
        onProgress(message);
      } else if (message is FolderNode) {
        completer.complete(message);
        sub.cancel();
        scanReceivePort.close();
      }
    });

    return completer.future;
  }

  static Future _scanFolder(List<dynamic> args) async {
    final String folderPath = args[0];
    final SendPort sendPort = args[1];

    final dir = Directory(folderPath);
    int processed = 0;
    int totalFiles = 0;

    Future countFiles(Directory dir) async {
      try {
        final entities = await dir.list(followLinks: false).toList();
        for (final entity in entities) {
          if (entity is File) {
            totalFiles++;
          } else if (entity is Directory) {
            countFiles(entity);
          }
        }
      } catch (e) {
        debugPrint("Error on counting files: $e");
      }
    }

    await countFiles(dir);

    Future<FolderNode> buildTree(Directory dir) async {
      int folderSize = 0;
      List<FolderNode> children = [];
      List<FileSystemEntity> entities = [];

      try {
        entities = await dir.list(followLinks: false).toList();
      } catch (e) {
        sendPort.send(FolderScanProgress(
          currentPath: dir.path,
          processed: processed,
          totalFiles: totalFiles,
        ));

        debugPrint("Folder skipped: ${dir.path} due to error: $e");

        return FolderNode(
          path: dir.path,
          type: ElementType.folder,
          size: 0,
          children: []
        );
      }
      
      for (final entity in entities) {
        if (entity is File) {
          int fileSize = 0;
          try {
            fileSize = await entity.length();
            folderSize += fileSize;
            processed++;

            children.add(FolderNode(
              path: entity.path,
              size: fileSize,
              type: ElementType.file
            ));

            sendPort.send(FolderScanProgress(
              currentPath: entity.path,
              processed: processed,
              totalFiles: totalFiles,
            ));
          } catch (e) {
            fileSize = 0;
            debugPrint(e);
          }
        } else if (entity is Directory) {
          final child = await buildTree(entity);
          folderSize += child.size ?? 0;
          children.add(child);
        }
      }

      return FolderNode(
        path: dir.path, 
        size: folderSize, 
        type: ElementType.folder,
        children: children
      );
    }

    final result = await buildTree(dir);
    sendPort.send(result);
  }
}