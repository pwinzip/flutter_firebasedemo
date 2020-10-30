import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasedemo/screens/login.dart';
import 'package:firebasedemo/screens/uploadimage.dart';
import 'package:flutter/material.dart';
import 'package:firebasedemo/controller/authentication.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebasedemo/screens/managefood.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final User user = FirebaseAuth.instance.currentUser;
  String uid;
  String uname;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    findUserPreference();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> findUserPreference() async {
    await Firebase.initializeApp();
    SharedPreferences pre = await SharedPreferences.getInstance();
    setState(() {
      uid = pre.getString('uid');
      uname = pre.getString('displayName');
    });
  }

  Future<void> signOutPage() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.clear();
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome $uname"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => googleSignOut().whenComplete(() {
                signOutPage();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => SignInPage(),
                    ),
                    (route) => false);
              }),
            )
          ],
        ),
        body: Builder(
          builder: (context) {
            return Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  buildMenuList(context),
                  Container(
                    child: IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          MaterialPageRoute route = MaterialPageRoute(
                            builder: (context) => UploadImage(),
                          );
                          Navigator.push(context, route);
                        }),
                  )
                  // buildMenuListByType(),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => ManageFood(action: 'add'),
            );
            Navigator.push(context, route);
          },
        ),
      ),
    );
  }

  AlertDialog buildDeleteDialog(document, BuildContext context) {
    return AlertDialog(
      title: Text(
        'ลบรายการอาหาร !!',
        style: TextStyle(color: Colors.red),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('คุณต้องการลบรายการอาหาร ${document['food_name']}'),
          ],
        ),
      ),
      actions: [
        RaisedButton(
          child: Text(
            'ยกเลิก',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Colors.lightBlue[600],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RaisedButton(
            child: Text(
              'ลบรายการ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.red[600],
            onPressed: () {
              // delete item from Firebase
              deleteFood(document.id);
              Navigator.of(context).pop();
              _showSnackBar(context, 'ลบรายการอาหารแล้ว');
            })
      ],
    );
  }

  Widget buildMenuList(BuildContext context) {
    print(searchController.text);
    return StreamBuilder(
      stream: (searchController.text.trim().isNotEmpty &&
              searchController.text != null)
          ? FirebaseFirestore.instance
              .collection('Foods')
              .where('food_name', isGreaterThan: searchController.text)
              .snapshots()
          : FirebaseFirestore.instance.collection('Foods').snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot data = snapshot.data.docs[index];
                  return makeSearchList(data);
                },
              ),
            );
        }
      },
    );
  }

  Slidable makeSearchList(DocumentSnapshot data) {
    Map<String, dynamic> d = data.data();
    return Slidable(
      child: Container(
        child: ListTile(
          title: Text(d['food_name']),
          subtitle: Text(d['price'].toString()),
          onTap: () {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => ManageFood(
                action: 'edit',
                item: data.id,
              ),
            );
            Navigator.push(context, route);
          },
        ),
      ),
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          // when onTap should be show alertDialog when tap on delete show snackbar
          onTap: () {
            AlertDialog dialog = buildDeleteDialog(d, context);
            showDialog(
              context: context,
              builder: (context) => dialog,
            );
          },
        ),
      ],
    );
  }

  List<Widget> findAllMenu(BuildContext context, AsyncSnapshot snapshot) {
    return snapshot.data.docs.map<Widget>((document) {
      return Slidable(
        child: Container(
          child: ListTile(
            title: Text(document['food_name']),
            subtitle: Text(document['price'].toString()),
            onTap: () {
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => ManageFood(
                  action: 'edit',
                  item: document.id,
                ),
              );
              Navigator.push(context, route);
            },
          ),
        ),
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            // when onTap should be show alertDialog when tap on delete show snackbar
            onTap: () {
              AlertDialog dialog = buildDeleteDialog(document, context);
              showDialog(
                context: context,
                builder: (context) => dialog,
              );
            },
          ),
        ],
      );
    }).toList();
  }

  Widget buildMenuListByType() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('FoodTypes')
          .doc('ตำ')
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
            break;
          default:
            return Column(
              children: makeFoodList(snapshot),
            );
        }
      },
    );
  }

  List<Widget> makeFoodList(AsyncSnapshot snapshot) {
    List<Widget> alist = [];
    Map<String, dynamic> data = snapshot.data.data();
    for (var key in data.keys) {
      alist.add(ListTile(
        title: Text(key),
      ));
    }
    return alist;
  }

  Future<void> deleteFood(id) async {
    await FirebaseFirestore.instance.collection('Foods').doc(id).delete();
  }

  // Widget buildMenuList(BuildContext context) {
  //   return FutureBuilder(
  //     future: FirebaseFirestore.instance.collection('Foods').get(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done)
  //         return Column(
  //           children: findAllMenu(context, snapshot),
  //         );
  //       else
  //         return CircularProgressIndicator();
  //     },
  //   );
  // }

}
