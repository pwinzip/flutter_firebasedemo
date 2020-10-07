import 'package:cloud_firestore/cloud_firestore.dart';
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
        body: realTimeRead("2"),
        // oneTimeRead("2"),
        // oneTimeFood(),
        // realTimeFood(),
        // Center(
        //   child: SingleChildScrollView(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         oneTimeFood(),
        //         // Image.network(
        //         //   '${user.photoURL}',
        //         // ),
        //         // SizedBox(
        //         //   height: 16,
        //         // ),
        //         // buildCard("Display Name: ${user.displayName}"),
        //         // buildCard("Email: ${user.email}"),
        //         // buildCard("Last Sign In: ${user.metadata.lastSignInTime}"),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Widget realTimeFood() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Foods").snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return ListView(
              children: makeListWidget(snapshot),
            );
        }
      },
    );
  }

  List<Widget> makeListWidget(AsyncSnapshot snapshot) {
    return snapshot.data.docs.map<Widget>((document) {
      return ListTile(
        title: Text(document['food_name']),
        subtitle: Text(document['price'].toString()),
      );
    }).toList();
  }

  Widget oneTimeFood() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection("Foods").get(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return ListView(
              children: makeListWidget(snapshot),
            );
        }
      },
    );
  }

  oneTimeRead(String s) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("Foods").doc(s).get(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return ListTile(
              title: Text(snapshot.data.data()['food_name']),
              subtitle: Text(snapshot.data.data()['price'].toString()),
            );
        }
      },
    );
  }

  realTimeRead(String s) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Foods").doc(s).snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return ListTile(
              title: Text(snapshot.data.data()['food_name']),
              subtitle: Text(snapshot.data.data()['price'].toString()),
            );
        }
      },
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
