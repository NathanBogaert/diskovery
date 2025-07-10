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
}