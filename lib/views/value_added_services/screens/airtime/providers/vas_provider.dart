import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../repositories/vas_repository.dart';
import '../services/reloadly_airtime_service.dart';
import '../services/reloadly_auth_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final vasRepositoryProvider =
    Provider<VasRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return VasRepository(
    authService: ReloadlyAuthService(dio),
    airtimeService: ReloadlyAirtimeService(dio),
  );
});