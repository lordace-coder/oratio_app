import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:io';
import 'package:open_filex/open_filex.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FileDownloadHandler {
  static Future<String> getDownloadPath(String fileName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return '${directory.path}/$fileName';
  }

  static Future<bool> isFileDownloaded(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Error opening file: $e');
    }
  }

  static Future<void> downloadRawFile(BuildContext context, String url,
      {bool? isvideo}) async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }

    try {
      // Extract file name from URL
      final fileName = url.split('/').last;
      final savePath = await getDownloadPath(fileName);

      // Check if file already exists
      if (await isFileDownloaded(savePath)) {
        // If file exists, just open it
        await openFile(savePath);
        return;
      }

      // Download file using Dio
      if (isvideo == true) {
        NotificationService.showInfo("Downloading Video...");
        await Dio().download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total) * 100;
              debugPrint('Download Progress: ${progress.toStringAsFixed(0)}%');
            }
          },
        );
      } else {
        NotificationService.showInfo("Saving Image...");
        await Dio().download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total) * 100;
              debugPrint('Download Progress: ${progress.toStringAsFixed(0)}%');
            }
          },
        );
      }

      // Show the dialog using the provided context
      bool? openFileDialog = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download Complete'),
            content: const Text('Do you want to open the file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (openFileDialog == true) {
        await openFile(savePath);
      }
    } catch (e) {
      debugPrint('Error handling file: $e');
      throw Exception('Failed to handle file: $e');
    }
  }

  static void showDownloadProgress(BuildContext context, double progress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Downloading...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 20),
              Text('${progress.toStringAsFixed(0)}%'),
            ],
          ),
        );
      },
    );
  }

  static Future<void> downloadFile(
      types.FileMessage message, BuildContext context) async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }

    try {
      final savePath = await getDownloadPath(message.name);

      // Check if file already exists
      if (await isFileDownloaded(savePath)) {
        // If file exists, just open it
        await openFile(savePath);
        return;
      }

      // Download file using Dio
      NotificationService.showInfo("Downloading File Message");
      await Dio().download(
        message.uri,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            debugPrint('Download Progress: ${progress.toStringAsFixed(0)}%');
            showDownloadProgress(context, progress / 100);
          }
        },
      );

      // Close the progress dialog
      Navigator.of(context).pop();

      // Open the file after download
      await openFile(savePath);
    } catch (e) {
      debugPrint('Error handling file: $e');
      throw Exception('Failed to handle file: $e');
    }
  }

  static Future<void> downloadImageFromBytes(
      BuildContext context, Uint8List imageBytes, String fileName) async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }

    try {
      final directory = await getExternalStorageDirectory();
      final savePath = '${directory!.path}/$fileName';

      // Write the bytes to a file
      final file = File(savePath);
      await file.writeAsBytes(imageBytes);

      // Notify the user
      NotificationService.showInfo("Image saved to $savePath");

      // Show the dialog using the provided context
      bool? openFileDialog = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download Complete'),
            content: const Text('Do you want to open the file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (openFileDialog == true) {
        await openFile(savePath);
      }
    } catch (e) {
      throw Exception('Error saving image: $e');
    }
  }
}
