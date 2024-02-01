import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EgresosScreen extends StatefulWidget {
  @override
  _EgresosScreenState createState() => _EgresosScreenState();
}

class _EgresosScreenState extends State<EgresosScreen> {
  bool isLoading = false;
  DateTime currentDate = DateTime.now();
  String formattedDate = '';
  List<Widget> _camposEgresos = [];
  List<GlobalKey<_CampoEgresoState>> _clavesEgresos = [];

  @override
  void initState() {
    super.initState();
    _updateFormattedDate();
  }

  void _updateFormattedDate() {
    formattedDate =
        '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Registro de Egresos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Registrar Egreso",
                          style: GoogleFonts.abel(
                              color: Colors.limeAccent, fontSize: 19),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                            onPressed: () => _agregarCampoEgreso(),
                            icon: Icon(
                              CupertinoIcons.add,
                              color: Colors.cyan,
                            )),
                      ],
                    ),
                    for (var i = 0; i < _camposEgresos.length; i++)
                      _camposEgresos[i],
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        _registrarEgresos(context);

                        setState(() {
                          isLoading = false;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 136, 233, 139)),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all<double>(5.0),
                      ),
                      child: Text(
                        'Registrar Egreso(s)',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registrarEgresos(BuildContext context) async {
    try {
      int monthNumber = currentDate.month;
      String formattedMonth = monthNumber.toString().padLeft(2, '0');
      String monthPath = '${currentDate.year}-$formattedMonth';

      int weekNumber = ((currentDate.day - 1) ~/ 7) + 1;
      String weekPath = 'semana$weekNumber';

      String salesPath = 'egresos/$monthPath/$weekPath';
      final saleCollection = FirebaseFirestore.instance.collection(salesPath);

      for (var i = 0; i < _clavesEgresos.length; i++) {
        var egresoData = {
          'monto': _clavesEgresos[i].currentState!._montoController.text,
          'descripcion':
              _clavesEgresos[i].currentState!._descripcionController.text,
          'categoria': _clavesEgresos[i].currentState!._selectedCategoria,
          'fecha': formattedDate,
        };

        await saleCollection.add(egresoData);
      }

      _clavesEgresos.clear();
      _camposEgresos.clear();
      setState(() {});

      // Mostrar diálogo de éxito
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Egreso registrado'),
            content: Text('El egreso se ha registrado correctamente.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error during _registrarEgresos: $e");
    }
  }

  void _agregarCampoEgreso() {
    var claveEgreso = GlobalKey<_CampoEgresoState>();
    _clavesEgresos.add(claveEgreso);

    _camposEgresos.add(
      _CampoEgreso(
        key: claveEgreso,
        onEliminar: () {
          _eliminarCampoEgreso(claveEgreso);
        },
      ),
    );
    setState(() {});
  }

  void _eliminarCampoEgreso(GlobalKey<_CampoEgresoState> clave) {
    int index = _clavesEgresos.indexOf(clave);
    _camposEgresos.removeAt(index);
    _clavesEgresos.remove(clave);
    setState(() {});
  }
}

class _CampoEgreso extends StatefulWidget {
  final VoidCallback onEliminar;

  const _CampoEgreso({Key? key, required this.onEliminar}) : super(key: key);

  @override
  _CampoEgresoState createState() => _CampoEgresoState();
}

class _CampoEgresoState extends State<_CampoEgreso> {
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _selectedCategoria = ''; // Inicializado como cadena vacía

  @override
  void initState() {
    super.initState();
    _montoController.text = '';
    _descripcionController.text = '';
    _selectedCategoria = 'Pasaje'; // Asigna un valor predeterminado
  }

  Future<String?> _mostrarDialogoCategorias(BuildContext context) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Seleccionar categoría'),
          actions: [
            for (var categoria in [
              'Pasaje',
              'Hospedaje',
              'Almacen Chupaca',
              'Cuatro Tarma',
              'Internet Chupaca',
              'Agua Chupaca',
              'Luz Chupaca',
              'Gas Chupaca',
              'Pago Contador',
              'Mi Banco',
              'P.Venta',
              'GLP',
              'GASOHOL',
              'Facturacion',
              'Menú',
              'P.Apoyo',
              'Otros'
            ])
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, categoria);
                },
                child: Text(
                  categoria,
                  style: GoogleFonts.notoSansPsalterPahlavi(fontSize: 17),
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 17,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            controller: _montoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: Color.fromARGB(255, 54, 54, 54),
              filled: true,
              labelText: 'Monto',
              labelStyle: TextStyle(
                color: Colors.white, // Color del texto de la etiqueta
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            controller: _descripcionController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              fillColor: Color.fromARGB(255, 54, 54, 54),
              filled: true,
              labelText: 'Description',
              labelStyle: TextStyle(
                color: Colors.white, // Color del texto de la etiqueta
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(
              CupertinoIcons.right_chevron,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              _selectedCategoria,
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontSize: 16),
            ),
            TextButton(
                onPressed: () async {
                  final categoriaSeleccionada =
                      await _mostrarDialogoCategorias(context);
                  if (categoriaSeleccionada != null) {
                    setState(() {
                      _selectedCategoria = categoriaSeleccionada;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cambiar categoría',
                      style: GoogleFonts.lato(
                          color: const Color.fromARGB(255, 204, 95, 223),
                          fontSize: 17),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(
                        onPressed: widget.onEliminar,
                        icon: const Icon(
                          CupertinoIcons.delete_solid,
                          color: Colors.red,
                        ))
                  ],
                )),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Future<void> _calculateTotalEgresos() async {
//   try {
//     if (startDate != null && endDate != null) {
//       DateTime currentDate = DateTime.now();
//       int monthNumber = currentDate.month;

//       // Construye la parte del camino correspondiente al mes en el formato deseado
//       String formattedMonth = monthNumber.toString().padLeft(2, '0');
//       String monthPath = '${currentDate.year}-$formattedMonth';

//       // Calcular el número total de semanas en el mes actual
//       int totalWeeksInMonth = ((currentDate.day - 1) ~/ 7) + 1;

//       // Inicializar total de egresos
//       double totalEgresos = 0.0;

//       // Iterar sobre todas las semanas del mes
//       for (int weekNumber = 1; weekNumber <= totalWeeksInMonth; weekNumber++) {
//         // Construir la ruta de la semana para los egresos (ajusta según tu estructura)
//         String egresosPath = 'egresos/$monthPath/semana$weekNumber';

//         // Realizar la consulta en la subcolección de egresos de la semana actual
//         QuerySnapshot egresosQuerySnapshot =
//             await FirebaseFirestore.instance.collection(egresosPath).get();

//         // Sumar los montos de egresos de la semana actual
//         egresosQuerySnapshot.docs.forEach((egresoDoc) {
//           dynamic montoValue = egresoDoc['monto'];
//           if (montoValue is num) {
//             totalEgresos += montoValue;
//           } else if (montoValue is String) {
//             try {
//               totalEgresos += double.parse(montoValue);
//             } catch (e) {
//               print('Error al convertir el valor del monto a double: $e');
//             }
//           }
//         });

//         print('Total de egresos en la semana $weekNumber: $totalEgresos');
//       }

//       // Puedes utilizar el valor totalEgresos como necesites
//       print('Egresos en el rango de fechas: $totalEgresos');

//       // Actualizar la interfaz de usuario si es necesario
//       setState(() {
//         this.egresosAmount = _formatCurrency(totalEgresos);
//       });
//     }
//   } catch (e) {
//     print('Error al calcular los egresos: $e');
//     // Tratar el error según tus necesidades
//   }
// }


// Future<void> _calculateTotalAmount() async {
//     try {
//       if (startDate != null && endDate != null) {
//         // Calcular el número total de días entre las fechas seleccionadas
//         int daysDifference = endDate!.difference(startDate!).inDays + 1;

//         DateTime currentDate = startDate!;
//         double totalAmount = 0;
//         double totalUtilidades = 0;

//         for (int i = 0; i < daysDifference; i++) {
//           // Construir la ruta de la colección específica para las ventas
//           String monthPath =
//               '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';
//           int weekNumber = ((currentDate.day - 1) ~/ 7) + 1;
//           String salesPath = 'ventasRistos/$monthPath/semana$weekNumber';

//           // Realizar la consulta en la colección específica
//           QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//               .collection(salesPath)
//               .where('fechaVenta',
//                   isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
//               .where('fechaVenta',
//                   isLessThanOrEqualTo:
//                       Timestamp.fromDate(currentDate.add(Duration(days: 1))))
//               .get();

//           querySnapshot.docs.forEach((doc) {
//             double montoTotal = doc['montoTotal'] ?? 0.0;
//             double utilidadTotal = doc['utilidad'] ?? 0.0;

//             totalAmount += montoTotal;
//             totalUtilidades += utilidadTotal;
//           });

//           // Avanzar al siguiente día para la próxima iteración
//           currentDate = currentDate.add(Duration(days: 1));
//         }

//         setState(() {
//           this.totalAmount = _formatCurrency(totalAmount);
//           this.utilidades = _formatCurrency(totalUtilidades);
//         });
//       }
//     } catch (e) {
//       print('Error al calcular el monto total de ventas: $e');
//     }
//   }


