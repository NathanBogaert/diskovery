import 'package:diskovery/models/folder_node.dart';

class FolderScanProgress {
  final String currentPath;
  final int processedFiles;
  final int totalFiles;
  final int totalSize;
  final FolderNode? partialInfo;

  FolderScanProgress({
    required this.currentPath,
    required this.processedFiles, 
    required this.totalFiles, 
    required this.totalSize, 
    this.partialInfo});
}