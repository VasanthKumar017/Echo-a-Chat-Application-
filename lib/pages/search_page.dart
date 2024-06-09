import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../pages/conversation_page.dart';

import '../models/contact.dart';

class SearchPage extends StatefulWidget {
  late final double _height;
  late final double _width;

  const SearchPage(this._height, this._width, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  late String _searchText;

  late AuthProvider _auth;

  _SearchPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _userSearchField(),
            _usersListView(),
          ],
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      height: widget._height * 0.08,
      width: widget._width,
      padding: EdgeInsets.symmetric(vertical: widget._height * 0.02),
      child: TextField(
        autocorrect: false,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (input) {
          setState(() {
            _searchText = input;
          });
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (context, snapshot) {
        var usersData = snapshot.data;
        if (usersData != null) {
          usersData.removeWhere((contact) => contact.id == _auth.user.uid);
        }
        return snapshot.hasData
            ? SizedBox(
                height: widget._height * 0.75,
                child: ListView.builder(
                  itemCount: usersData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var userData = usersData[index];
                    var currentTime = DateTime.now();
                    var recepientID = usersData[index].id;
                    var isUserActive = !userData.lastseen.toDate().isBefore(
                          currentTime.subtract(
                            const Duration(hours: 1),
                          ),
                        );
                    return ListTile(
                      onTap: () {
                        DBService.instance.createOrGetConversartion(
                            _auth.user.uid, recepientID,
                            (String conversationID) {
                          NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(builder: (context) {
                              return ConversationPage(
                                  conversationID,
                                  recepientID,
                                  userData.name,
                                  userData.image);
                            }),
                          );
                        });
                      },
                      title: Text(userData.name),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userData.image),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          isUserActive
                              ? const Text(
                                  "Active Now",
                                  style: TextStyle(fontSize: 15),
                                )
                              : const Text(
                                  "Last Seen",
                                  style: TextStyle(fontSize: 15),
                                ),
                          isUserActive
                              ? Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : Text(
                                  timeago.format(
                                    userData.lastseen.toDate(),
                                  ),
                                  style: const TextStyle(fontSize: 15),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
      },
    );
  }
}
