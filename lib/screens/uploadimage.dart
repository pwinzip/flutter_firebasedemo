import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final picker = ImagePicker();
  File _image;

  Future getImage() async {
    print('getImage');
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image != null) {
      print('upload Image');
      String fileName = Path.basename(_image.path);
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      StorageUploadTask storageUploadTask = storageReference.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then((value) async {
        print(value);
        await FirebaseFirestore.instance.collection('Images').add({
          'url': value,
        });
        setState(() {
          _image = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: RaisedButton(
                  onPressed: getImage,
                  child: Text('Choose Image'),
                ),
              )
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green[300],
            ),
            height: 200,
            width: 500,
            child: _image == null
                ? Center(
                    child: Text('No Image'),
                  )
                : Center(
                    child: Image.file(_image),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: RaisedButton(
                  onPressed: uploadImage,
                  child: Text('Upload Image'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
