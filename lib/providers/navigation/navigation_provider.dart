import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider =
    Provider<NavigationService>((ref) => NavigationService());

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<dynamic> pushNamed(String route) {
    return navigatorKey.currentState!.pushNamed(route);
  }

  void pop() {
    navigatorKey.currentState!.pop();
  }
}