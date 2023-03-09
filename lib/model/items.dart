class Item {
  String barcode;
  String Name;
  double Quantity;
  double MyPrice;
  String Category;
  double StorePrice;
  Item({
    required this.barcode,
    required this.Name,
    required this.Category,
    required this.Quantity,
    required this.MyPrice,
    required this.StorePrice,
  });
  Map<String, dynamic> toJson() => {
        'Barcode': barcode,
        'Name': Name,
        'Category': Category,
        'Quantity': Quantity,
        'MyPrice': MyPrice,
        'StorePrice': StorePrice,
      };
  static Item fromJson(Map<String, dynamic> json) => Item(
        Category: json['Category'],
        Name: json['Name'],
        MyPrice: json['MyPrice'].toDouble(),
        Quantity: json['Quantity'].toDouble(),
        StorePrice: json['StorePrice'].toDouble(),
        barcode: json['Barcode']
      );
}
