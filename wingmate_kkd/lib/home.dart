import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat.dart';
import 'create.dart';
//import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String _currentUserId;

  HomeScreen({
    Key key, @required String currentUserId
  }): _currentUserId = currentUserId, super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState(currentUserId: _currentUserId);
  }
}

class HomeScreenState extends State<HomeScreen> {
  final String _currentUserId;

  final drawerItems = ListView(
    children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text("Username"),
        accountEmail: Text("User E-mail"),
      ),
//      ListTile(
//
//        title : Text("Chats"),
//        onTap : () => debugPrint("Chats"),
//      ),
//      ListTile(
//        title : Text("Group chats"),
//        leading: Icon(Icons.group),
//        onTap :() => debugPrint("Group Chats"),
//      ),
//      ListTile(
//        title : Text("Private chats"),
//        leading: Icon(Icons.person),
//        onTap :() => debugPrint("Private Chats"),
//      ),
//      ListTile(
//        title : Text("Sign Out"),
//        leading: Icon(Icons.remove_circle),
//        onTap : () => debugPrint("Sign Out"),
//      ),
    Card(
      color: Colors.blueAccent,
      child: ListTile(
        title: Text("Chats", style: TextStyle(color: Colors.white)),
        leading: Icon(Icons.chat),
      )
    ),
    Card(
        child: ListTile(
          title: Text("Group Chats"),
          leading: Icon(Icons.group),
        )
    ),
    Card(
        child: ListTile(
          title: Text("Private Chats"),
          leading: Icon(Icons.person),
        )
    ),
      Card(
          color: Colors.blueAccent,
          child: ListTile(
            title: Text("Events", style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.event),
          )
      ),
    Card(
        color: Colors.red,
        child: ListTile(
          title: Text("Sign Out", style: TextStyle(color: Colors.white)),
          leading: Icon(Icons.remove_circle, color: Colors.white,),
        )
    ),

    ]
    );

  HomeScreenState({
    Key key, @required String currentUserId
  }): _currentUserId = currentUserId;

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.group_add),
            onPressed: () {
              debugPrint("Create Group");
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroup())
              );
            },            //  Add Group Creation here
          ),
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {debugPrint("User Settings");},            //  Add User Options here
          )
        ],
        backgroundColor: Colors.lightBlue,
        // centerTitle: true,
        title: Text(
            'Wingmate',
            style: TextStyle(
              color: Colors.white,
            )
        ),
      ),
      drawer: Drawer(
        child: drawerItems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => debugPrint("All Chats"),
        tooltip: 'All Chats',
        child: Icon(Icons.message),
        backgroundColor: Colors.blue,
      ),
//      bottomNavigationBar: new BottomNavigationBar(
//        backgroundColor: Colors.lightBlueAccent,
//        elevation: 10.0,
//        items: [
//          new BottomNavigationBarItem(icon: new Icon(Icons.chat_bubble), title: new Text("Chats",)),
//          new BottomNavigationBarItem(icon: new Icon(Icons.event), title: new Text("Events")),
//          new BottomNavigationBarItem(icon: new Icon(Icons.music_note), title: new Text("Group Play")),
//        ], onTap: (int i){
//        if(i==1) Navigator.pushReplacementNamed(context, '/events_sl');
//        else if(i==2) Navigator.pushReplacementNamed(context, '/group_play_sl');
//      },),
      body: Stack(
        children: <Widget>[
          Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('groupChats').snapshots(),
              builder: (context, snapshot)  {
                if(snapshot.hasData)  {
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      DocumentSnapshot doc = snapshot.data.documents[i];
                      debugPrint(doc.data.toString());
                      if(doc['members'].contains(_currentUserId)) {
                        return Card(
                          color: Colors.lightBlue,
                          child: ListTile(
                            title: Text(
                              doc['groupName'],
                              style: TextStyle(
                                  color: Colors.black87
                                // fontWeight: FontWeight.w600
                              ),
                            ),
                            onTap: () {
                              debugPrint("Tapped");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatScreen(peerId: doc['groupId'].toString(), peerName: doc['groupName'], type: 'groupChats'))
                              );
                            },
                          ),
                        );
                      }
                      else  {
                        return Container();
                      }
                    },
                  );
                }
                else  {
                  return Container();
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 100.0),
            child: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot)  {
                if(snapshot.hasData){
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      DocumentSnapshot doc = snapshot.data.documents[i];
                      if(doc['id'] != _currentUserId) {
                        return Card(
                            color: Colors.lightBlue,
                            child: ListTile(
                              title: Text(
                                doc['displayName'],
                                style: TextStyle(
                                    color: Colors.black87
                                ),
                              ),
                              onTap: () {
                                debugPrint("Tapped");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatScreen(peerId: doc['id'], peerName: doc['displayName'], peerImg: doc['photoUrl'], type: '2pChats'))
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(doc['photoUrl']),
                              ),
                              subtitle: Text(
                                  doc['about']??'NA',
                                  style: TextStyle(
                                      color: Colors.black87
                                  )
                              ),
                            )
                        );
                      }
                      else  {
                        return Container();
                      }
                    },
                    padding: EdgeInsets.all(8.0),
                  );
                }
                else  {
                  return Container();
                }
              },
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[FloatingActionButton(
          //     onPressed: null,
          //     backgroundColor: Colors.lightBlue,
          //     child: Icon(Icons.group_add),
          //   )]
          // )
        ],
      ),
    );
  }
}