import 'dart:io';

import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;

  String _profileImages = "profile_images";
  String _messages = "messages";
  String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<UploadTask> uploadUserImage(String _uid, File _image) async {
    try {
      return _baseRef
          .child(_profileImages)
          .child(_uid)
          .putFile(_image);
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<UploadTask> uploadMediaMessage(String _uid, File _file) async {
    var _timestamp = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += "_${_timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file);
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }
}
