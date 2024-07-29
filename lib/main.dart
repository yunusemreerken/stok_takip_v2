import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'stock.dart';
import 'screens/stock_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(StockAdapter());

  await Hive.openBox('stocks');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockScreen(),
    );
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarcodeScannerScreen(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _scanResult = 'Henüz taranmadı';
  String _product_name = '';
  String _product_quantity = '';
  final Box stocksBox = Hive.box('stocks');

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  Future<void> startBarcodeScan() async {
    String scanResult;
    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'İptal', true, ScanMode.BARCODE);
      if (scanResult == '-1') {
        scanResult = 'Taramadan çıkıldı';
      }
    } catch (e) {
      scanResult = 'Taramada hata: $e';
    }

    setState(() {
      _scanResult = scanResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barkod Tarayici'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              // Tüm verileri silme işlemi
              stocksBox.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Tarama Sonucu: $_scanResult'),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Urun adini giriniz',
              ),
            ),
            TextField(
              controller: _controller2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Urun miktarini giriniz:',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startBarcodeScan,
              child: Text('Barkod Tara'),
            ),
            ElevatedButton(
              onPressed: () async {
                runApp(MyApp());
              },
              child: Text('Urunleri Listele'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          runApp(MyApp());

          _product_name = _controller.text;
          _product_quantity = _controller2.text;
          // Stok ekleme işlemi
          if (_scanResult.isNotEmpty &&
              _scanResult != 'Henüz taranmadı' &&
              _scanResult != 'Taramadan çıkıldı' &&
              _product_name.isNotEmpty &&
              _product_quantity.isNotEmpty) {
            final newStock =
                Stock(_product_name, _product_quantity, _scanResult);
            stocksBox.add(newStock);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
