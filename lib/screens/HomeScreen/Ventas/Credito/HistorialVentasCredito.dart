import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ristos/screens/BarraEstadistica/BarraEstadistica.dart';
import 'package:ristos/screens/HomeScreen/Ventas/Credito/detallesVentas.dart';

import 'package:ristos/screens/components/detalles-venta.dart';

import '../../../components/detalles-productos-vendidos.dart';

class HistorialVentaCreditoScreen extends StatefulWidget {
  const HistorialVentaCreditoScreen({
    super.key,
  });
  @override
  _HistorialVentaCreditoScreenState createState() =>
      _HistorialVentaCreditoScreenState();
}

class _HistorialVentaCreditoScreenState
    extends State<HistorialVentaCreditoScreen> {
  List<QueryDocumentSnapshot> sales = [];

  List<ExpansionItem> expansionItems = [];
  bool isRefreshing = false;
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    try {
      // Obtén el número del mes actual
      int monthNumber = DateTime.now().month;
      String formattedMonth = monthNumber.toString().padLeft(2, '0');

      // Calcula la semana actual del mes (considerando que un mes tiene 4 semanas)
      int weekNumber = ((DateTime.now().day - 1) ~/ 7) + 1;

      // Construye la parte del camino correspondiente al mes en el formato deseado
      String monthPath = '${DateTime.now().year}-$formattedMonth';

      // Construye el camino completo de la colección
      String salesPath = 'ventasCredito/$monthPath/semana$weekNumber';

      // Obtén una referencia a la colección
      final saleCollection = FirebaseFirestore.instance.collection(salesPath);

      // Realiza la consulta y obtén los documentos
      final salesQuery =
          await saleCollection.orderBy('fechaVenta', descending: true).get();

      setState(() {
        // Inicializa la lista de ventas
        sales = [];

        // Inicializar los elementos de expansión con fechas únicas
        final uniqueDates = Set<String>();

        // Recorre los documentos obtenidos
        salesQuery.docs.forEach((saleDoc) {
          final saleData = saleDoc.data() as Map<String, dynamic>;
          final fechaVenta = saleData['fechaVenta'] as Timestamp;
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(fechaVenta.toDate());

          // Agrega la fecha a las fechas únicas
          uniqueDates.add(formattedDate);

          // Agrega el documento a la lista de ventas
          sales.add(saleDoc);
        });

        // Crear elementos de expansión para cada fecha única
        expansionItems = uniqueDates.map((date) {
          return ExpansionItem(date, <QueryDocumentSnapshot>[]);
        }).toList();

        // Agregar ventas a los elementos de expansión correspondientes
        sales.forEach((saleDoc) {
          final saleData = saleDoc.data() as Map<String, dynamic>;
          final fechaVenta = saleData['fechaVenta'] as Timestamp;
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(fechaVenta.toDate());

          final item =
              expansionItems.firstWhere((item) => item.date == formattedDate);
          item.sales.add(saleDoc);
        });
      });
    } catch (e) {
      print('Error al cargar las ventas: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'Hubo un error al cargar las ventas. Por favor, inténtalo de nuevo.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      // Cuando termines de cargar los datos, asegúrate de poner isRefreshing a false
      setState(() {
        isRefreshing = false;
      });
    }
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
                              // Cierra el diálogo de confirmación
                              Navigator.of(context).pop();
// Obtén el número del mes actual
                              int monthNumber = DateTime.now().month;
                              String formattedMonth =
                                  monthNumber.toString().padLeft(2, '0');

                              // Calcula la semana actual del mes (considerando que un mes tiene 4 semanas)
                              int weekNumber =
                                  ((DateTime.now().day - 1) ~/ 7) + 1;

                              // Construye la parte del camino correspondiente al mes en el formato deseado
                              String monthPath =
                                  '${DateTime.now().year}-$formattedMonth';
                              // Obtiene la colección correcta para eliminar la venta
                              String salesPath =
                                  'ventasCredito/$monthPath/semana$weekNumber';
                              final saleCollection = FirebaseFirestore.instance
                                  .collection(salesPath);

                              // Elimina la venta de la colección correcta
                              saleCollection.doc(sale.id).delete().then((_) {
                                print('Venta eliminada correctamente');
                              }).catchError((error) {
                                print('Error al eliminar la venta: $error');
                              });
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
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: LineIcon.arrowCircleLeft(
              color: Colors.white,
            )),
        backgroundColor: Colors.black,
        title: Text(
          'Historia V.Credito',
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
                                        .start, // Alinea el botón o el icono a la derecha
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
                                            color: Colors.green),
                                      ),
                                      // Agrega un icono (por ejemplo, una lupa) que permite a los usuarios ver los detalles de los productos vendidos por día.
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
                                                    DetallesVentaCredito(
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

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}

class ExpansionItem {
  final String date;
  List<QueryDocumentSnapshot> sales;
  bool isExpanded;

  ExpansionItem(this.date, this.sales, {this.isExpanded = false});
}
