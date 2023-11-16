import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ristos/screens/components/detalles-venta.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../../components/detalles-productos-vendidos.dart';

class HistorialVentasScreen extends StatefulWidget {
  const HistorialVentasScreen({
    super.key,
  });
  @override
  _HistorialVentasScreenState createState() => _HistorialVentasScreenState();
}

class _HistorialVentasScreenState extends State<HistorialVentasScreen> {
  List<QueryDocumentSnapshot> sales = [];

  List<ExpansionItem> expansionItems = [];
  bool isRefreshing = false;
  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    final salesQuery = await FirebaseFirestore.instance
        .collection('ventas')
        .orderBy('fechaVenta', descending: true)
        .get();

    setState(() {
      sales = salesQuery.docs;

      // Inicializar los elementos de expansión con fechas únicas
      final uniqueDates = Set<String>();
      sales.forEach((sale) {
        final fechaVenta = sale['fechaVenta'] as Timestamp;
        final formattedDate =
            DateFormat('yyyy-MM-dd').format(fechaVenta.toDate());
        uniqueDates.add(formattedDate);
      });

      // Crear elementos de expansión para cada fecha única
      expansionItems = uniqueDates.map((date) {
        return ExpansionItem(date, <QueryDocumentSnapshot>[]);
      }).toList();

      // Agregar ventas a los elementos de expansión correspondientes
      sales.forEach((sale) {
        final fechaVenta = sale['fechaVenta'] as Timestamp;
        final formattedDate =
            DateFormat('yyyy-MM-dd').format(fechaVenta.toDate());
        final item =
            expansionItems.firstWhere((item) => item.date == formattedDate);
        item.sales.add(sale);
      });
    });
    // Cuando termines de cargar los datos, asegúrate de poner isRefreshing a false
    setState(() {
      isRefreshing = false;
    });
  }

  Future<void> _handleRefresh() async {
    if (!isRefreshing) {
      setState(() {
        isRefreshing = true;
      });
      await loadSales();
    }
  }

  Widget buildSaleItem(QueryDocumentSnapshot sale) {
    final saleData = sale.data() as Map<String, dynamic>;
    final facturada = saleData['facturada'] ?? false;

    final clientName =
        saleData['clienteNombre'] ?? 'Nombre de Cliente Desconocido';
    final totalAmount = saleData['montoTotal'] ?? 0.0;
    final fechaVenta = saleData['fechaVenta'] as Timestamp?;
    final formattedDate = fechaVenta != null
        ? DateFormat('yyyy-MM-dd').format(fechaVenta.toDate())
        : 'Fecha Desconocida';

    return Column(
      children: [
        ListTile(
          title: Text(
            clientName,
            style: GoogleFonts.concertOne(color: Colors.white),
          ),
          subtitle: Text(
            'Monto Total: \$${totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.prompt(color: Colors.white60),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (facturada)
                Icon(
                  LineIcons.checkCircleAlt,
                  color: Colors.green,
                ),
              // Agregar un icono para eliminar ventas
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Eliminar Venta'),
                        content: Text(
                            '¿Está seguro de que desea eliminar esta venta?'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('Eliminar'),
                            onPressed: () {
                              // Muestra un diálogo de confirmación de eliminación usando Cupertino
                              showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: Text('Confirmación de Eliminación'),
                                    content: Text(
                                        '¿Estás seguro de que deseas eliminar esta venta?'),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text('Cancelar'),
                                        onPressed: () {
                                          // Cierra el diálogo sin realizar ninguna acción
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                          child: Text('Eliminar'),
                                          onPressed: () {
                                            // Resto del código...

                                            FirebaseFirestore.instance
                                                .collection('ventas')
                                                .doc(sale.id)
                                                .delete()
                                                .then((_) {
                                              print(
                                                  'Venta eliminada correctamente');
                                            }).catchError((error) {
                                              print(
                                                  'Error al eliminar la venta: $error');
                                            });

                                            // Cierra el diálogo después de intentar eliminar la venta
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  LineIcons.trash,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Establecer el fondo negro aquí
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Historial de Ventas',
          style: GoogleFonts.concertOne(fontSize: 22, color: Colors.white),
        ),
      ),
      body: isRefreshing
          ? Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de progreso mientras se refresca
          : (expansionItems.isEmpty
              ? Center(
                  child: Text(
                    'No hay ventas registradas.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    itemCount: expansionItems.length,
                    itemBuilder: (context, index) {
                      final item = expansionItems[index];

                      return ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        expansionCallback: (int itemIndex, bool isExpanded) {
                          setState(() {
                            item.isExpanded = !isExpanded;
                          });
                        },
                        children: [
                          ExpansionPanel(
                            backgroundColor:
                                const Color.fromARGB(255, 44, 43, 43),
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Column(
                                children: <Widget>[
                                  Divider(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Alinea el botón o el icono a la derecha
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isExpanded
                                              ? LineIcons.arrowUp
                                              : LineIcons.arrowDown,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            item.isExpanded = !item.isExpanded;
                                          });
                                        },
                                      ),
                                      Text(
                                        item.date,
                                        style: GoogleFonts.workSans(
                                            color: Colors.white),
                                      ),
                                      // Agrega un icono (por ejemplo, una lupa) que permite a los usuarios ver los detalles de los productos vendidos por día.
                                      IconButton(
                                        icon: Icon(
                                          LineIcons
                                              .car, // Puedes elegir un icono diferente
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          // Cuando se toca el botón, navega a la pantalla de detalles de productos vendidos por día.
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                DetallesProductosPorDiaScreen(
                                              // Pasa la fecha a la nueva pantalla
                                              sales: item.sales,
                                              date:
                                                  "", // Pasa las ventas a la nueva pantalla
                                            ),
                                          ));
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          LineIcons.locationArrow,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CupertinoAlertDialog(
                                                title: Text(
                                                    'Función en Desarrollo'),
                                                content: Text(
                                                    'Esta función aún está en desarrollo.'),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: Text('OK'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      )

                                      // En HistorialVentasScreen
                                    ],
                                  ),
                                ],
                              );
                            },
                            body: Column(
                              children: item.sales.asMap().entries.map((entry) {
                                final index = entry.key;
                                final sale = entry.value;

                                return Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetalleVentaScreen(
                                                        sale: sale)));
                                      },
                                      child: buildSaleItem(sale),
                                    ),
                                    if (index != item.sales.length - 1)
                                      Divider(
                                        color: const Color.fromARGB(
                                            255, 80, 80, 80),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                            isExpanded: item.isExpanded,
                          ),
                        ],
                      );
                    },
                  ),
                )),
    );
  }
}

class ExpansionItem {
  final String date;
  List<QueryDocumentSnapshot> sales;
  bool isExpanded;

  ExpansionItem(this.date, this.sales, {this.isExpanded = false});
}
