import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/model/cartitems.dart';
import 'package:shop/model/items.dart';
import 'package:shop/pages/Inventory.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  late TextEditingController QuantityController;

  List<String> Items = [];
  List<int> Quantity_Items = [];
  List<CartItem> cart = [];
  List<double> cost = [];
  List<double> profit = [];
  double totalcost = 0;
  double totalprofit = 0;
  @override
  void initState() {
    super.initState();
    QuantityController = TextEditingController();
  }

  @override
  void dispose() {
    QuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 45, 8, 25),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await startBarcodeScanStream();
              },
              icon: Icon(Icons.camera),
              label: Text("Scan Code"),
            ),
            Expanded(
              child: ListView(
                children: cart.map((e) => createcartitem(item: e)).toList(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            getcomplete(),
          ],
        ),
      ),
    );
  }

  Future askpayment() async {
    await showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Total Amount: ₹$totalcost"),
            content: ListView(
              shrinkWrap: true,
              children: [
                Text("Select Payment Mode"),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addtoGpay();
                    Navigator.of(context).pop();
                  },
                  child: Text("Gpay"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addtoPhonePe();
                    Navigator.of(context).pop();
                  },
                  child: Text("PhonePe"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addtoPayTM();
                    Navigator.of(context).pop();
                  },
                  child: Text("Paytm"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addtoCash();
                    Navigator.of(context).pop();
                  },
                  child: Text("Cash"),
                ),
              ],
            ),
            actions: [],
          )),
    );
  }

  Future<void> startBarcodeScanStream() async {
    String barcode = "";
    try {
      barcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      print("Platform Error");
    }
    print("Barcode");
    await checkitem(barcode: barcode);
  }

  Future checkitem({required String barcode}) async {
    if (!Items.contains(barcode)) {
      await getquantity(barcode: barcode, present: false);
    } else {
      setState(() {
        QuantityController.text =
            Quantity_Items[Items.indexOf(barcode)].toString();
      });
      await getquantity(barcode: barcode, present: true);
      cart.removeAt(Items.indexOf(barcode));
    }
    final doc = await getdata(barcode: barcode);
    int index = Items.indexOf(barcode);
    if (doc.isEmpty) {
      await showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: Text("New Item Found."),
              content: Text(
                  "Scan the item again to add this item after redirecting."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Inventory(),
                      ),
                    );
                  },
                  child: Text("Redirect"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Items.remove(barcode);
                    Quantity_Items.removeAt(index);
                  },
                  child: Text("Cancel"),
                ),
              ],
            )),
      );
    }

    print("docs:${doc.isEmpty}");
    doc.forEach((e) {
      print("ITEM12");
      print(e);
      cart.insert(index,
          CartItem.CartItemcreate(e: e, quantity: Quantity_Items[index]));
      cost.insert(index, e.StorePrice * Quantity_Items[index]);
      profit.insert(index, (e.StorePrice - e.MyPrice) * Quantity_Items[index]);
    });
    setState(() {
      print("instate");
    });
  }

  Future getquantity({required String barcode, required bool present}) async {
    await showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Enter Quantity"),
            content: TextField(
              keyboardType: TextInputType.number,
              controller: QuantityController,
              autofocus: true,
              decoration: InputDecoration(hintText: "Enter Quantity of item."),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (QuantityController.text != "" &&
                      int.parse(QuantityController.text) >= 1) {
                    if (!present) {
                      setState(() {
                        Items.add(barcode);
                        Quantity_Items.add(int.parse(QuantityController.text));
                      });
                    } else {
                      setState(() {
                        Quantity_Items[Items.indexOf(barcode)] =
                            int.parse(QuantityController.text);
                      });
                    }
                    Navigator.of(context).pop();
                    QuantityController.clear();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text("Enter Quantity"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text("Add"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ],
          )),
    );
  }

  Widget createcartitem({required CartItem item}) => Card(
        child: ListTile(
          title: Text(item.Name),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MRP: ${item.Cost}"),
              Text("COST: ${item.Cost * item.Quantity}"),
              IconButton(
                onPressed: () {
                  int index = Items.indexOf(item.barcode);
                  setState(() {
                    item.Quantity += 1;
                    Quantity_Items[index] = item.Quantity;
                    cost[index] = item.Cost * item.Quantity;
                    profit[index] = (item.Cost - item.Mycost) * item.Quantity;
                  });
                },
                icon: Icon(Icons.add),
                color: Colors.green,
              ),
              Text('${item.Quantity}'),
              IconButton(
                onPressed: () {
                  int index = Items.indexOf(item.barcode);
                  setState(() {
                    item.Quantity -= 1;
                    Quantity_Items[index] = item.Quantity;
                    cost[index] = item.Cost * item.Quantity;
                    profit[index] = (item.Cost - item.Mycost) * item.Quantity;
                  });
                  if (item.Quantity < 1) {
                    Quantity_Items.removeAt(index);
                    Items.removeAt(index);
                    cart.removeAt(index);
                    profit.removeAt(index);
                  }
                  setState(() {});
                },
                icon: Icon(Icons.remove),
                color: Colors.red,
              ),
            ],
          ),
        ),
      );

  Future<List<Item>> getdata({required String barcode}) async =>
      await FirebaseFirestore.instance
          .collection('Inventory')
          .where('Barcode', isEqualTo: barcode)
          .get()
          .then((value) =>
              value.docs.map((e) => Item.fromJson(e.data())).toList())
          .whenComplete(() => print("got"));

  checkpaymentdoc() async {
    final init = {
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
    doc.get().then((value) {
      if (!value.exists) {
        doc.set(init);
      }
    });
  }

  addtoGpay() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    print("Date: $date");
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .update({
      'GPay': FieldValue.increment(totalcost),
      'Bills': FieldValue.increment(1)
    });
  }

  addtoPhonePe() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .update({
      'PhonePe': FieldValue.increment(totalcost),
      'Bills': FieldValue.increment(1)
    });
  }

  addtoPayTM() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .update({
      'PayTM': FieldValue.increment(totalcost),
      'Bills': FieldValue.increment(1)
    });
  }

  addtoCash() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .update({
      'Cash': FieldValue.increment(totalcost),
      'Bills': FieldValue.increment(1)
    });
  }

  addtoProfit() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .update({'Profit': FieldValue.increment(totalprofit)});
  }

  addbill() async {
    final datenow = DateTime.now();
    final date = '${datenow.day}-${datenow.month}-${datenow.year}';
    int billindex = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(date)
        .get()
        .then((value) {
      final doc = value.data() as Map<String, dynamic>;
      return doc['Bills'];
    });
    await reflectinventory();
    print("Bill: $billindex");
    final documentid = '${date}_$billindex';
    Map<String, dynamic> bill = {};
    cart.forEach((element) {
      bill.addAll({'${element.barcode}': element.toJson()});
    });
    print(bill);
    final doc = await FirebaseFirestore.instance
        .collection('Bill')
        .doc(documentid)
        .set(bill);
    await addtoProfit();
  }

  cleareverything() {
    setState(() {
      QuantityController.clear();
      Items = [];
      Quantity_Items = [];
      cart = [];
      cost = [];
      totalcost = 0;
      profit = [];
      totalprofit = 0;
    });
  }

  reflectinventory() async {
    print(Items.isEmpty);
    Items.forEach((barcode) async {
      int quant = Quantity_Items[Items.indexOf(barcode)] * -1;
      // print(quant);
      // print("quantity12: $quant");
      final doc = await FirebaseFirestore.instance
          .collection('Inventory')
          .doc(barcode)
          .update({'Quantity': FieldValue.increment(quant)});
    });
  }

  Widget getcomplete() {
    if (cart.isNotEmpty)
      return ElevatedButton(
        onPressed: () async {
          setState(() {
            cost.forEach((e) => totalcost += e);
            profit.forEach((e) => totalprofit += e);
            print(totalcost);
          });
          await checkpaymentdoc();
          await askpayment();
          await addbill();
          await cleareverything();
        },
        child: Text("Complete"),
      );
    else {
      return Text("Add Items to complete");
    }
  }
}
