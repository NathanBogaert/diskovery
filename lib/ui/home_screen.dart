import 'dart:io';
import 'dart:math';

import 'package:diskovery/models/folder_node.dart';
import 'package:diskovery/services/disk_scanner.dart';
import 'package:diskovery/services/tree_view.dart';
import 'package:diskovery/utils/format_bytes.dart';
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
  List<FolderNode> _rootNode = [];
  final TreeView _treeView = TreeView();
  String? _selectedPath;
  bool _isScanning = false;
  int _totalFiles = 0;
  int _scannedFiles = 0;
  final _sortItems = ['Sort by A-Z', 'Sort by Z-A', 'Sort by Size asc', 'Sort by Size desc'];
  String _sortOption = 'Sort by A-Z';
  final _sizeUnit = {"KB": 1024, "MB": pow(1024, 2).toInt(), "GB": pow(1024, 3).toInt(), "TB": pow(1024, 4).toInt()};
  String _selectedSizeUnit = "GB";
  int? _minSize;

  @override
  void initState() {
    super.initState();
    initTree();
  }

  Future initTree() async {
    final List<FolderNode> disks = await _treeView.loadInitialTree();
    _selectedPath = disks.first.path;

    setState(() {
      _rootNode = disks;
      _sortTree();
    });
  }

  Future<void> _startScan(String path) async {
    setState(() {
      _isScanning = true;
      _progress = 0;
      _percent = 0;
      _scannedFiles = 0;
      _totalFiles = 0;
      _currentScanPath = '';
      _duration = null;
    });

    final Stopwatch stopwatch = Stopwatch()..start();

    final result = await DiskScanner().scanFolderIsolate(
      path,
      (progress) {
        setState(() {
          _currentScanPath = progress.currentPath;
          _scannedFiles = progress.processed;
          _totalFiles = progress.totalFiles;
          _duration = stopwatch.elapsed;
          _progress = (_scannedFiles / _totalFiles).clamp(0, 1);
          _percent = (_progress * 100).toInt();
        });
      },
    );

    stopwatch.stop();

    setState(() {
      _totalFiles = _scannedFiles;
      _progress = (_scannedFiles / _totalFiles).clamp(0, 1);
      _percent = (_progress * 100).toInt();
      _duration = stopwatch.elapsed;
      _treeView.updateNodeWithScanResult(result, _rootNode);
      _sortTree();
      _isScanning = false;
    });
    debugPrint("Path: ${result.path} Size: ${result.size} Duration: ${stopwatch.elapsed}");
  }

  bool _matchesFilter(FolderNode node) {
    if (node.children != null) {
      for (final child in node.children!) {
        if (_matchesFilter(child)) return true;
      }
    }

    final minSizeInBytes = _minSize != null ? _minSize! * (_sizeUnit[_selectedSizeUnit] ?? 1) : null;
    final sizeMatches = minSizeInBytes == null || (node.size ?? 0) >= minSizeInBytes;
    return sizeMatches;
  }

  Widget _buildFolderNode(FolderNode node, [int depth = 0]) {
    if (!_matchesFilter(node)) {
        return const SizedBox.shrink();
    }

    final nodeSize = node.size != null ? formatBytes(node.size!) : "";

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
        trailing: Text(nodeSize),
      );
    } else {
      return ExpansionTile(
        key: PageStorageKey(node.path),
        dense: true,
        leading: Icon(
          node.type == ElementType.file ? Icons.file_copy : node.isExpanded ? Icons.folder_open : Icons.folder,
          size: 20,
        ),
        trailing: Text(nodeSize),
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
            _selectedPath = node.path;
            debugPrint(_selectedPath);
          });

          if (expanded && node.children == null) {
            final dir = Directory(node.path);
            final children = await _treeView.getChildren(dir);
            setState(() {
              node.children = children;
              _sortTree();
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

  void _sortTree() {
    _treeView.sortChildren(_rootNode, _sortOption);
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
                      text: "Scan Selected Disk: ${_selectedPath != null ? _selectedPath!.substring(0, 2): ""}", 
                      onPressed: () => _startScan(_selectedPath!.substring(0, 2)),
                      isButtonDisabled: _isScanning,
                    ),
                    ButtonWidget(
                      text: "Scan Selected Folder: $_selectedPath", 
                      onPressed: () => _startScan(_selectedPath!),
                      isButtonDisabled: _isScanning,
                    ),
                  ],
                )
              ],
            ),
            TextFieldWidget(
              hintText: "Add minimum size to display",
              onChanged: (value) {
                setState(() {
                  _minSize = int.tryParse(value!);
                });
              },
              suffixWidget: DropdownButtonWidget(
                items: _sizeUnit.keys.toList(),
                selectedItem: _selectedSizeUnit,
                onChanged: (value) {
                  setState(() {
                    _selectedSizeUnit = value!;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                DropdownButtonWidget(
                  items: _sortItems,
                  selectedItem: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value!;
                      _sortTree();
                    });
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  !_isScanning ? "Waiting for scan" : _progress == 0 ? "Estimating Scan Size" : "Analyzing: $_currentScanPath",
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
                  "$_percent% complete (scanned $_scannedFiles${_duration != null ? " in $_duration" : ""})",
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
            Expanded(
              child: ListView(
                children: _rootNode.map((node) => _buildFolderNode(node)).toList(),
              )
            ),
          ],
        ),
      ),
    );
  }
}