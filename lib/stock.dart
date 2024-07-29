import 'package:hive/hive.dart';

part 'stock.g.dart';

@HiveType(typeId: 0)
class Stock {
  @HiveField(0)
  final String product_name;

  @HiveField(1)
  final String quantity;

  @HiveField(2)
  final String product_barcode;

  Stock(this.product_name, this.quantity, this.product_barcode);
}
