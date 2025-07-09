import 'dart:io';

import 'package:diskovery/models/folder_node.dart';

class TreeView {
  Future loadInitialTree(Directory path) async {
    return getChildren(path);
  }

  Future getChildren(Directory path) async {
    final entities = await path.list(followLinks: false).toList();

    return entities
      .map((entity) => FolderNode(
        path: entity.path,
        type: entity is Directory ? ElementType.folder : ElementType.file))
      .toList();
  }
}