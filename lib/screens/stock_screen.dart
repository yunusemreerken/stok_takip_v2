// lib/screens/stock_screen.dart
import 'package:barcode_scan2/model/scan_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:stok_takip_v2/main.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../stock.dart';
import 'package:hive_flutter/adapters.dart';

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final Box stocksBox = Hive.box('stocks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Yönetimi      -    işlemler '),
      ),
      body: ValueListenableBuilder(
        valueListenable: stocksBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('Görüntülenebilecek stok yoktur.'),
            );
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final stock = box.getAt(index) as Stock;
                return ListTile(
                  title: Text('Ürün adı: ${stock.product_name}'),
                  subtitle: Text(
                      'Miktar: ${stock.quantity}  -     \nBarkod: ${stock.product_barcode} '),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Güncelleme işlevi
                          showDialog(
                            context: context,
                            builder: (context) {
                              return UpdateTaskDialog(
                                  stock: stock, index: index);
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Tek tek veri silme işlemi
                          box.deleteAt(index);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          runApp(MyApp2());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class UpdateTaskDialog extends StatefulWidget {
  final Stock stock;
  final int index;

  UpdateTaskDialog({required this.stock, required this.index});

  @override
  _UpdateTaskDialogState createState() => _UpdateTaskDialogState();
}

class _UpdateTaskDialogState extends State<UpdateTaskDialog> {
  final Box stocksBox = Hive.box('stocks');

  String _scanResult = 'Henüz taranmadı';
  String _product_name = '';
  String _product_quantity = '';
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
        title: Text('Barkod Tarayıcı'),
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
                labelText: '${stocksBox.getAt(widget.index)}',
                hintText: '',
              ),
            ),
            TextField(
              controller: _controller2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ürün miktarını giriniz:',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startBarcodeScan,
              child: Text('Barkod Tara'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            runApp(MyApp2());

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
              stocksBox.deleteAt(widget.index);
            }
          },
          child: Icon(Icons.update)),
    );
  }
}
