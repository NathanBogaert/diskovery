import 'package:diskovery/services/disk_scanner.dart';
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
  String _currentPath = '';
  int _percent = 0;

  Future<void> _startScan() async {
    setState(() {
      _progress = 0;
      _currentPath = '';
      _percent = 0;
    });

    final result = await DiskScanner().getFolderInfo(
      r"C:\Dev",
      ({
        required String currentPath,
        required int processedFiles,
        required int totalFiles,
        required int totalSize,
      }) {
        setState(() {
          _progress = totalFiles == 0 ? 0 : processedFiles / totalFiles;
          _currentPath = currentPath;
          _percent = (_progress * 100).toInt();
        });
      }
    );

    print("Path: ${result.path} Size: ${result.totalSize} Duration: ${result.duration}");
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
                  "Analyzing : $_currentPath",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12
                  ),
                ),
                LinearProgressIndicator(
                  value: _progress,
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  minHeight: 6,
                ),
                Text(
                  "$_percent% complete",
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
          ],
        ),
      ),
    );
  }
}