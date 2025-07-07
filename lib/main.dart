import 'package:diskovery/services/disk_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diskovery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ElevatedButton(
        onPressed: () async {
          final folderInfo = await DiskScanner().getFolderInfo('C:/Dev');
          print('Path: ${folderInfo.path}, Size: ${folderInfo.totalSize}');
        },
        child: Text("Analyse")),
    );
  }
}
