import 'dart:io';

import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;

  final String _profileImages = "profile_images";
  final String _messages = "messages";
  final String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<UploadTask> uploadUserImage(String uid, File image) async {
    try {
      return _baseRef
          .child(_profileImages)
          .child(uid)
          .putFile(image);
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<UploadTask> uploadMediaMessage(String uid, File file) async {
    var timestamp = DateTime.now();
    var fileName = basename(file.path);
    fileName += "_${timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName)
          .putFile(file);
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }
}
