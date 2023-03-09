import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shop/model/items.dart';
import 'package:shop/pages/Inventory_items.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  String _barcode = '';
  late TextEditingController Namecontroller;
  late TextEditingController Categorycontroller;
  late TextEditingController Quantitycontroller;
  late TextEditingController MyPricecontroller;
  late TextEditingController StorePricecontroller;
  late TextEditingController Barcodecontroller;
  @override
  void initState() {
    super.initState();
    Namecontroller = TextEditingController();
    Categorycontroller = TextEditingController();
    Quantitycontroller = TextEditingController();
    MyPricecontroller = TextEditingController();
    StorePricecontroller = TextEditingController();
    Barcodecontroller = TextEditingController();
  }

  @override
  void dispose() {
    Namecontroller.dispose();
    Categorycontroller.dispose();
    Quantitycontroller.dispose();
    MyPricecontroller.dispose();
    StorePricecontroller.dispose();
    Barcodecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: Barcodecontroller,
                decoration: InputDecoration(hintText: "Enter Barcode"),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit_bar(Barcode: Barcodecontroller.text),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "OR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await scancode();
                await searchdata();
                await getdata();
              },
              icon: Icon(Icons.camera),
              label: Text('Scan Item Barcode'),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const inventory_items()),
                );
              },
              icon: Icon(Icons.library_books),
              label: Text('Manage Inventory'),
            ),
            // Text(
            //   "Barcode:$_barcode",
            // ),
          ],
        ),
      ),
    );
  }

  Future additem(Item item) async {
    final db = FirebaseFirestore.instance;
    final docref = db.collection('Inventory').doc(item.barcode);
    final data = item.toJson();
    await docref.set(data);
  }

  Future searchdata() async {
    final db = FirebaseFirestore.instance;
    final docref = db.collection('Inventory').doc(_barcode);
    docref.get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          Namecontroller.text = data['Name'];
          Categorycontroller.text = data['Category'];
          Quantitycontroller.text = data['Quantity'].toString();
          MyPricecontroller.text = data['MyPrice'].toString();
          StorePricecontroller.text = data['StorePrice'].toString();
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future getdata() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Barcode: $_barcode'),
              content: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    autofocus: true,
                    controller: Namecontroller,
                    decoration: InputDecoration(hintText: "Enter Item Name"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    autofocus: true,
                    controller: Categorycontroller,
                    decoration: InputDecoration(hintText: "Enter Category"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    controller: Quantitycontroller,
                    decoration: InputDecoration(hintText: "Enter Quantity"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    controller: MyPricecontroller,
                    decoration: InputDecoration(hintText: "Enter Buying Price"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    controller: StorePricecontroller,
                    decoration: InputDecoration(hintText: "Enter Retail Price"),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: submit,
                  icon: Icon(Icons.check),
                  label: Text('Add'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    cleancontrollers();
                  },
                  icon: Icon(Icons.close),
                  label: Text('Cancel'),
                ),
              ],
            ));
  }

  Future scancode() async {
    String bar = 'unknown';
    try {
      bar = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      print("Platform error");
    }
    setState(() {
      _barcode = bar;
    });
  }

  void submit() {
    final item = Item(
        barcode: _barcode,
        Name: Namecontroller.text,
        Category: Categorycontroller.text,
        Quantity: double.parse(Quantitycontroller.text),
        MyPrice: double.parse(MyPricecontroller.text),
        StorePrice: double.parse(StorePricecontroller.text));
    additem(item);
    Navigator.of(context).pop();
    cleancontrollers();
  }

  Future<void> submit_bar({required String Barcode}) async {
    setState(() {
      _barcode = Barcode;
    });
    await searchdata();
    await getdata();
    submit();
  }

  void cleancontrollers() {
    Namecontroller.clear();
    Quantitycontroller.clear();
    Categorycontroller.clear();
    MyPricecontroller.clear();
    StorePricecontroller.clear();
  }
}
