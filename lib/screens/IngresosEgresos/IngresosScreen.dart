import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class IngresosScreen extends StatefulWidget {
  @override
  _IngresosScreenState createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  bool isLoading = false;
  DateTime currentDate = DateTime.now();
  List<Widget> _camposIngresos = [];
  List<GlobalKey<_CampoIngresoState>> _clavesIngresos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            Text('Registro de Ingresos', style: TextStyle(color: Colors.white)),
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
                          "Registrar Ingreso",
                          style: GoogleFonts.abel(
                              color: Colors.limeAccent, fontSize: 19),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                var claveIngreso =
                                    GlobalKey<_CampoIngresoState>();
                                _clavesIngresos.add(claveIngreso);
                                _camposIngresos.add(_CampoIngreso(
                                  key: claveIngreso,
                                  onEliminar: () {
                                    setState(() {
                                      _camposIngresos.removeLast();
                                      _clavesIngresos.removeLast();
                                    });
                                  },
                                ));
                              });
                            },
                            child: Icon(
                              CupertinoIcons.add,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            )),
                      ],
                    ),
                    for (var i = 0; i < _camposIngresos.length; i++)
                      _camposIngresos[i],
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        _registrarIngresos();

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

  void _mostrarDialogoExito() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Registro Exitoso'),
          content: Text('Los datos de ingresos se registraron correctamente.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _registrarIngresos() async {
    try {
      // Lista para almacenar datos de ingresos
      List<Map<String, dynamic>> ingresosDataList = [];

      // Iterar sobre las claves de los campos de ingresos y recopilar datos
      for (var i = 0; i < _clavesIngresos.length; i++) {
        final clave = _clavesIngresos[i];
        final ingresoState = clave.currentState;
        if (ingresoState != null) {
          final monto =
              double.tryParse(ingresoState._montoController.text) ?? 0.0;
          final descripcion = ingresoState._descripcionController.text;

          // Obtener el mes y la semana de la fecha actual
          int monthNumber = currentDate.month;
          String formattedMonth = monthNumber.toString().padLeft(2, '0');
          int weekNumber = ((currentDate.day - 1) ~/ 7) + 1;

          // Construir la ruta del documento en Firestore
          String monthPath = '${currentDate.year}-$formattedMonth';
          String weekPath = 'semana$weekNumber';
          String documentPath = 'ingresos/$monthPath/$weekPath';

          // Agregar datos a la lista
          ingresosDataList.add({
            'monto': monto,
            'descripcion': descripcion,
            'fecha': Timestamp.fromDate(currentDate),
          });

          // Guardar datos en Firestore
          CollectionReference ingresosRef =
              FirebaseFirestore.instance.collection(documentPath);
          await ingresosRef.add({
            'monto': monto,
            'descripcion': descripcion,
            'fecha': Timestamp.fromDate(currentDate),
          });
        }
      }

      // Limpiar los controladores de texto
      for (var i = 0; i < _clavesIngresos.length; i++) {
        _clavesIngresos[i].currentState?._montoController.clear();
        _clavesIngresos[i].currentState?._descripcionController.clear();
      }

      // Mostrar SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos de ingresos registrados correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Mostrar el diálogo de éxito
      _mostrarDialogoExito();

      // Limpiar la lista de claves de campos de ingresos
      setState(() {
        _camposIngresos.clear();
        _clavesIngresos.clear();
      });
    } catch (e) {
      print("Error durante _registrarIngresos: $e");
    }
  }
}

class _CampoIngreso extends StatefulWidget {
  final VoidCallback onEliminar;

  _CampoIngreso({Key? key, required this.onEliminar}) : super(key: key);

  @override
  _CampoIngresoState createState() => _CampoIngresoState();
}

class _CampoIngresoState extends State<_CampoIngreso> {
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

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
        SizedBox(height: 16),
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {
                  // Llamar a la función de devolución de llamada para manejar la eliminación
                  widget.onEliminar();
                },
                icon: Icon(
                  CupertinoIcons.delete,
                  color: Colors.red,
                ))
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
