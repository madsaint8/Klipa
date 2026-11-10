import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import 'camera_layer.dart';

class CameraLayerState extends State<CameraLayer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCameraReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: widget.controller,
      onDetect: widget.onDetect,
      // mobile_scanner ^5.x — errorBuilder has no child parameter
      errorBuilder: (context, error) => ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.white40,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera unavailable\n${error.errorCode}',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      fit: BoxFit.cover,
    );
  }
}