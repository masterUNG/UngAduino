import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ungaduino/utility/my_style.dart';

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  // Field
  String despt, qrCode;
  int status;
  bool statusQRcode = true;

  // Method

  @override
  void initState() {
    super.initState();
    readDataThread();
  }

  Future<void> readDataThread() async {
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference databaseReference = firebaseDatabase
        .reference()
        .child('Line_01')
        .child('System')
        .child('Mobile');
    await databaseReference.once().then((DataSnapshot dataSnapshot) {
      // print('dataSnapshot ===>>> ${dataSnapshot.value}');
      Map<dynamic, dynamic> map = dataSnapshot.value;
      setState(() {
        despt = map['despt'];
        status = map['status'];
        if (statusQRcode) {
          qrAndBarCode();
        }
      });
      myDuration();
    });
  }

  Future<void> qrAndBarCode() async {
    if (status == 3) {
      statusQRcode = false;
      print('Open Scan');

      try {
        qrCode = await BarcodeScanner.scan();
        print('qrCode = $qrCode');
        editValueToFirebase(qrCode);
      } catch (e) {}
    }
  }

  Future<void> editValueToFirebase(String newDespt) async {
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference databaseReference = firebaseDatabase
        .reference()
        .child('Line_01')
        .child('System')
        .child('Mobile');

    Map<String, dynamic> map = Map();
    map['despt'] = newDespt;
    map['status'] = 4;

    await databaseReference.update(map).then((response) {
      statusQRcode = true;
    });
  }

  Future<void> myDuration() async {
    Duration duration = Duration(seconds: 3);
    Timer(duration, () {
      return readDataThread();
    });
  }

  @override
  void dispose() {
    super.dispose();
    readDataThread();
  }

  Widget showProgress() {
    return CircularProgressIndicator();
  }

  Widget showDespt() {
    if (despt == null) {
      despt = '';
    }
    return Text(
      'Despt : $despt',
      style: MyStyle().h2TextStyle,
    );
  }

  Widget showStatus() {
    if (status == null) {
      status = 0;
    }
    return Text(
      'Status : $status',
      style: MyStyle().h1TextStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.purple.shade800,
        title: Text('Monitor'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, -1.0),
            end: Alignment(0.0, 1.0),
            colors: <Color>[Colors.white, Colors.purple.shade800],
          ),
        ),
        child: Center(
          child: despt == null ? showProgress() : showContent(),
        ),
      ),
    );
  }

  Widget showContent() {
    return Card(
      color: Colors.lime.shade300,
      child: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showDespt(),
            showStatus(),
          ],
        ),
      ),
    );
  }
}
