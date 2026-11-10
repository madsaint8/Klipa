enum AppErrorType {
  auth,
  network,
  validation,
  database,
  wallet,
  transaction,
  server,
  unknown,
}

class AppError implements Exception {
  final AppErrorType type;
  final String title;
  final String message;

  const AppError({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  String toString() => message;
}