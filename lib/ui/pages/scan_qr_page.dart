// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart' as barcode;

// class ScanQrPage extends StatefulWidget {
//   const ScanQrPage({super.key});

//   @override
//   State<ScanQrPage> createState() => _ScanQrPageState();
// }

// class _ScanQrPageState extends State<ScanQrPage> {
//   final _controller = barcode.MobileScannerController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           barcode.MobileScanner(
//             controller: _controller,
//           )
//         ],
//       ),
//     );
//   }
// }
