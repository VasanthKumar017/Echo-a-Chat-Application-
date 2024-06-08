import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DBService {
  static DBService instance = DBService();

  FirebaseFirestore _db;

  DBService() : _db = FirebaseFirestore.instance;

  String _userCollection = "Users";
  String _conversationsCollection = "Conversations";

  Future<void> createUserInDB(
      String _uid, String _name, String _email, String _imageURL) async {
    try {
      await _db.collection(_userCollection).doc(_uid).set({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastSeen": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> updateUserLastSeenTime(String _userID) async {
    var _ref = _db.collection(_userCollection).doc(_userID);
    try {
      await _ref.update({"lastSeen": FieldValue.serverTimestamp()});
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> sendMessage(String _conversationID, Message _message) async {
    var _ref = _db.collection(_conversationsCollection).doc(_conversationID);
    var _messageType = _message.type == MessageType.Text ? "text" : "image";
    try {
      await _ref.update({
        "messages": FieldValue.arrayUnion([
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": FieldValue.serverTimestamp(),
            "type": _messageType,
          },
        ]),
      });
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> createOrGetConversation(String _currentID, String _recepientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationsCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .doc(_currentID)
        .collection(_conversationsCollection);
    try {
      var conversation = await _userConversationRef.doc(_recepientID).get();
      if (conversation.exists) {
        return _onSuccess(conversation.data()!["conversationID"]);
      } else {
        var _conversationRef = _ref.doc();
        await _conversationRef.set(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            'messages': [],
          },
        );
        return _onSuccess(_conversationRef.id);
      }
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.snapshots().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .doc(_userID)
        .collection(_conversationsCollection);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String _conversationID) {
    var _ref =
        _db.collection(_conversationsCollection).doc(_conversationID);
    return _ref.snapshots().map(
      (_doc) {
        return Conversation.fromFirestore(_doc);
      },
    );
  }
}
