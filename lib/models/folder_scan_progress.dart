import 'package:diskovery/models/folder_node.dart';

class FolderScanProgress {
  final String currentPath;
  final int processed;
  final FolderNode? partialInfo;
  final int totalFiles;

  FolderScanProgress({
    required this.currentPath,
    required this.processed, 
    required this.totalFiles,
    this.partialInfo});
}