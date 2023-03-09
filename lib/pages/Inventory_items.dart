import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shop/model/items.dart';
import 'package:shop/pages/Inventory.dart';

class inventory_items extends StatefulWidget {
  const inventory_items({super.key});

  @override
  State<inventory_items> createState() => _inventory_itemsState();
}

class _inventory_itemsState extends State<inventory_items> {
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
        appBar: AppBar(
            leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        )),
        body: StreamBuilder<List<Item>>(
          stream: readItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went Wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final item = snapshot.data!;
              return ListView(
                children: item.map(builditem).toList(),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  Stream<List<Item>> readItems() => FirebaseFirestore.instance
      .collection('Inventory')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList());
  // Stream<List<Item>> readItems() => FirebaseFirestore.instance
  //     .collection('Inventory')
  //     .snapshots()
  //     .map((snapshot) => snapshot.docs.map((doc) => Item.fromJson(doc.data())))
  // .toList();
  Widget builditem(Item item) => Card(
        child: ListTile(
          title: Text(
            item.Name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Quantity: ' + item.Quantity.toString()),
                  SizedBox(
                    width: 10,
                  ),
                  Text('MRP: ' + item.StorePrice.toString()),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      submit_bar(Barcode: item.barcode);
                    },
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool decision = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Deleting"),
                                content: Text(
                                    "Are you sure you want to delete ${item.Name}?"),
                                actions: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text("Yes"),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.green),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text("No"),
                                  ),
                                ],
                              ));
                      if (decision) {
                        deleterecord(barcode: item.barcode);
                      }
                    },
                    child: Text('Delete'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
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

  Future additem(Item item) async {
    final db = FirebaseFirestore.instance;
    final docref = db.collection('Inventory').doc(item.barcode);
    final data = item.toJson();
    await docref.set(data);
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

  void cleancontrollers() {
    Namecontroller.clear();
    Quantitycontroller.clear();
    Categorycontroller.clear();
    MyPricecontroller.clear();
    StorePricecontroller.clear();
  }

  Future deleterecord({required String barcode}) async {
    final db = FirebaseFirestore.instance;
    db.collection("Inventory").doc(barcode).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }
}
