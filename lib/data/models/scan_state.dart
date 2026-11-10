import 'payment_payload.dart';

enum ScanStatus {
  requestingPermission,
  permissionDenied,
  scanning,
  detected,
  processing,
  success,
  error,
}

class ScanState {
  final ScanStatus status;
  final PaymentPayload? payload;
  final String? errorMessage;
  final bool isTorchOn;
  final bool cameraInitialized;

  const ScanState({
    this.status = ScanStatus.requestingPermission,
    this.payload,
    this.errorMessage,
    this.isTorchOn = false,
    this.cameraInitialized = false,
  });

  ScanState copyWith({
    ScanStatus? status,
    PaymentPayload? payload,
    String? errorMessage,
    bool? isTorchOn,
    bool? cameraInitialized,
  }) =>
      ScanState(
        status: status ?? this.status,
        payload: payload ?? this.payload,
        errorMessage: errorMessage ?? this.errorMessage,
        isTorchOn: isTorchOn ?? this.isTorchOn,
        cameraInitialized: cameraInitialized ?? this.cameraInitialized,
      );
}