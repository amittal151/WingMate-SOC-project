import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>{
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences _preferences;
  FirebaseUser _currentUser;
  bool _isLoggedIn = false;
  bool _isWaiting = false;

  @override
  void initState()  {
    super.initState();
    _initialise();
  }

  void _initialise() async  {
    this.setState(()  {
      _isWaiting = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _isLoggedIn = await _googleSignIn.isSignedIn();
    if(_isLoggedIn) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: _preferences.getString('id')))
      );
    }
    this.setState(()  {
      _isWaiting = false;
    });
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          title: Text(
            "Login Screen",
            style: TextStyle(
                color: Colors.black87
            ),
          ),
        ),
        body: Stack(
            children: <Widget>[
              Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        child: RaisedButton(
                          onPressed: _gSignin,
                          child: Text(
                            "Sign in with Google",
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                          color: Colors.red,
                          padding: EdgeInsets.all(10.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: ButtonTheme(
                          minWidth: 200.0,
                          height: 50.0,
                          child: RaisedButton(
                            onPressed: _gSignout,
                            child: Text(
                              "Sign out of Google",
                              style: TextStyle(
                                  color: Colors.black87
                              ),
                            ),
                            color: Colors.red,
                            padding: EdgeInsets.all(10.0),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              Positioned(
                  child: _isWaiting
                      ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      ),
                    ),
                    color: Colors.white,
                  )
                      : Container()
              )
            ]
        )
    );
  }

  Future<FirebaseUser> _gSignin() async {
    this.setState(()  {
      _isWaiting = true;
    });
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    AuthCredential authCredential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    FirebaseUser firebaseUser = await _auth.signInWithCredential(authCredential);
    debugPrint("Hello ${firebaseUser.displayName}");
    if(firebaseUser != null)  {
      final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if(documents.length == 0) {
        Firestore.instance.collection('users').document(firebaseUser.uid).setData({'displayName': firebaseUser.displayName, 'photoUrl': firebaseUser.photoUrl, 'id': firebaseUser.uid});
        _currentUser = firebaseUser;
        await _preferences.setString('id', _currentUser.uid);
        await _preferences.setString('displayName', _currentUser.displayName);
        await _preferences.setString('photoUrl', _currentUser.photoUrl);
      }
      else {
        await _preferences.setString('id', documents[0]['id']);
        await _preferences.setString('photoUrl', documents[0]['photoUrl']);
        await _preferences.setString('displayName', documents[0]['displayName']);
        await _preferences.setString('about', documents[0]['about']);
        debugPrint("Already on DB ${documents[0]['about']}");
      }
      Fluttertoast.showToast(msg: "Signed in as ${_preferences.getString('displayName')}");
      this.setState(()  {
        _isWaiting = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: _preferences.getString('id')))
      );
    }
    else  {
      Fluttertoast.showToast(msg: "Sign in Failed");
      this.setState(()  {
        _isWaiting = false;
      });
    }
    return firebaseUser;
  }

  _gSignout() {
    _googleSignIn.signOut();
  }
}