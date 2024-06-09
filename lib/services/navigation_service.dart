import 'package:flutter/material.dart';

class NavigationService {
  late final GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String routeName) async {
    return await navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateTo(String routeName) async {
    return await navigatorKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) async {
    return await navigatorKey.currentState!.push(route);
  }

  void goBack() {
    navigatorKey.currentState!.pop();
  }
}
