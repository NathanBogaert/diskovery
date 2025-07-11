import 'dart:io';

import 'package:diskovery/models/folder_node.dart';
import 'package:diskovery/utils/debug_print.dart';
import 'package:windows_disk_utils/windows_disk_utils.dart';

class TreeView {
  final diskUtils = WindowsDiskUtils();

  Future loadInitialTree() async {
    final disks = await diskUtils.getDisks();

    return disks
      .map((entity) => FolderNode(
        path: entity.name, 
        type: ElementType.folder))
      .toList();
  }

  Future getChildren(Directory path) async {
    List<FileSystemEntity> entities = [];

    try {
      entities = await path.list(followLinks: false).toList();
    } catch (e) {
      debugPrint("Error on expand node $path: $e");
      return;
    }

    return entities
      .map((entity) => FolderNode(
        path: entity.path,
        type: entity is Directory ? ElementType.folder : ElementType.file))
      .toList();
  }

  void updateNodeWithScanResult(FolderNode scannedNode, List<FolderNode> targetNodes) {
    for (var i = 0; i < targetNodes.length; i++) {
      if (targetNodes[i].path == scannedNode.path) {
        targetNodes[i].size = scannedNode.size;
        targetNodes[i].children = scannedNode.children;
        return;
      }

      if (targetNodes[i].children != null) {
        updateNodeWithScanResult(scannedNode, targetNodes[i].children!);
      }
    }
  }

  void sortChildren(List<FolderNode> nodes, String sortOption) {
    for (final node in nodes) {
      if (node.children != null) {
        node.children!.sort((a, b) {
          switch (sortOption) {
            case 'Sort by A-Z':
              return a.path.toLowerCase().compareTo(b.path.toLowerCase());
            case 'Sort by Z-A':
              return b.path.toLowerCase().compareTo(a.path.toLowerCase());
            case 'Sort by Size asc':
              return (a.size ?? 0).compareTo((b.size ?? 0));
            case 'Sort by Size desc':
              return (b.size ?? 0).compareTo((a.size ?? 0));
            default:
              return 0;
          }
        });
        sortChildren(node.children!, sortOption);
      }
    }
  }
}