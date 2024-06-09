import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../models/conversation.dart';
import '../models/message.dart';

import '../pages/conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  const RecentConversationsPage(this._height, this._width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListViewWidget(),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext context) {
        var auth = Provider.of<AuthProvider>(context);
        return SizedBox(
          height: _height,
          width: _width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DBService.instance.getUserConversations(auth.user.uid),
            builder: (context, snashot) {
              var data = snashot.data;
              if (data != null) {
                data.removeWhere((c) {
                  return c.timestamp == null;
                });
                return data.isNotEmpty
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return ConversationPage(
                                        data[index].conversationID,
                                        data[index].id,
                                        data[index].name,
                                        data[index].image);
                                  },
                                ),
                              );
                            },
                            title: Text(data[index].name),
                            subtitle: Text(
                                data[index].type == MessageType.Text
                                    ? data[index].lastMessage
                                    : "Attachment: Image"),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(data[index].image),
                                ),
                              ),
                            ),
                            trailing: _listTileTrailingWidgets(
                                data[index].timestamp),
                          );
                        },
                      )
                    : const Align(
                        child: Text(
                          "No Conversations Yet!",
                          style:
                              TextStyle(color: Colors.white30, fontSize: 15.0),
                        ),
                      );
              } else {
                return const SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Text(
          "Last Message",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(lastMessageTimestamp.toDate()),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
