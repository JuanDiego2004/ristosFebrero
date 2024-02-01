import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StockNotificationWatcher extends StatefulWidget {
  const StockNotificationWatcher({Key? key}) : super(key: key);

  @override
  StockNotificationWatcherState createState() =>
      StockNotificationWatcherState();
}

class StockNotificationWatcherState extends State<StockNotificationWatcher> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final products = snapshot.data!.docs;
          checkStockAndShowDialog(context, products);
        }
        return SizedBox.shrink();
      },
    );
  }

  void checkStockAndShowDialog(
      BuildContext context, List<DocumentSnapshot> products) {
    for (var product in products) {
      final productData = product.data() as Map<String, dynamic>;
      final productName = productData['name'] as String;
      final productStock = productData['stock'] as int;

      if (productStock <= 5) {
        showLowStockDialog(context, productName, productStock);
      }
    }
  }

  void showLowStockDialog(BuildContext context, String productName, int stock) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Stock Bajo'),
          content: Text(
              '$productName tiene un stock bajo: $stock unidades restantes.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
