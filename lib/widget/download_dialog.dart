import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class DownloadingDialog extends StatefulWidget {
  const DownloadingDialog({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  _DownloadingDialogState createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  Dio dio = Dio();
  double progress = 0.0;
  bool fileDownloaded = false;

  void startDownloading() async {
    List<String> urlParts = widget.url.split("?");
    String fileName = urlParts[0].split("/").last;

    String path = await _getFilePath(fileName);
    print(path);

    if (await _isFileExists(path)) {
      setState(() {
        fileDownloaded = true;
      });
    } else {
      await dio.download(
        widget.url,
        path,
        onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            progress = receivedBytes / totalBytes;
          });

          print(progress);
        },
        deleteOnError: true,
      ).then((_) {
        setState(() {
          fileDownloaded = true;
        });
      });
    }
  }

  Future<String> _getFilePath(String filename) async {
    final dir = await getApplicationSupportDirectory();
    return "${dir.path}/$filename";
  }

  Future<bool> _isFileExists(String filePath) async {
    File file = File(filePath);
    return await file.exists();
  }

  void openFile() async {
    List<String> urlParts = widget.url.split("?");
    String fileName = urlParts[0].split("/").last;
    String path = await _getFilePath(fileName);
    OpenFile.open(path);
  }

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  @override
  Widget build(BuildContext context) {
    String downloadingprogress = (progress * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: Colors.deepPurple[200],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fileDownloaded)
            ElevatedButton(
              onPressed: openFile,
              child: const Text(
                "Open File",
                style: TextStyle(color: Colors.black),
              ),
            ),
          if (!fileDownloaded)
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Downloading: $downloadingprogress%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
