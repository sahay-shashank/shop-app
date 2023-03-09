import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/pages/Bill.dart';
import 'package:shop/pages/Inventory.dart';
import 'package:shop/pages/Summary.dart';
import 'package:shop/pages/Home.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialization(null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.removeAfter(initialization);
  runApp(MyApp(index: 0));
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(milliseconds: 100));
}

class MyApp extends StatefulWidget {
  late int index;
  MyApp({super.key, required this.index});

  @override
  State<MyApp> createState() => _MyAppState(index: index);
}

class _MyAppState extends State<MyApp> {
  int current_index = 0;
  final screens = [
    Home(),
    Inventory(),
    Bill(),
    Summary(),
  ];
  _MyAppState({required int index}) {
    current_index = index;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.amber,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      title: "Shop",
      home: Scaffold(
        body: screens[current_index],
        bottomNavigationBar: BottomNavigationBar(
          // selectedLabelStyle: GoogleFonts.poppins(),
          currentIndex: current_index,
          onTap: (value) => setState(() {
            current_index = value;
          }),
          // backgroundColor: Color.fromRGBO(0, 0, 0, 0),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              backgroundColor: Colors.red,
              label: "Home",
              tooltip: "Shows home page",
              activeIcon: Icon(Icons.home_filled),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse_outlined),
              backgroundColor: Colors.amber,
              label: "Inventory",
              tooltip: "Check the inventory",
              activeIcon: Icon(Icons.warehouse),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pages_outlined),
              backgroundColor: Colors.purple,
              label: "Bill",
              tooltip: "Bill the customers",
              activeIcon: Icon(Icons.pages),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_outlined),
              backgroundColor: Colors.cyan,
              label: "Summary",
              tooltip: "Summary of the day",
              activeIcon: Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
