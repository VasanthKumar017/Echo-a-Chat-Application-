import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DBService {
  static DBService instance = DBService();

  final FirebaseFirestore _db;

  DBService() : _db = FirebaseFirestore.instance;

  final String _userCollection = "Users";
  final String _conversationsCollection = "Conversations";

  Future<void> createUserInDB(
      String uid, String name, String email, String imageURL) async {
    try {
      await _db.collection(_userCollection).doc(uid).set({
        "name": name,
        "email": email,
        "image": imageURL,
        "lastSeen": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> updateUserLastSeenTime(String userID) async {
    var ref = _db.collection(_userCollection).doc(userID);
    try {
      await ref.update({"lastSeen": FieldValue.serverTimestamp()});
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> sendMessage(String conversationID, Message message) async {
    var ref = _db.collection(_conversationsCollection).doc(conversationID);
    var messageType = message.type == MessageType.Text ? "text" : "image";
    try {
      await ref.update({
        "messages": FieldValue.arrayUnion([
          {
            "message": message.content,
            "senderID": message.senderID,
            "timestamp": FieldValue.serverTimestamp(),
            "type": messageType,
          },
        ]),
      });
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Future<void> createOrGetConversation(String currentID, String recepientID,
      Future<void> Function(String conversationID) onSuccess) async {
    var ref = _db.collection(_conversationsCollection);
    var userConversationRef = _db
        .collection(_userCollection)
        .doc(currentID)
        .collection(_conversationsCollection);
    try {
      var conversation = await userConversationRef.doc(recepientID).get();
      if (conversation.exists) {
        return onSuccess(conversation.data()!["conversationID"]);
      } else {
        var conversationRef = ref.doc();
        await conversationRef.set(
          {
            "members": [currentID, recepientID],
            "ownerID": currentID,
            'messages': [],
          },
        );
        return onSuccess(conversationRef.id);
      }
    } catch (e) {
      print(e);
      rethrow; // Re-throw the error for higher-level handling
    }
  }

  Stream<Contact> getUserData(String userID) {
    var ref = _db.collection(_userCollection).doc(userID);
    return ref.snapshots().map((snapshot) {
      return Contact.fromFirestore(snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String userID) {
    var ref = _db
        .collection(_userCollection)
        .doc(userID)
        .collection(_conversationsCollection);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationSnippet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String searchName) {
    var ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: searchName)
        .where("name", isLessThan: '${searchName}z');
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var ref =
        _db.collection(_conversationsCollection).doc(conversationID);
    return ref.snapshots().map(
      (doc) {
        return Conversation.fromFirestore(doc);
      },
    );
  }
}
