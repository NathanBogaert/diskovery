enum ElementType { file, folder }

class FolderNode {
  final String path;
  List<FolderNode>? children;
  bool isExpanded;
  int? size;
  final ElementType type;

  FolderNode({
    required this.path,
    this.children,
    this.isExpanded = false,
    this.size,
    required this.type,
  });

  static FolderNode empty(String path) => FolderNode(
    path: path,
    type: ElementType.folder,
    size: 0,
    children: []
  );
}