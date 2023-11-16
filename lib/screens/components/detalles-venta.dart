import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maps_launcher/maps_launcher.dart';

class DetalleVentaScreen extends StatefulWidget {
  final QueryDocumentSnapshot sale;

  const DetalleVentaScreen({Key? key, required this.sale}) : super(key: key);

  @override
  _DetalleVentaScreenState createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  bool? estaFacturada; // Nuevo estado para rastrear si la venta está facturada
  String? direccionCliente;
  String? tipoDocumentoCliente;
  String? numeroDocumentoCliente;
  String? vendedorCorreo;
  String? coordenadasTexto;
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
  }

  void actualizarFacturacionFirestore(bool newValue) async {
    // Actualiza el estado de facturación en Firestore
    await widget.sale.reference.update({'facturada': newValue});
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
          'Detalles de Venta',
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
                style: GoogleFonts.concertOne(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  TextSpan(
                    style:
                        GoogleFonts.almarai(color: Colors.white, fontSize: 15),
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
                      style: GoogleFonts.concertOne(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$direccionCliente",
                        style: GoogleFonts.almarai(
                            color: Colors.white, fontSize: 15))
                  ])),
            if (tipoDocumentoCliente != null)
              RichText(
                  text: TextSpan(
                      text: "Tipo de Documento: ",
                      style: GoogleFonts.concertOne(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$tipoDocumentoCliente",
                        style: GoogleFonts.almarai(
                            color: Colors.white, fontSize: 15))
                  ])),
            if (numeroDocumentoCliente != null)
              RichText(
                  text: TextSpan(
                      text: "Numero de Documento: ",
                      style: GoogleFonts.concertOne(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "$numeroDocumentoCliente",
                        style: GoogleFonts.almarai(
                            color: Colors.white, fontSize: 15))
                  ])),
            RichText(
              text: TextSpan(
                  text: "Fecha: ",
                  style: GoogleFonts.concertOne(
                    fontSize: 19,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        style: GoogleFonts.almarai(
                            color: Colors.white, fontSize: 15),
                        text: '${formattedDate(saleData['fechaVenta'])}')
                  ]),
            ),
            Divider(
              color: const Color.fromARGB(255, 46, 46, 46),
            ),
            SizedBox(height: 20),
            Text('Lista de Productos',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
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
                          style: GoogleFonts.agdasima(
                              color: Colors.white, fontSize: 21),
                        ),
                        subtitle: Text(
                          'Cantidad: ${producto['cantidad']}',
                          style: GoogleFonts.akshar(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 17),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                  text: TextSpan(
                      text: "Informacion: ",
                      style: GoogleFonts.concertOne(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        style: GoogleFonts.arapey(
                            color: Colors.white, fontSize: 17),
                        text:
                            "${saleData['informacionAdicional'] ?? 'No proporcionada'}")
                  ])),
            ),
            Divider(
              color: const Color.fromARGB(255, 70, 70, 70),
            ),
            Text(
                'Monto Total: \$${(saleData['montoTotal'] ?? 0.0).toStringAsFixed(2)}',
                style: GoogleFonts.concertOne(
                  fontSize: 19,
                  color: Colors.white,
                )),
            Divider(
              color: const Color.fromARGB(255, 70, 70, 70),
            ),
            Text(
                "Vendido por: ${saleData['vendedorCorreo'] ?? 'Nombre de Vendedor Desconocido'}",
                style: GoogleFonts.concertOne(
                  fontSize: 19,
                  color: Colors.white,
                )),
            Divider(
              color: const Color.fromARGB(255, 70, 70, 70),
            ),
            if (coordenadasTexto != null)
              Text(
                'Coordenadas: $coordenadasTexto',
                style:
                    GoogleFonts.concertOne(fontSize: 19, color: Colors.white),
              ),
            // Agrega un checkbox para marcar si la venta está facturada
            Row(
              children: [
                Text('Facturada: ',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
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
                // TextButton(
                //   onPressed: () {
                //     final saleData = widget.sale.data() as Map<String, dynamic>;
                //     final coordinates = saleData['coordenadas'] as GeoPoint;

                //     if (coordinates != null) {
                //       final latitud = coordinates.latitude;
                //       final longitud = coordinates.longitude;

                //       if (latitud != null && longitud != null) {
                //         final googleMapsUrl =
                //             'https://www.google.com/maps?q=$latitud,$longitud';

                //         // Muestra el enlace en un TextField para copiar
                //         showDialog(
                //           context: context,
                //           builder: (context) {
                //             return AlertDialog(
                //               title: Text('Enlace a Google Maps'),
                //               content: TextField(
                //                 controller:
                //                     TextEditingController(text: googleMapsUrl),
                //                 readOnly: true,
                //                 decoration: InputDecoration(
                //                   labelText: 'Enlace',
                //                   hintText: 'Presiona para copiar',
                //                 ),
                //               ),
                //               actions: [
                //                 TextButton(
                //                   child: Text('Cerrar'),
                //                   onPressed: () {
                //                     Navigator.of(context).pop();
                //                   },
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       }
                //     }
                //   },
                //   child: Text('Ver en Google Maps'),
                // )
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
