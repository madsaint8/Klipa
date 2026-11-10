import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../data/models/scan_state.dart';
import 'corner_painter.dart';
import 'scan_beam.dart';
import 'vignette_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScannerView
//
// Renders the scanner square together with the surrounding dark vignette.
// Both are driven by the same widget so the cutout hole is always pixel-perfect
// aligned with the corner brackets — no separate coordinate guessing.
// ─────────────────────────────────────────────────────────────────────────────

class ScannerView extends StatelessWidget {
  final double size;
  final ScanStatus status;
  final Animation<double> scanLine;
  final Animation<double> pulse;
  final Animation<double> corner;

  const ScannerView({
    super.key,
    required this.size,
    required this.status,
    required this.scanLine,
    required this.pulse,
    required this.corner,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Vignette bleeds outward to screen edges via OverflowBox
          Positioned.fill(
            child: LayoutBuilder(
              builder: (ctx, _) {
                final screen = MediaQuery.of(ctx).size;
                return OverflowBox(
                  minWidth: screen.width,
                  maxWidth: screen.width,
                  minHeight: screen.height,
                  maxHeight: screen.height,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: screen,
                    painter: VignettePainter(
                      scannerSize: size,
                      screenSize: screen,
                    ),
                  ),
                );
              },
            ),
          ),

          // Corner brackets 
          AnimatedBuilder(
            animation: corner,
            builder: (_, __) => CustomPaint(
              size: Size(size, size),
              painter: CornerPainter(
                progress: corner.value,
                color: status == ScanStatus.detected
                    ? AppColors.primary
                    : AppColors.white,
              ),
            ),
          ),

          //  Scan beam 
          if (status == ScanStatus.scanning)
            AnimatedBuilder(
              animation: scanLine,
              builder: (_, __) => Positioned(
                top: (size - 4) * scanLine.value,
                left: 0,
                right: 0,
                child: const ScanBeam(),
              ),
            ),

          // Detected pulse overlay 
          if (status == ScanStatus.detected)
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => Transform.scale(
                scale: pulse.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



