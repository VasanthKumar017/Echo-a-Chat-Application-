import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final String _conversationID;
  final String _receiverID;
  final String _receiverImage;
  final String _receiverName;

  const ConversationPage(this._conversationID, this._receiverID, this._receiverName,
      this._receiverImage, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  late ScrollController _listViewController;
  late AuthProvider _auth;

  late String _messageText;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget._receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return Stack(
          clipBehavior: Clip.none, children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return SizedBox(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget._conversationID),
        builder: (BuildContext context, snapshot) {
          Timer(
            const Duration(milliseconds: 50),
            () {
              _listViewController
                  .jumpTo(_listViewController.position.maxScrollExtent);
            },
          );
          var conversationData = snapshot.data;
          if (conversationData != null) {
            if (conversationData.messages.isNotEmpty) {
              return ListView.builder(
                controller: _listViewController,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: conversationData.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  var message = conversationData.messages[index];
                  bool isOwnMessage = message.senderID == _auth.user.uid;
                  return _messageListViewChild(isOwnMessage, message);
                },
              );
            } else {
              return const Align(
                alignment: Alignment.center,
                child: Text("Let's start a conversation!"),
              );
            }
          } else {
            return const SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          message.type == MessageType.Text
              ? _textMessageBubble(
                  isOwnMessage, message.content, message.timestamp)
              : _imageMessageBubble(
                  isOwnMessage, message.content, message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double imageRadius = _deviceHeight * 0.05;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget._receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool isOwnMessage, String message, Timestamp timestamp) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [const Color.fromRGBO(69, 69, 69, 1), const Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _deviceHeight * 0.08 + (message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(message),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool isOwnMessage, String imageURL, Timestamp timestamp) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [const Color.fromRGBO(69, 69, 69, 1), const Color.fromRGBO(43, 43, 43, 1)];
    DecorationImage image =
        DecorationImage(image: NetworkImage(imageURL), fit: BoxFit.cover);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: image,
            ),
          ),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (input) {
          if (input.length == 0) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (input) {
          _formKey.currentState.save();
        },
        onSaved: (input) {
          setState(() {
            _messageText = input;
          });
        },
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context) {
    return SizedBox(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
          icon: const Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              DBService.instance.sendMessage(
                widget._conversationID,
                Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    type: MessageType.Text),
              );
              _formKey.currentState.reset();
              FocusScope.of(context).unfocus();
            }
          }),
    );
  }

  Widget _imageMessageButton() {
    return SizedBox(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var image = await MediaService.instance.getImageFromLibrary();
          var result = await CloudStorageService.instance
              .uploadMediaMessage(_auth.user.uid, image);
          var imageURL = await result.ref.getDownloadURL();
          await DBService.instance.sendMessage(
            widget._conversationID,
            Message(
                content: imageURL,
                senderID: _auth.user.uid,
                timestamp: Timestamp.now(),
                type: MessageType.Image),
          );
        },
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
