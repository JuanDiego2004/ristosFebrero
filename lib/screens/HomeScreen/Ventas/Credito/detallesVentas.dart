import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maps_launcher/maps_launcher.dart';

class DetallesVentaCredito extends StatefulWidget {
  final QueryDocumentSnapshot sale;

  const DetallesVentaCredito({Key? key, required this.sale}) : super(key: key);

  @override
  _DetallesVentaCreditoState createState() => _DetallesVentaCreditoState();
}

class _DetallesVentaCreditoState extends State<DetallesVentaCredito> {
  bool? estaFacturada; // Nuevo estado para rastrear si la venta está facturada
  String? direccionCliente;
  String? tipoDocumentoCliente;
  String? numeroDocumentoCliente;
  String? vendedorCorreo;
  String? coordenadasTexto;
  double? diferenciaMontos;
  bool isPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    // Obtén el estado de facturación de Firestore al cargar la pantalla
    final saleData = widget.sale.data() as Map<String, dynamic>;
    estaFacturada = saleData['facturada'] ?? false;

    // Recupera la información del cliente desde Firestore
    final clienteNombre = saleData['clienteNombre'];
    if (clienteNombre != null) {
      // Realiza una consulta a la colección "clientes" para obtener la información del cliente
      FirebaseFirestore.instance
          .collection('clientes')
          .where('nombre', isEqualTo: clienteNombre)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final clienteData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            direccionCliente = clienteData['direccion'];
            tipoDocumentoCliente = clienteData['tipoDocumento'];
            numeroDocumentoCliente = clienteData["numeroDocumento"];
          });
        }
      });
    }

    // Calcular la diferencia entre montoTotal y montoInicial
    final montoTotal = saleData['montoTotal'] ?? 0.0;
    final montoInicial = saleData['montoInicial'] ?? 0.0;
    diferenciaMontos = montoTotal - montoInicial;
  }

  void actualizarFacturacionFirestore(bool newValue) async {
    // Actualiza el estado de facturación en Firestore
    await widget.sale.reference.update({'facturada': newValue});
  }

  void _mostrarDialogoAgregarPago() async {
    TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Agregar Pago'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CupertinoTextField(
                  controller: montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  placeholder: 'Ingrese el monto',
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Agregar'),
              onPressed: () async {
                // Validar y procesar el monto ingresado
                if (montoController.text.isNotEmpty) {
                  double montoIngresado = double.parse(montoController.text);

                  // Obtener datos de la venta
                  Map<String, dynamic> saleData =
                      widget.sale.data() as Map<String, dynamic>;

                  // Obtener monto total y monto inicial actual
                  double montoTotal = saleData['montoTotal'] ?? 0.0;
                  double montoInicialActual = saleData['montoInicial'] ?? 0.0;

                  // Calcular la deuda actual
                  double deudaActual = montoTotal - montoInicialActual;

                  // Validar si el monto ingresado es mayor a la deuda
                  if (montoIngresado > deudaActual) {
                    // Mostrar error
                    Navigator.of(context).pop(); // Cerrar el diálogo actual
                    _mostrarDialogoError(
                        'El monto ingresado es mayor a la deuda actual.');
                    return;
                  }

                  // Calcular la nueva diferencia
                  double nuevoDiferenciaMontos =
                      (montoTotal - (montoInicialActual + montoIngresado))
                          .toDouble();

                  // Actualizar en Firestore
                  await widget.sale.reference.update({
                    'montoInicial':
                        (montoInicialActual + montoIngresado).toDouble(),
                  });

                  // Obtener los datos actualizados después de la actualización en Firestore
                  DocumentSnapshot updatedSale =
                      await widget.sale.reference.get();
                  Map<String, dynamic> updatedSaleData =
                      updatedSale.data() as Map<String, dynamic>;

                  setState(() {
                    // Actualizar en el estado local
                    saleData['montoInicial'] =
                        updatedSaleData['montoInicial'].toDouble();
                    diferenciaMontos = montoTotal -
                        (updatedSaleData['montoInicial'].toDouble());
                  });

                  Navigator.of(context).pop(); // Cerrar el diálogo actual
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: [
            CupertinoDialogAction(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo de error
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleData = widget.sale.data() as Map<String, dynamic>;
//
    final GeoPoint coordenadas = saleData['coordenadas'] as GeoPoint;
    final double latitud = coordenadas.latitude;
    final double longitud = coordenadas.longitude;

    void openMaps(double lat, double long) {
      MapsLauncher.launchCoordinates(lat, long);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.money_dollar_circle,
              color: Colors.white,
            ),
            onPressed: () {
              _mostrarDialogoAgregarPago();
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(
            LineIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Detalles de V.Credito',
          style: GoogleFonts.concertOne(fontSize: 22, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: 'Cliente: ',
                style: GoogleFonts.abhayaLibre(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  TextSpan(
                    style: GoogleFonts.magra(color: Colors.white, fontSize: 15),
                    text:
                        '${saleData['clienteNombre'] ?? 'Nombre de Cliente Desconocido'}',
                  ),
                ],
              ),
            ),
            // Agregar la dirección y el tipo de documento del cliente aquí
            if (direccionCliente != null)
              RichText(
                  text: TextSpan(
                      text: "Direccion: ",
                      style: GoogleFonts.abhayaLibre(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$direccionCliente",
                        style: GoogleFonts.magra(
                            color: Colors.white, fontSize: 15))
                  ])),
            if (tipoDocumentoCliente != null)
              RichText(
                  text: TextSpan(
                      text: "Tipo de Documento: ",
                      style: GoogleFonts.abhayaLibre(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$tipoDocumentoCliente",
                        style: GoogleFonts.magra(
                            color: Colors.white, fontSize: 15))
                  ])),
            if (numeroDocumentoCliente != null)
              RichText(
                  text: TextSpan(
                      text: "Numero de Documento: ",
                      style: GoogleFonts.abhayaLibre(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$numeroDocumentoCliente",
                        style: GoogleFonts.magra(
                            color: Colors.white, fontSize: 15))
                  ])),
            RichText(
              text: TextSpan(
                  text: "Fecha: ",
                  style: GoogleFonts.abhayaLibre(
                    fontSize: 19,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        style: GoogleFonts.magra(
                            color: Colors.white, fontSize: 15),
                        text: '${formattedDate(saleData['fechaVenta'])}')
                  ]),
            ),
            const Divider(
              color: Color.fromARGB(255, 46, 46, 46),
            ),
            const SizedBox(height: 20),
            const Text('Lista de Productos',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: saleData['productos'].length,
                itemBuilder: (context, index) {
                  final producto = saleData['productos'][index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          producto["nombre"],
                          style: GoogleFonts.mPlusCodeLatin(
                              color: Colors.white, fontSize: 15),
                        ),
                        subtitle: Text(
                          'Cantidad: ${producto['cantidad']}',
                          style: GoogleFonts.akshar(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 14),
                        ),
                        trailing: Text(
                          'Subtotal: \$${(producto['cantidad'] * producto['precio']).toStringAsFixed(2)}',
                          style: GoogleFonts.akshar(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 14),
                        ),
                      ),
                      Divider(
                        color: const Color.fromARGB(255, 46, 46, 46),
                      )
                    ],
                  );
                },
              ),
            ),
            Divider(),
            ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.all(0),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  // Cambiar el estado de expansión del panel
                  // Puedes utilizar un estado booleano para controlar esto
                  // Aquí se asume que tienes un booleano llamado `isPanelExpanded`
                  isPanelExpanded = !isPanelExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  backgroundColor: Colors.black,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(
                        'Información Detallada',
                        style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold),
                      ),
                      leading: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPanelExpanded = !isPanelExpanded;
                          });
                        },
                        child: Icon(
                          isExpanded
                              ? CupertinoIcons.up_arrow
                              : CupertinoIcons.down_arrow,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                              text: TextSpan(
                                  text: "Informacion: ",
                                  style: GoogleFonts.mPlus1Code(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  children: <TextSpan>[
                                TextSpan(
                                    style: GoogleFonts.arapey(
                                        color: Colors.white, fontSize: 15),
                                    text:
                                        "${saleData['informacionAdicional'] ?? 'No proporcionada'}")
                              ])),
                        ),
                        Divider(
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                        Text(
                            'Monto Total: \$${(saleData['montoTotal'] ?? 0.0).toStringAsFixed(2)}',
                            style: GoogleFonts.mPlus1Code(
                              fontSize: 15,
                              color: Colors.white,
                            )),
                        Divider(
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                        Text(
                          'Utilidad: \$${(saleData['utilidad'] ?? 0.0).toStringAsFixed(2)}',
                          style: GoogleFonts.mPlus1Code(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Divider(
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                        if (diferenciaMontos != null)
                          Text(
                            'Debe: \$${diferenciaMontos!.toStringAsFixed(2)}',
                            style: GoogleFonts.mPlus1Code(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 255, 0, 0),
                            ),
                          ),
                        const Divider(),
                        Text(
                          'Monto Inicial: \$${(saleData['montoInicial'] ?? 0.0).toStringAsFixed(2)}',
                          style: GoogleFonts.mPlus1Code(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(),
                        Text(
                            "Vendido por: ${saleData['vendedorCorreo'] ?? 'Nombre de Vendedor Desconocido'}",
                            style: GoogleFonts.mPlus1Code(
                              fontSize: 15,
                              color: Colors.white,
                            )),
                        Divider(
                          color: const Color.fromARGB(255, 70, 70, 70),
                        ),
                        if (coordenadasTexto != null)
                          Text(
                            'Coordenadas: $coordenadasTexto',
                            style: GoogleFonts.concertOne(
                                fontSize: 19, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  isExpanded: isPanelExpanded,
                ),
              ],
            ),

            // Agrega un checkbox para marcar si la venta está facturada
            Row(
              children: [
                Text('Ya pago?: ',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Checkbox(
                  value: estaFacturada ?? false,
                  onChanged: (newValue) {
                    setState(() {
                      estaFacturada = newValue;
                      // Actualiza Firestore cuando se cambia el valor del checkbox
                      actualizarFacturacionFirestore(newValue == true);
                    });
                  },
                ),
                const SizedBox(
                  width: 70,
                ),
                ElevatedButton(
                  onPressed: () {
                    openMaps(latitud, longitud);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(
                            255, 90, 90, 90)), // Cambia el color de fondo
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Cambia el radio del borde
                    )),
                  ),
                  child: Text(
                    'Abrir locacion',
                    style: GoogleFonts.monda(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchUrl(Uri url) async {
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'No se puede abrir la URL: $url';
    }
  }

  String formattedDate(Timestamp? timestamp) {
    if (timestamp != null) {
      final date = timestamp.toDate();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      return dateFormat.format(date);
    } else {
      return 'Fecha Desconocida';
    }
  }
}
