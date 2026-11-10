import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/payment_payload.dart';
import '../data/models/scan_state.dart';


class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState()) {
    _init();
  }

  /// Exposed so the camera widget can bind to it directly.
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isHandlingDetection = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      state = state.copyWith(status: ScanStatus.scanning);
    } else if (status.isPermanentlyDenied) {
      state = state.copyWith(
        status: ScanStatus.permissionDenied,
        errorMessage:
            'Camera permission is permanently denied. Please enable it in Settings.',
      );
    } else {
      state = state.copyWith(
        status: ScanStatus.permissionDenied,
        errorMessage: 'Camera permission is required to scan QR codes.',
      );
    }
  }

  // Public API 

  void onCameraReady() =>
      state = state.copyWith(cameraInitialized: true);

  /// Called by the [MobileScanner] onDetect callback.
  void onBarcodeDetected(BarcodeCapture capture) {
    if (_isHandlingDetection) return;
    if (state.status != ScanStatus.scanning) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _isHandlingDetection = true;
    HapticFeedback.mediumImpact();

    final payload = PaymentPayload.fromRaw(rawValue);
    state = state.copyWith(status: ScanStatus.detected, payload: payload);
    cameraController.stop();
    _processPayment();
  }

  /// Pick an image from the gallery and attempt to decode a QR code from it.
  Future<void> scanFromGallery() async {
    if (_isHandlingDetection) return;

    // Android 13+ uses READ_MEDIA_IMAGES; older devices use READ_EXTERNAL_STORAGE.
    PermissionStatus photoStatus = await Permission.photos.request();
    if (!photoStatus.isGranted) {
      photoStatus = await Permission.storage.request();
      if (!photoStatus.isGranted) {
        _setError('Photo library permission denied.');
        return;
      }
    }

    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked == null) return;

    final result = await cameraController.analyzeImage(picked.path);
    if (result == null || result.barcodes.isEmpty) {
      _setError('No QR code found in the selected image. Please try another.');
      return;
    }

    final rawValue = result.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) {
      _setError('Could not decode QR code from image.');
      return;
    }

    _isHandlingDetection = true;
    HapticFeedback.mediumImpact();

    final payload = PaymentPayload.fromRaw(rawValue);
    state = state.copyWith(status: ScanStatus.detected, payload: payload);
    cameraController.stop();
    _processPayment();
  }

  Future<void> toggleTorch() async {
    HapticFeedback.lightImpact();
    await cameraController.toggleTorch();
    state = state.copyWith(isTorchOn: !state.isTorchOn);
  }

  Future<void> resetScan() async {
    _isHandlingDetection = false;
    state = const ScanState(
      status: ScanStatus.scanning,
      cameraInitialized: true,
    );
    await cameraController.start();
  }

  Future<void> openSettings() async => openAppSettings();

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _processPayment() async {
    state = state.copyWith(status: ScanStatus.processing);
    //TODO:Replace with  real payment API call 
    await Future.delayed(const Duration(milliseconds: 2200));
    // ─────────────────────────────────────────────────────────────────────
    HapticFeedback.heavyImpact();
    state = state.copyWith(status: ScanStatus.success);
  }

  void _setError(String message) {
    HapticFeedback.vibrate();
    state = state.copyWith(status: ScanStatus.error, errorMessage: message);
    Future.delayed(const Duration(seconds: 3), resetScan);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}