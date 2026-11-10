import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/colors/app_colors.dart';
import '../../data/models/scan_state.dart';
import '../../providers/scan_provider.dart';
import 'scan_features/my_qr.dart';
import 'widgets/Cards/payment_overlay.dart';
import 'widgets/bottom_controls/bottom_controls.dart';
import 'widgets/bottom_controls/loading_view.dart';
import 'widgets/camera_layer/camera_layer.dart';
import 'widgets/permissons/permission.dart';
import 'widgets/scanner_viewport/scanner_view.dart';
import 'widgets/status_subtitle/status_subtitle.dart';
import 'widgets/buttons/top_bar.dart';

class ScanToPayScreen extends ConsumerStatefulWidget {
  const ScanToPayScreen({super.key});

  @override
  ConsumerState<ScanToPayScreen> createState() => _ScanToPayScreenState();
}

class _ScanToPayScreenState extends ConsumerState<ScanToPayScreen>
    with TickerProviderStateMixin {
  //  Animation controllers 
  late final AnimationController _scanLineCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _cornerCtrl;
  late final AnimationController _successCtrl;
  late final AnimationController _overlayCtrl;

  //  Animations
  late final Animation<double> _scanLine;
  late final Animation<double> _pulse;
  late final Animation<double> _corner;
  late final Animation<double> _successScale;
  late final Animation<double> _overlayFade;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _cornerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _overlayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scanLine = CurvedAnimation(
      parent: _scanLineCtrl,
      curve: Curves.easeInOut,
    );
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _corner = CurvedAnimation(
      parent: _cornerCtrl,
      curve: Curves.easeOutBack,
    );
    _successScale = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    _cornerCtrl.dispose();
    _successCtrl.dispose();
    _overlayCtrl.dispose();
    super.dispose();
  }

  // Status → animation mapping

  void _onStatusChanged(ScanStatus status) {
    switch (status) {
      case ScanStatus.scanning:
        _scanLineCtrl.repeat(reverse: true);
        _successCtrl.reset();
        _overlayCtrl.reverse();
        break;
      case ScanStatus.processing:
        _scanLineCtrl.stop();
        _overlayCtrl.forward();
        break;
      case ScanStatus.success:
        _successCtrl.forward();
        break;
      case ScanStatus.error:
        _scanLineCtrl.stop();
        _overlayCtrl.forward();
        break;
      default:
        break;
    }
  }

  // Build 

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final notifier = ref.read(scanProvider.notifier);
    final scannerSize = MediaQuery.of(context).size.width * 0.76;

    // Drive animations from state changes.
    ref.listen<ScanState>(scanProvider, (prev, next) {
      if (prev?.status != next.status) _onStatusChanged(next.status);
    });

    final bool cameraVisible =
        state.status != ScanStatus.requestingPermission &&
        state.status != ScanStatus.permissionDenied;

    final bool scannerVisible =
        state.status == ScanStatus.scanning ||
        state.status == ScanStatus.detected;

    final bool overlayVisible =
        state.status == ScanStatus.processing ||
        state.status == ScanStatus.success ||
        state.status == ScanStatus.error;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Camera feed ───────────────────────────────────────────────
            if (cameraVisible)
              CameraLayer(
                controller: notifier.cameraController,
                onDetect: notifier.onBarcodeDetected,
                onCameraReady: notifier.onCameraReady,
              ),

            // Main UI column 
            SafeArea(
              child: Column(
                children: [
                  TopBar(
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 12),
                  StatusSubtitle(status: state.status),
                  const Spacer(flex: 2),

                  // Scanner + vignette
                  if (scannerVisible)
                    ScannerView(
                      size: scannerSize,
                      status: state.status,
                      scanLine: _scanLine,
                      pulse: _pulse,
                      corner: _corner,
                    ),

                  // Permission denied
                  if (state.status == ScanStatus.permissionDenied)
                    PermissionDeniedView(
                      message: state.errorMessage,
                      onOpenSettings: notifier.openSettings,
                    ),

                  // Initialising
                  if (state.status == ScanStatus.requestingPermission)
                    const LoadingView(),

                  const Spacer(flex: 3),

                  // Bottom controls — only shown while actively scanning
                  if (state.status == ScanStatus.scanning)
                    BottomControls(
                      isTorchOn: state.isTorchOn,
                      onTorchToggle: notifier.toggleTorch,
                      onGallery: notifier.scanFromGallery,
                      onMyQr: () => _showMyQrSheet(context),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Processing / Success / Error overlay 
            if (overlayVisible)
              FadeTransition(
                opacity: _overlayFade,
                child: PaymentOverlay(
                  status: state.status,
                  payload: state.payload,
                  errorMessage: state.errorMessage,
                  successScale: _successScale,
                  onDone: () {
                    notifier.resetScan();
                    Navigator.of(context).maybePop();
                  },
                  onRetry: notifier.resetScan,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMyQrSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MyQRCodeScreen(),
    );
  }
}