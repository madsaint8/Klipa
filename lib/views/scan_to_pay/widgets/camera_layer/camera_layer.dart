import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'camera_state.dart';

/// Full-screen camera preview that feeds barcode captures to [onDetect].
/// Converted to [StatefulWidget] to safely signal [onCameraReady] via a
/// post-frame callback after the scanner widget is mounted.
class CameraLayer extends StatefulWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onCameraReady;

  const CameraLayer({
    super.key,
    required this.controller,
    required this.onDetect,
    required this.onCameraReady,
  });

  @override
  State<CameraLayer> createState() => CameraLayerState();
}

