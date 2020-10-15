import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasedemo/controller/authentication.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  Future<void> autoLogin() async {
    try {
      await Firebase.initializeApp();
      SharedPreferences pr = await SharedPreferences.getInstance();
      String uid = pr.getString('uid');
      if (uid != null && uid.isNotEmpty) {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => HomePage(),
        );
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(25),
                  child: GoogleSignInButton(
                      borderRadius: 10,
                      onPressed: () => signInwithGoogle().then((value) {
                            if (value != null) {
                              setPreferencesLogin(
                                  FirebaseAuth.instance.currentUser);
                              MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => HomePage(),
                              );
                              Navigator.of(context)
                                  .pushAndRemoveUntil(route, (route) => false);
                            }
                          })

                      // .then((value) {
                      //   if (value != null) {
                      //     print(value);
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => HomePage(account: value),
                      //       ),
                      //     );
                      //   }
                      // }),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setPreferencesLogin(User currentUser) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('uid', currentUser.uid);
    preferences.setString('displayName', currentUser.displayName);
  }
}
