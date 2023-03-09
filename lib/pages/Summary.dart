import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  double cash = 0;

  double gpay = 0;

  double phonepe = 0;

  double paytm = 0;

  double profit = 0;

  int bills = 0;

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Cash',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$cash',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PayTM',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$paytm',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PhonePe',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$phonepe',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'GPay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$gpay',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Profit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$profit',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sale',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$bills',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getdata() async {
    final init = {
      'GPay': 0,
      'PhonePe': 0,
      'Cash': 0,
      'PayTM': 0,
      'Bills': 0,
      'Profit': 0
    };
    final values = {
      'GPay': 0,
      'PhonePe': 0,
      'Cash': 0,
      'PayTM': 0,
      'Bills': 0,
      'Profit': 0
    };
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    final doc = await FirebaseFirestore.instance.collection('Bill').doc(date);
    await doc.get().then((value) {
      if (!value.exists) {
        doc.set(init);
      } else {
        final data = value.data() as Map<String, dynamic>;
        setState(() {
          gpay = data['GPay'].toDouble();
          phonepe = data['PhonePe'].toDouble();
          cash = data['Cash'].toDouble();
          bills = int.parse(data['Bills'].toString());
          paytm = data['PayTM'].toDouble();
          profit = data['Profit'].toDouble();
        });
      }
    });
  }
}
