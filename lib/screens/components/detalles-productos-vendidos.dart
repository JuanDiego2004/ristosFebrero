import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class DetallesProductosPorDiaScreen extends StatelessWidget {
  final String date;
  final List<dynamic> sales; // Lista de ventas (ajusta el tipo según tus datos)

  DetallesProductosPorDiaScreen({required this.date, required this.sales});

  @override
  Widget build(BuildContext context) {
    // Inicializa un mapa para rastrear las cantidades de cada producto
    Map<String, int> productCounts = {};

    // Procesa las ventas para calcular las cantidades de productos
    for (var sale in sales) {
      final products = sale['productos']
          as List<dynamic>; // Ajusta la estructura según tus datos

      for (var product in products) {
        final productName =
            product['nombre'] as String; // Ajusta la clave según tus datos

        if (productCounts.containsKey(productName)) {
          productCounts[productName] =
              (productCounts[productName] ?? 0) + (product['cantidad'] as int);
        } else {
          productCounts[productName] = (product['cantidad'] as int);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.arrowCircleLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Productos Vendidos el $date',
          style: GoogleFonts.albertSans(color: Colors.white, fontSize: 16),
        ),
      ),
      body: ListView.builder(
        itemCount: productCounts.length,
        itemBuilder: (context, index) {
          final productName = productCounts.keys.elementAt(index);
          final productQuantity = productCounts.values.elementAt(index);

          return Column(
            children: [
              ListTile(
                title: Text(
                  '$productName: $productQuantity Paquetes',
                  style:
                      GoogleFonts.alumniSans(color: Colors.white, fontSize: 18),
                ),
              ),
              Divider(
                // Agrega una línea divisoria entre los elementos
                height:
                    1, // Puedes ajustar la altura de la línea según tus preferencias
                color: const Color.fromARGB(255, 122, 122,
                    122), // Puedes ajustar el color de la línea según tus preferencias
              ),
            ],
          );
        },
      ),
    );
  }
}
