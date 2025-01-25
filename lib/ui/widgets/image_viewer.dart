import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageViewer extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;

  const ImageViewer({super.key, this.imageBytes, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          'Image Viewer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: imageBytes != null
                ? Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                  )
                : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                if (await Permission.manageExternalStorage.request().isGranted) {
                  imageUrl != null
                      ? FileDownloadHandler.downloadRawFile(context, imageUrl!)
                      : imageBytes != null
                          ? FileDownloadHandler.downloadImageFromBytes(
                              context,
                              imageBytes!,
                              'ORATIO-IMG-${DateTime.now().toString()}')
                          : null;
                } else {
                  // Handle permission denied
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permission denied')),
                  );
                }
              },
              child: const Column(
                children: [
                  Icon(
                    Icons.save_alt_rounded,
                    color: Colors.white,
                  ),
                  Text('Save to device', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...

void openImageView(
  BuildContext context,
  String uri, {
  Uint8List? imageBytes,
  String? imageUrl,
}) async {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImageViewer(
        imageBytes: imageBytes,
        imageUrl: imageUrl,
      ),
    ),
  );
}
