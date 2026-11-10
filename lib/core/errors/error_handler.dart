import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}