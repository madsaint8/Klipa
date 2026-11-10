import 'package:flutter_riverpod/legacy.dart';
import '../controllers/scan_notifier.dart';
import '../data/models/scan_state.dart';

/// Single source of truth for the entire scan-to-pay flow.
/// autoDispose ensures the camera controller is released when the screen pops.
final scanProvider =
    StateNotifierProvider.autoDispose<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(),
);