import 'dart:io';

import 'package:diskovery/models/folder_node.dart';
import 'package:diskovery/services/disk_scanner.dart';
import 'package:diskovery/services/tree_view.dart';
import 'package:diskovery/widgets/button_widget.dart';
import 'package:diskovery/widgets/dropdown_button_widget.dart';
import 'package:diskovery/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _progress = 0;
  String _currentScanPath = '';
  int _percent = 0;
  Duration? _duration;
  FolderNode? _rootNode;
  final TreeView _treeView = TreeView();
  final String _currentPath = r"C:\Program Files (x86)\Steam";

  @override
  void initState() {
    super.initState();
    updateTree();
  }

  Future updateTree() async {
    final children = await _treeView.getChildren(Directory(_currentPath));

    setState(() {
      _rootNode = FolderNode(
        path: _currentPath, 
        children: children,
        type: ElementType.folder,
      );
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _progress = 0;
      _currentScanPath = '';
      _percent = 0;
      _duration = null;
    });

    final Stopwatch stopwatch = Stopwatch()..start();

    final result = await DiskScanner().scanFolderIsolate(
      _currentPath,
      (progress) {
        setState(() {
          _currentScanPath = progress.currentPath;
          _progress = progress.totalFiles == 0 
            ? 0 
            : progress.processedFiles / progress.totalFiles;
          _percent = (_progress * 100).toInt();
        });
      },
    );

    stopwatch.stop;

    setState(() {
      _rootNode = result;
      _duration = stopwatch.elapsed;
    });
    print("Path: ${result.path} Size: ${result.size} Duration: ${stopwatch.elapsed}");
  }

  Widget _buildFolderNode(FolderNode node, [int depth = 0]) {
    if (node.type == ElementType.file) {
      return ListTile(
        key: PageStorageKey(node.path),
        dense: true,
        leading: Icon(
          Icons.file_copy, 
          size: 20,
        ),
        title: Text(
          _getFolderName(node.path),
          style: TextStyle(fontSize: 12),
        ),
        contentPadding: EdgeInsets.only(left: depth * 20, right: 16),
        trailing: Text(
          node.size != null ? " ${(node.size! / (1024 * 1024)).toStringAsFixed(2)} MB" : ""
        ),
      );
    } else {
      return ExpansionTile(
        key: PageStorageKey(node.path),
        dense: true,
        leading: Icon(
          node.type == ElementType.file ? Icons.file_copy : node.isExpanded ? Icons.folder_open : Icons.folder,
          size: 20,
        ),
        trailing: Text(
          node.size != null ? " ${(node.size! / (1024 * 1024)).toStringAsFixed(2)} MB" : ""
        ),
        title: Text(
          _getFolderName(node.path),
          style: TextStyle(
            fontSize: 12
          ),
        ),
        tilePadding: EdgeInsets.only(left: depth * 20, right: 16),
        initiallyExpanded: node.isExpanded,
        onExpansionChanged: (expanded) async {
          setState(() {
            node.isExpanded = expanded;
          });

          if (expanded && node.children == null) {
            final dir = Directory(node.path);
            final children = await _treeView.getChildren(dir);
            setState(() {
              node.children = children;
            });
          }
        },
        children: (node.children ?? [])
          .map((child) => _buildFolderNode(child, depth + 1))
          .toList(),
      );
    }
  }

  String _getFolderName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: 45,
        title: Text(
          "Diskovery",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), 
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          )
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 128.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Start Analyse your Disk",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 16.0,
                  children: [
                    ButtonWidget(
                      text: "Start Scan", 
                      onPressed: _startScan,
                    ),
                    ButtonWidget(
                      text: "Scan Selected Folder", 
                      onPressed: _startScan,
                    ),
                  ],
                )
              ],
            ),
            TextFieldWidget(hintText: "Search folders or files"),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                DropdownButtonWidget(items: ['Sort by Size asc', 'Sort by Size desc']),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  "Analyzing : $_currentScanPath",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12
                  ),
                  maxLines: 1,
                ),
                LinearProgressIndicator(
                  value: _progress,
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  minHeight: 6,
                ),
                Text(
                  "$_percent% complete ${_duration != null ? "in $_duration" : ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[700],
                    fontSize: 10
                  ),
                ),
              ],
            ),
            Text(
              "Folder Structure",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13
              ),
            ),
            if (_rootNode != null)
              Expanded(
                child: ListView(
                  children: [_buildFolderNode(_rootNode!)],
                )
              )
          ],
        ),
      ),
    );
  }
}