import 'package:shop/model/items.dart';

class CartItem {
  String barcode;
  int Quantity;
  double Cost;
  double Mycost;
  String Name;
  CartItem({
    required this.barcode,
    required this.Name,
    required this.Quantity,
    required this.Cost,
    required this.Mycost,
  });
  static CartItem CartItemcreate({required Item e, required int quantity}) =>
      CartItem(
        barcode: e.barcode,
        Name: e.Name,
        Quantity: quantity,
        Cost: e.StorePrice,
        Mycost: e.MyPrice,
      );
  Map<String, dynamic> toJson() => {
        'Barcode': barcode,
        'Name': Name,
        'Quantity': Quantity,
        'Cost': Cost,
      };
}
