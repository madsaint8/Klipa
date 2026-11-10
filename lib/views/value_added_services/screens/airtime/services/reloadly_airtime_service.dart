import 'package:dio/dio.dart';

class ReloadlyAirtimeService {
  final Dio dio;

  ReloadlyAirtimeService(this.dio);

  Future<List<dynamic>> getOperators(
    String countryCode,
    String token,
  ) async {
    final response = await dio.get(
      "https://topups.reloadly.com/operators/countries/$countryCode",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }
}