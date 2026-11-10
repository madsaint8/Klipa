import 'package:dio/dio.dart';

class ReloadlyAuthService {
  final Dio dio;

  ReloadlyAuthService(this.dio);

  Future<String> getAccessToken() async {
    final response = await dio.post(
      "https://auth.reloadly.com/oauth/token",
      data: {
        "client_id": "YOUR_CLIENT_ID",
        "client_secret": "YOUR_CLIENT_SECRET",
        "grant_type": "client_credentials",
        "audience":
            "https://topups.reloadly.com",
      },
    );

    return response.data["access_token"];
  }
}