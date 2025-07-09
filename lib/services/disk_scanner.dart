import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:diskovery/models/folder_node.dart';
import 'package:diskovery/models/folder_scan_progress.dart';

class DiskScanner {
  Future<FolderNode> scanFolderIsolate(
    String folderPath,
    void Function(FolderScanProgress) onProgress
  ) async {
    final receivePort = ReceivePort();
    final completer = Completer<FolderNode>();

    await Isolate.spawn(
      _scanFolder, 
      [folderPath, receivePort.sendPort]
    );

    late StreamSubscription sub;
    sub = receivePort.listen((message) {
      if (message is FolderScanProgress) {
        onProgress(message);
      } else if (message is FolderNode) {
        completer.complete(message);
        sub.cancel();
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future _scanFolder(List<dynamic> args) async {
    final String folderPath = args[0];
    final SendPort sendPort = args[1];

    final dir = Directory(folderPath);
    final List<FileSystemEntity> allEntities = await dir
      .list(recursive: true, followLinks: false)
      .toList();
    final files = allEntities.whereType<File>().toList();
    final totalFiles = files.length;

    int processed = 0;
    int totalSize = 0;

    Future<FolderNode> buildTree(Directory dir) async {
      int size = 0;
      List<FolderNode> children = [];
      final entities = await dir.list(followLinks: false).toList();

      for (final entity in entities) {
        if (entity is File) {
          final fileSize = await entity.length();
          size += fileSize;
          totalSize += fileSize;
          processed++;

          children.add(FolderNode(
            path: entity.path,
            size: fileSize,
            type: ElementType.file
          ));

          sendPort.send(FolderScanProgress(
            currentPath: entity.path, 
            processedFiles: processed, 
            totalFiles: totalFiles, 
            totalSize: totalSize
            )
          );
        } else if (entity is Directory) {
          final child = await buildTree(entity);
          size += child.size ?? 0;
          children.add(child);
        }
      }

      return FolderNode(
        path: dir.path, 
        size: size, 
        type: ElementType.folder,
        children: children
      );
    }

    final result = await buildTree(dir);

    sendPort.send(result);
  }
}