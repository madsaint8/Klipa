import '../models/operator_model.dart';
import '../services/reloadly_airtime_service.dart';
import '../services/reloadly_auth_service.dart';

class VasRepository {
  final ReloadlyAuthService authService;
  final ReloadlyAirtimeService airtimeService;

  VasRepository({
    required this.authService,
    required this.airtimeService,
  });

  Future<List<OperatorModel>> getOperators(
    String countryCode,
  ) async {
    final token = await authService.getAccessToken();

    final operators =
        await airtimeService.getOperators(
      countryCode,
      token,
    );

    return operators
        .map<OperatorModel>(
          (e) => OperatorModel.fromJson(e),
        )
        .toList();
  }
}