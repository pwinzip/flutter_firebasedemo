import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFood extends StatefulWidget {
  final String action;
  final String item;

  const ManageFood({Key key, this.action, this.item}) : super(key: key);
  @override
  _ManageFoodState createState() => _ManageFoodState();
}

class _ManageFoodState extends State<ManageFood> {
  TextEditingController _foodNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _foodTypeController = TextEditingController();

  String _chooseItem;

  @override
  void initState() {
    super.initState();
    _chooseItem = 'ตำ';
    checkAction();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _foodNameController.dispose();
    _priceController.dispose();
    _foodTypeController.dispose();
    super.dispose();
  }

  Future<void> checkAction() async {
    if (widget.action == 'edit') {
      await FirebaseFirestore.instance
          .collection('Foods')
          .doc(widget.item)
          .get()
          .then((value) {
        setState(() {
          _foodNameController =
              TextEditingController(text: value.data()['food_name']);
          _priceController =
              TextEditingController(text: value.data()['price'].toString());
          // _foodTypeController =
          //     TextEditingController(text: value.data()['type']);
          _chooseItem = value.data()['type'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.action == 'add' ? 'เพิ่มรายการอาหาร' : 'แก้ไขรายการอาหาร'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    makeTextField(_foodNameController, 'ชื่ออาหาร',
                        Icons.restaurant_menu),
                    makeTextField(_priceController, 'ราคา', Icons.local_offer),
                    makeDropDownType(),
                    // Text(_chooseItem),
                    // makeTextField(
                    //     _foodTypeController, 'ประเภท', Icons.menu_book),
                    Container(
                      width: 250,
                      child: RaisedButton.icon(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if (widget.action == 'add') {
                            print('In add');
                            addFood();
                          } else if (widget.action == 'edit') {
                            print('In edit');
                            editFood(widget.item);
                          }
                        },
                        icon: Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                        ),
                        label: Text(
                          'บันทึก',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget makeTextField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          labelText: label,
          icon: Icon(icon),
        ),
      ),
    );
  }

  Future<void> addFood() async {
    await FirebaseFirestore.instance.collection('Foods').add({
      'food_name': _foodNameController.text,
      'price': int.parse(_priceController.text),
      'type': _foodTypeController.text,
    }).whenComplete(() => Navigator.of(context).pop());
  }

  Future<void> editFood(String doc) async {
    await FirebaseFirestore.instance.collection('Foods').doc(doc).update({
      'food_name': _foodNameController.text,
      'price': int.parse(_priceController.text),
      'type': _foodTypeController.text,
    }).whenComplete(() => Navigator.of(context).pop());
  }

  Widget makeDropDownType() {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      width: 300,
      child: Center(
        child: DropdownButton(
          onChanged: (value) {
            setState(() {
              _chooseItem = value;
            });
          },
          value: _chooseItem,
          items: [
            DropdownMenuItem(
              child: Text("ตำ"),
              value: 'ตำ',
            ),
            DropdownMenuItem(
              child: Text("ย่าง"),
              value: 'ย่าง',
            ),
            DropdownMenuItem(
              child: Text("ลาบ/น้ำตก"),
              value: 'ลาบ_น้ำตก',
            ),
          ],
        ),
      ),
    );
  }
}
