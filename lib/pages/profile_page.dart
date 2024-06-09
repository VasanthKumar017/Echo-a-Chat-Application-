import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';

import '../models/contact.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;

  late AuthProvider _auth;

  ProfilePage(this._height, this._width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (context, snapshot) {
            var userData = snapshot.data;
            return snapshot.hasData
                ? Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: _height * 0.50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _userImageWidget(userData.image),
                          _userNameWidget(userData.name),
                          _userEmailWidget(userData.email),
                          _logoutButton(),
                        ],
                      ),
                    ),
                  )
                : const SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                  );
          },
        );
      },
    );
  }

  Widget _userImageWidget(String image) {
    double imageRadius = _height * 0.20;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(image),
        ),
      ),
    );
  }

  Widget _userNameWidget(String userName) {
    return SizedBox(
      height: _height * 0.05,
      width: _width,
      child: Text(
        userName,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String email) {
    return SizedBox(
      height: _height * 0.03,
      width: _width,
      child: Text(
        email,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      height: _height * 0.06,
      width: _width * 0.80,
      child: MaterialButton(
        onPressed: () {
          _auth.logoutUser(() {});
        },
        color: Colors.red,
        child: const Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
