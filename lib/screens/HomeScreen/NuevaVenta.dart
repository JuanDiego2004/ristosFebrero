import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NuevaVenta extends StatefulWidget {
  @override
  _NuevaVentaState createState() => _NuevaVentaState();
}

class _NuevaVentaState extends State<NuevaVenta> {
  TextEditingController clientNameController = TextEditingController();
  TextEditingController _clientSearchController = TextEditingController();

  String clientQuery = '';
  String selectedClient = '';
  String productQuery = '';
  String additionalInfo = "";
  List<SelectedProduct> selectedProducts = [];
  List<TextEditingController> cantidadControllers = [];
  double totalAmount = 0.0;
  List<Map<String, dynamic>> productsData =
      []; // Declaración de la lista de productos

  TextEditingController _customerController = TextEditingController();
  TextEditingController _direccionController = TextEditingController();
  TextEditingController _additionalInfoController = TextEditingController();

  String _selectedDocumentType = 'DNI';
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String selectedSearchOption =
      'Nombre'; // Establece un valor predeterminado, por ejemplo, 'Nombre'.

  void _refreshScreen() {
    setState(() {
      _clientSearchController.clear();
      clientQuery = '';
      _customerController.clear();
      _direccionController.clear();
      _selectedDocumentType = 'DNI';
      productQuery = '';
      selectedClient = '';
      selectedProducts = [];
      cantidadControllers = [];
      _additionalInfoController.clear();
    });
  }

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: Text(
            'Nueva Venta',
            style: GoogleFonts.concertOne(fontSize: 22, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/add.png",
              width: 40,
              height: 40,
            ),
            onPressed: () {
              _showAddCustomerDialog(context);
            },
          ),
        ),
        body: RefreshIndicator(
          child: Column(
            children: <Widget>[
              _buildClientSearch(),
              _buildProductSearch(),
              _buildSelectedProductsList(),
            ],
          ),
          key: _refreshIndicatorKey,
          onRefresh: () async {
            _refreshScreen();
          },
        ));
  }

  void _showAddCustomerDialog(BuildContext context) {
    // Controladores para los campos de entrada
    TextEditingController nameController = TextEditingController();
    TextEditingController documentNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController codigoClienteController = TextEditingController();
    String selectedCategory = "Tarma"; // Valor predeterminado
    String selectedDocumentType = "DNI"; // Valor predeterminado

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nombre del Cliente'),
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      icon: Icon(LineIcons.arrowDown,
                          color: const Color.fromARGB(255, 2, 2, 2)),
                      items: [
                        'DNI',
                        'RUC',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDocumentType = newValue!;
                        });
                      },
                      value: selectedDocumentType,
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: TextField(
                        controller: documentNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número de ${selectedDocumentType}',
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Dirección'),
                ),
                TextField(
                  controller: codigoClienteController,
                  decoration: InputDecoration(labelText: 'Código de Cliente'),
                ),
                DropdownButton<String>(
                  icon: Icon(LineIcons.arrowDown,
                      color: const Color.fromARGB(255, 2, 2, 2)),
                  items: [
                    'Tarma',
                    'Huancayo',
                    'Chupaca',
                    "Oroya",
                    'Otros',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  value: selectedCategory,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                // Obtener los valores de los campos de entrada
                String customerName = nameController.text;
                String documentNumber = documentNumberController.text;
                String address = addressController.text;
                String codigoCliente = codigoClienteController.text;
                String category = selectedCategory;

                if (customerName.isNotEmpty &&
                    documentNumber.isNotEmpty &&
                    address.isNotEmpty &&
                    codigoCliente.isNotEmpty) {
                  try {
                    // Crear un nuevo documento en la colección "clientes"
                    await FirebaseFirestore.instance
                        .collection('clientes')
                        .add({
                      'nombre': customerName,
                      'tipoDocumento':
                          selectedDocumentType, // Tipo de documento
                      'numeroDocumento': documentNumber,
                      'direccion': address,
                      'codigoCliente': codigoCliente,
                      'lugar': category,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cliente agregado correctamente.'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error al guardar el cliente en Firestore: $e');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ningún campo debe estar vacío.'),
                    ),
                  );
                }
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildClientSearch() {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown para seleccionar la opción de búsqueda
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    // Establece el ancho máximo deseado
                    child: DropdownButton<String>(
                      icon: Icon(LineIcons.arrowDown, color: Colors.white),
                      items:
                          ['Nombre', 'Código de Cliente'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: 80, // Ajusta el ancho según tus necesidades
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSearchOption = newValue!;
                        });
                      },
                      value: selectedSearchOption,
                      menuMaxHeight:
                          100, // Ajusta la altura máxima del menú según tus necesidades
                    )),

                SizedBox(width: 16),

                // Campo de búsqueda
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.5, // Establece el ancho al 70% de la pantalla
                  child: TextField(
                    style: TextStyle(
                        color: const Color.fromARGB(255, 216, 134, 134)),
                    controller: _clientSearchController,
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 54, 54, 54),
                      filled: true,
                      labelText: selectedSearchOption == 'Nombre'
                          ? 'Buscar Cliente por Nombre'
                          : 'Buscar Cliente por Código',
                      labelStyle: TextStyle(
                        color: Colors.white,
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
                    // Color del texto escrito
                    onChanged: (query) {
                      setState(() {
                        clientQuery = query;
                      });
                    },
                  ),
                ),
              ],
            )),
        if (clientQuery.isNotEmpty)
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('clientes').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final filteredClients = snapshot.data!.docs.where((clientDoc) {
                final clientData = clientDoc.data() as Map<String, dynamic>;
                final clientName = clientData['nombre'];
                final clientCode = clientData['codigoCliente'];

                if (selectedSearchOption == 'Nombre' && clientName is String) {
                  return clientName
                      .toLowerCase()
                      .contains(clientQuery.toLowerCase());
                } else if (selectedSearchOption == 'Código de Cliente' &&
                    clientCode is String) {
                  return clientCode
                      .toLowerCase()
                      .contains(clientQuery.toLowerCase());
                }

                return false;
              }).toList();

              if (filteredClients.isEmpty) {
                return Text(
                  'No se encontraron resultados',
                  style: TextStyle(color: Colors.white),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final clientData =
                      filteredClients[index].data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(
                      clientData['nombre'],
                      style: GoogleFonts.prompt(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        selectedClient = clientData['nombre'];
                        _clientSearchController.text = selectedClient;
                        clientQuery = '';
                      });
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductSearch() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(color: const Color.fromARGB(255, 216, 134, 134)),
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'Buscar Producto',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  productQuery = query;
                });
              },
            ),
          ),
          if (productQuery.isNotEmpty)
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final filteredProducts =
                    snapshot.data!.docs.where((productDoc) {
                  final productData = productDoc.data() as Map<String, dynamic>;
                  final productName =
                      productData['name'].toString().toLowerCase();

                  return productName.contains(productQuery.toLowerCase());
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Text(
                    'No se encontraron resultados',
                    style: TextStyle(color: Colors.white),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final productData =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    final productName = productData['name'];
                    final productImage = productData["image"];
                    print('URL de la imagen: $productImage');

                    return ListTile(
                      leading: productImage != null
                          ? CachedNetworkImage(
                              imageUrl: productImage,
                              width: 50,
                              height: 50,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(LineIcons.ad),
                            ),
                      title: Text(
                        productName,
                        style: GoogleFonts.prompt(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Precio: ${productData['price']}',
                        style: GoogleFonts.prompt(
                          color: Color.fromARGB(255, 206, 204, 204),
                        ),
                      ),
                      onTap: () {
                        final isProductSelected = selectedProducts.any(
                          (item) => item.productName == productName,
                        );

                        if (isProductSelected) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: Text('Aviso'),
                                content: Text(
                                  'El producto ya está en la lista de seleccionados.',
                                ),
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
                        } else {
                          final stock = productData["stock"] as int;
                          if (stock > 0) {
                            cantidadControllers
                                .add(TextEditingController(text: '1'));
                            setState(() {
                              selectedProducts.add(SelectedProduct(
                                  productName: productName,
                                  productImage: productImage,
                                  cantidad: 1,
                                  price: productData["price"].toDouble(),
                                  productId: ''));
                            });
                          } else {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('Aviso'),
                                  content: Text(
                                    'Este producto no tiene stock.',
                                    style: TextStyle(fontSize: 15),
                                  ),
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
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // Agregar un botón al final de la lista de productos seleccionados.
  Widget _buildSelectedProductsList() {
    final totalAmount = calculateTotalAmount();
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            'Productos Seleccionados',
            style: GoogleFonts.raleway(color: Colors.white, fontSize: 16),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: selectedProducts.length,
              itemBuilder: (context, index) {
                final selectedProduct = selectedProducts[index];

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: selectedProduct.productImage,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                        title: Text(
                          selectedProduct.productName,
                          style: GoogleFonts.arsenal(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: cantidadControllers[index],
                          onChanged: (value) {
                            setState(() {
                              selectedProduct.cantidad =
                                  int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        "assets/delete.png",
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedProducts.removeAt(index);
                          cantidadControllers.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Alinea los elementos al extremo derecho
            children: <Widget>[
              Text(
                'Total: \$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Para que el contenido sea desplazable
                    builder: (BuildContext context) {
                      return Container(
                        color: const Color.fromARGB(255, 53, 53, 53),
                        height: 600,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: TextEditingController(
                                    text:
                                        additionalInfo), // Mostrar la información almacenada
                                decoration: InputDecoration(
                                  fillColor: Color.fromARGB(255, 78, 78, 78),
                                  filled: true,
                                  labelStyle: TextStyle(color: Colors.white),
                                  labelText: 'Agregar Información',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 45, 206, 198)),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                maxLines: null,
                                onChanged: (text) {
                                  setState(() {
                                    additionalInfo =
                                        text; // Almacena la información a medida que se ingresa
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Icon(LineIcons.arrowCircleUp),
              ),
              SizedBox(width: 10), // Espacio entre los botones
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: isSaving
                    ? CircularProgressIndicator() // Muestra un indicador de carga
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSaving = true; // Activa el indicador de carga
                          });
                          saveSaleToFirestore().then((_) {
                            setState(() {
                              isSaving =
                                  false; // Desactiva el indicador de carga después de que se complete la operación
                            });
                          });
                        },
                        child: Text('Finalizar Venta'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var selectedProduct in selectedProducts) {
      total += (selectedProduct.cantidad * selectedProduct.price);
    }
    return total;
  }

  Future<void> updateProductStock(String? productId, int? newStock) async {
    if (productId != null && newStock != null) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({'stock': newStock});
      } catch (e) {
        print('Error al actualizar el stock: $e');
      }
    } else {
      print('productId o newStock es null.');
    }
  }

  Future<String?> getUserEmailFromFirestore() async {
    // Obtén el ID del usuario actual desde Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail;

    if (user != null) {
      String userID = user.uid;

      try {
        // Obtén el documento del usuario desde la colección "users"
        DocumentSnapshot userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .get();

        if (userDocument.exists) {
          final userData = userDocument.data() as Map<String, dynamic>;
          final email = userData['email'];
          if (email is String) {
            userEmail = email;
          } else {
            print('El campo "email" no es de tipo String en Firestore');
          }
        } else {
          print('El documento del usuario no existe en Firestore');
        }
      } catch (e) {
        print('Error al obtener el correo del usuario desde Firestore: $e');
      }
    } else {
      print('Usuario no autenticado');
    }

    return userEmail; // Devuelve el correo del usuario o null si no se encontró.
  }

  Future<void> saveSaleToFirestore() async {
    String? userEmail =
        await getUserEmailFromFirestore(); // Obtiene el correo del usuario

    // Comprueba si la aplicación tiene permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Si no tiene permisos, solicita al usuario que los otorgue
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el usuario deniega los permisos, muestra un mensaje y sale de la función
        print('Los permisos de ubicación fueron denegados');
        return;
      }
    }

    // Si la aplicación tiene permisos, procede a obtener la ubicación
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (selectedClient.isEmpty || selectedProducts.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Por favor, seleccione un cliente y al menos un producto antes de finalizar la venta.'),
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
      return; // Sale de la función si no se cumple la validación
    }

    // Crea un nuevo documento en la colección "ventas"
    final saleDocument = FirebaseFirestore.instance.collection('ventas').doc();

    final List<Map<String, dynamic>> productsData = [];
    for (final selectedProduct in selectedProducts) {
      // Agrega el producto a la lista de productos vendidos
      productsData.add({
        'nombre': selectedProduct.productName,
        'cantidad': selectedProduct.cantidad,
        'precio': selectedProduct.price,
      });

      // Obtén el producto correspondiente de Firestore
      final productQuerySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: selectedProduct.productName)
          .get();

      if (productQuerySnapshot.docs.isNotEmpty) {
        final productDoc = productQuerySnapshot.docs.first;
        final productData = productDoc.data() as Map<String, dynamic>;
        final stock = productData['stock'] as int;

        // Calcular el nuevo stock después de la venta
        final newStock = stock - selectedProduct.cantidad;

        // Actualizar el stock en Firestore
        updateProductStock(productDoc.id, newStock); // Pasar el ID del producto
      } else {
        print(
            'Producto no encontrado en Firestore: ${selectedProduct.productName}');
      }
    }

    // Crea un mapa con los detalles de la venta
    final saleData = {
      'clienteNombre': selectedClient,
      'montoTotal': calculateTotalAmount(),
      "vendedorCorreo": userEmail,
      'productos': productsData,
      'fechaVenta': DateTime.now(),
      'informacionAdicional': additionalInfo,
      'coordenadas': GeoPoint(
          position.latitude, position.longitude), // Guardar las coordenadas
    };

    // Guarda la venta en Firestore
    await saleDocument.set(saleData);

    // Muestra un mensaje de éxito
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Venta Guardada'),
          content: Text('La venta se ha guardado con éxito.'),
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
  }
}

class SelectedProduct {
  String productId;
  String productName;
  String productImage;
  int cantidad;
  double price;

  SelectedProduct(
      {required this.productId,
      required this.productImage,
      required this.productName,
      required this.cantidad,
      required this.price});
}
