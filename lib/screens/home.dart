import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebasedemo/controller/authentication.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome ${user.displayName}"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => googleSignOut().whenComplete(() => {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ),
                        (route) => false)
                  }),
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  '${user.photoURL}',
                ),
                SizedBox(
                  height: 16,
                ),
                buildCard("Display Name: ${user.displayName}"),
                buildCard("Email: ${user.email}"),
                buildCard("Last Sign In: ${user.metadata.lastSignInTime}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card buildCard(String str) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              str,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
