import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_error.dart';

class ErrorMapper {
  static AppError map(dynamic error) {
    // Supabase auth errors
    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return const AppError(
          type: AppErrorType.auth,
          title: 'Login Failed',
          message:
              'The email address or password you entered is incorrect.',
        );
      }

      if (msg.contains('email not confirmed')) {
        return const AppError(
          type: AppErrorType.auth,
          title: 'Email Verification Required',
          message:
              'Please verify your email address before signing in.',
        );
      }

      if (msg.contains('rate limit')) {
        return const AppError(
          type: AppErrorType.auth,
          title: 'Too Many Attempts',
          message:
              'Too many sign-in attempts detected. Please try again later.',
        );
      }
    }

    final text = error.toString().toLowerCase();

    if (text.contains('socketexception')) {
      return const AppError(
        type: AppErrorType.network,
        title: 'No Internet Connection',
        message:
            'Please check your internet connection and try again.',
      );
    }

    return const AppError(
      type: AppErrorType.unknown,
      title: 'Something Went Wrong',
      message:
          'Klipa encountered an unexpected error. Please try again.',
    );
  }
}