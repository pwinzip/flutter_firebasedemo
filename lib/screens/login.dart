import 'package:firebasedemo/controller/authentication.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                  (route) => false);
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
}
