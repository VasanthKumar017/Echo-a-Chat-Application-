import 'package:flutter/material.dart';

class NavigationService {
  late final GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _routeName) async {
    return await navigatorKey.currentState!.pushReplacementNamed(_routeName);
  }

  Future<dynamic> navigateTo(String _routeName) async {
    return await navigatorKey.currentState!.pushNamed(_routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) async {
    return await navigatorKey.currentState!.push(_route);
  }

  void goBack() {
    navigatorKey.currentState!.pop();
  }
}
