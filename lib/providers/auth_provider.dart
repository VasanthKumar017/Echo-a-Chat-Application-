import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../services/db_service.dart';

enum AuthStatus {
  notAuthenticated,
  authenticating,
  authenticated,
  UserNotFound,
  error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  AuthStatus status = AuthStatus.notAuthenticated;

  final FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider._();

  AuthProvider._() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      status = AuthStatus.notAuthenticated;
      notifyListeners();
    } else {
      user = firebaseUser;
      status = AuthStatus.authenticated;
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      notifyListeners();
      NavigationService.instance.navigateToReplacement("home");
    }
  }

  void loginUserWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      status = AuthStatus.authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user!.email}");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error authenticating");
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(
      String email, String password, Future<void> Function(String uid) onSuccess) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      status = AuthStatus.authenticated;
      await onSuccess(user!.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user!.email}");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error Registering User");
    }
    notifyListeners();
  }

  void logoutUser(Future<void> Function() onSuccess) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.notAuthenticated;
      await onSuccess();
      NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully!");
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Logging Out");
    }
    notifyListeners();
  }
}
