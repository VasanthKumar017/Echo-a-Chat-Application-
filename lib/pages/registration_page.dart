import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';
import '../services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  late AuthProvider _auth;

  late String _name;
  late String _email;
  late String _password;
  late File _image;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext context) {
        SnackBarService.instance.buildContext = context;
        _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: _deviceHeight * 0.75,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(),
              _inputForm(),
              _registerButton(),
              _backToLoginPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return SizedBox(
      height: _deviceHeight * 0.12,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Let's get going!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return SizedBox(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _image != null
                  ? FileImage(_image)
                  : const NetworkImage(
                      "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 ? null : "Please enter a name";
      },
      onSaved: (input) {
        setState(() {
          _name = input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 && input.contains("@")
            ? null
            : "Please enter a valid email";
      },
      onSaved: (input) {
        setState(() {
          _email = input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Email",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 ? null : "Please enter a password";
      },
      onSaved: (input) {
        setState(() {
          _password = input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.authenticating
        ? SizedBox(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _auth.registerUserWithEmailAndPassword(_email, _password,
                      (String uid) async {
                    var result = await CloudStorageService.instance
                        .uploadUserImage(uid, _image);
                    var imageURL = await result.ref.getDownloadURL();
                    await DBService.instance
                        .createUserInDB(uid, _name, _email, imageURL);
                  });
                }
              },
              color: Colors.blue,
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          )
        : const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }

  Widget _backToLoginPageButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: SizedBox(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: const Icon(Icons.arrow_back, size: 40),
      ),
    );
  }
}
