import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateGroupState();
  }
}

class CreateGroupState extends State<CreateGroup>  {
  TextEditingController _textEditingController = new TextEditingController();
  List<bool> _v;
  List<String> _selected = [];
  int _n = 0;
  int _numberAdded = 0;

  _makeGroup()  async{
    final String groupName = _textEditingController.text.trim();
    final DocumentSnapshot doc = await Firestore.instance.collection('0').document('0').get();
    final int groupId = doc['number_of_groups'];
    debugPrint(groupId.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
          Firestore.instance.collection('groupChats').document(groupId.toString()),
          {
            'groupName':  groupName,
            'groupId':  groupId,
            'members': _selected,
            'count':  _numberAdded
          }
      );
    });
    await Firestore.instance.collection('0').document('0').updateData({'number_of_groups': groupId + 1});
    for(var i in _selected) {
      DocumentSnapshot d = await Firestore.instance.collection('users').document(i).get();
      var groups = d['groups']??[];
      groups.add(groupId);
      await Firestore.instance.collection('users').document(i).updateData({'groups': groups});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.lightBlue,
          title: Text(
            'Create Group',
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Group Name',
                      icon: Icon(Icons.group)
                  ),
                  controller: _textEditingController,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Text(
                  'Members',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Flexible(
                child: StreamBuilder(
                  stream: Firestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot)  {
                    if(snapshot.hasData)  {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, i) {
                          DocumentSnapshot doc = snapshot.data.documents[i];
                          if(_n == 0) {
                            _v = [for(var i = 0; i <snapshot.data.documents.length; i++)  false];
                            _n++;
                          }
                          return Card(
                            child: Container(
                              child: CheckboxListTile(
                                onChanged: (value) {
                                  if(value) {
                                    _selected.insert(_numberAdded, doc['id']);
                                    debugPrint(_selected.toString());
                                    _numberAdded++;
                                  }
                                  else  {
                                    _selected.remove(doc['id']);
                                    debugPrint(_selected.toString());
                                    _numberAdded--;
                                  }
                                  setState(() {
                                    _v[i] = value;
                                  });
                                },
                                value: _v[i],
                                secondary: CircleAvatar(
                                  backgroundImage: NetworkImage(doc['photoUrl']),
                                ),
                                title: Text(doc['displayName']),
                              ),
                            ),
                          );
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
                child: FloatingActionButton(
                  child: Icon(Icons.add),
//                  mini: true,
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.black87,
                  onPressed: _makeGroup,
                ),
                margin: EdgeInsets.symmetric(vertical: 10.0),
              )
            ],
          ),
        )
    );
  }
}