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

  int currentStock = 0;

  String selectedSearchOption =
      'Nombre'; // Establece un valor predeterminado, por ejemplo, 'Nombre'.

  TextEditingController _cantidadController = TextEditingController();

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
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        appBar: AppBar(
          toolbarHeight: 40,
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
                                  originalPrice:
                                      productData["price"].toDouble(),
                                  productId: '',
                                  stock: stock,
                                  modifiedPrice:
                                      productData["price"].toDouble()));
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      selectedProduct.productName,
                      style: GoogleFonts.arsenal(
                          color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(
                        height:
                            10), // Espacio entre el nombre y la información abajo
                    Row(
                      children: <Widget>[
                        CachedNetworkImage(
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
                        SizedBox(
                            width: 10), // Espacio entre la imagen y la cantidad

                        SizedBox(
                          width: 50,
                          height: 40,
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                int newCantidad = int.tryParse(value) ?? 0;

                                // Verificar si el nuevo valor de cantidad es válido
                                if (newCantidad > selectedProduct.stock) {
                                  // Si la nueva cantidad no es válida, mostrar alerta y dejar la cantidad en 0
                                  showStockErrorDialog();
                                  selectedProduct.cantidad = 0;
                                } else {
                                  // Actualizar la cantidad
                                  selectedProduct.cantidad = newCantidad;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                            width: 10), // Espacio entre la cantidad y el precio
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue:
                                selectedProduct.modifiedPrice.toString(),
                            onChanged: (value) {
                              setState(() {
                                selectedProduct.modifiedPrice =
                                    double.tryParse(value) ??
                                        selectedProduct.originalPrice;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 70),
                        Text(
                          'Stock: ${selectedProduct.stock}', // Asegúrate de tener la propiedad 'stock' en tu clase SelectedProduct
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ), // Espacio entre los inputs y el icono
                        IconButton(
                          icon: Image.asset(
                            "assets/delete.png",
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedProducts.removeAt(index);
                              cantidadControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    Divider(), // Separador entre los productos
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Alinea los elementos al extremo derecho
            children: <Widget>[
              FutureBuilder<double>(
                future: calculateTotalProfit(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Mientras se espera, puedes mostrar un indicador de carga o algún mensaje
                    return const Text(
                      'Calculando utilidad...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Si hay un error, puedes mostrar un mensaje de error
                    return const Text(
                      'Error al calcular utilidad',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    // Si todo está bien, muestra el resultado
                    double totalProfit = snapshot.data ?? 0.0;
                    return Column(
                      children: [
                        Text(
                          'Total: \$${totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.mPlus1Code(
                              color: Colors.cyan, fontSize: 16),
                        ),
                        Text(
                          '  Utilidad: \$${totalProfit.toStringAsFixed(2)}',
                          style: GoogleFonts.mPlus1Code(
                              color: Colors.cyan, fontSize: 16),
                        ),
                      ],
                    );
                  }
                },
              ),

              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Para que el contenido sea desplazable
                    builder: (BuildContext context) {
                      return Container(
                        color: Color.fromARGB(255, 44, 44, 44),
                        height: 600,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Agregar Informacion Adicional",
                                style: GoogleFonts.lato(
                                    color:
                                        const Color.fromARGB(255, 231, 211, 32),
                                    fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: TextEditingController(
                                    text:
                                        additionalInfo), // Mostrar la información almacenada
                                decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromARGB(255, 78, 78, 78),
                                  filled: true,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
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
                icon: const Icon(
                  CupertinoIcons.arrow_up,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los botones
              AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isSaving
                      ? const CircularProgressIndicator() // Muestra un indicador de carga
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isSaving = true;
                            });

                            bool? isVentaAlContado =
                                await showConfirmationDialog();

                            if (isVentaAlContado != null) {
                              if (isVentaAlContado) {
                                double? montoInicial =
                                    await showMontoInicialDialog();
                                if (montoInicial != null) {
                                  await saveVentaAlCreditoToFirestore(
                                      montoInicial);
                                }
                              } else {
                                await saveSaleAlContadoToFirestore(
                                    isVentaAlContado); // Pasa el valor correcto
                              }
                            }

                            setState(() {
                              isSaving = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // Color del texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Bordes redondeados
                            ),
                            elevation: 3.0, // Elevación del botón
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0), // Padding
                          ),
                          child: Text(
                            'Realizar Venta',
                            style: GoogleFonts.lato(
                                color: Colors.white, fontSize: 17),
                          ),
                        )),
            ],
          ),
        ],
      ),
    );
  }

  void showStockErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Error de stock'),
          content:
              const Text('La cantidad ingresada es mayor al stock disponible.'),
          actions: <Widget>[
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
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var selectedProduct in selectedProducts) {
      // Usa el precio modificado si está presente y no es nulo, de lo contrario, usa el precio original
      final priceToUse = selectedProduct.modifiedPrice != null
          ? selectedProduct.modifiedPrice!
          : selectedProduct.originalPrice;

      total += (selectedProduct.cantidad * priceToUse);
    }
    return total;
  }

  Future<double> calculateTotalProfit() async {
    double totalProfit = 0.0;

    for (var selectedProduct in selectedProducts) {
      try {
        // Realiza la consulta a Firestore para obtener el precio de ganancia por paquete
        var productQuerySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: selectedProduct.productName)
            .get();

        if (productQuerySnapshot.docs.isNotEmpty) {
          // Obtiene los datos del producto
          var productData =
              productQuerySnapshot.docs.first.data() as Map<String, dynamic>;

          // Obtiene el precio por paquete del producto
          var packagePrice = productData['gananciaPorPaquete'] ?? 0.0;

          // Calcula la utilidad por paquete para este producto
          var productProfit = (packagePrice) * selectedProduct.cantidad;

          // Suma la utilidad de este producto al total
          totalProfit += productProfit;
        } else {
          print(
              'Producto no encontrado en Firestore: ${selectedProduct.productName}');
        }
      } catch (e) {
        print('Error al calcular la utilidad: $e');
      }
    }

    return totalProfit;
  }

  /* funciones de stock */
  Future<int?> updateProductStock(String productId, int newStock) async {
    try {
      // Construye la referencia al documento del producto en la colección "productos"
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);

      // Actualiza el stock del producto en Firestore
      await productRef.update({'stock': newStock});

      print(
          'Stock actualizado para el producto con ID $productId. Nuevo stock: $newStock');

      return newStock; // Devuelve el nuevo valor del stock
    } catch (e) {
      print('Error al actualizar el stock del producto con ID $productId: $e');
      // Puedes manejar este error según tus necesidades.
      return null; // Devuelve null en caso de error
    }
  }

  Future<void> obtenerStockActual(String productId) async {
    // Llama a la función para obtener el stock actual
    int? stockObtenido = await updateProductStock(productId, 0);

    // Actualiza this.currentStock con el valor obtenido
    this.currentStock = stockObtenido ?? 0;
  }

  /* ----- */

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

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  Future<bool?> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            '¿Venta a crédito?',
            style: TextStyle(fontSize: 16),
          ),
          content: const Text(
              '¿Esta venta es credito?, si no lo es selcciona "no", para realizar la venta al contado',
              style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true); // Venta al contado
              },
              child: Text('Sí'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false); // Venta a crédito
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<double?> showMontoInicialDialog() async {
    TextEditingController montoController = TextEditingController();

    return await showCupertinoDialog<double>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Monto Inicial'),
          content: Column(
            children: [
              Text('Ingrese el monto inicial:'),
              CupertinoTextField(
                controller: montoController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(
                  double.tryParse(montoController.text),
                );
              },
              child: Text('Hacer Venta'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveVentaAlCreditoToFirestore(double montoInicial) async {
    String? userEmail = await getUserEmailFromFirestore();

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
      desiredAccuracy: LocationAccuracy.high,
    );

    if (selectedClient.isEmpty || selectedProducts.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'Por favor, seleccione un cliente y al menos un producto antes de finalizar la venta.',
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
      return; // Sale de la función si no se cumple la validación
    }

    DateTime currentDate = DateTime.now();

    // Obtén el número del mes actual
    int monthNumber = currentDate.month;
    String formattedMonth = monthNumber.toString().padLeft(2, '0');

    // Calcula la semana actual del mes (considerando que un mes tiene 4 semanas)
    int weekNumber = ((currentDate.day - 1) ~/ 7) + 1;

    // Construye la parte del camino correspondiente al mes en el formato deseado
    String monthPath = '${currentDate.year}-$formattedMonth';

    // Construye el camino completo de la colección para ventasCredito
    String salesPathCredito = 'ventasCredito/$monthPath/semana$weekNumber';

    // Construye el camino completo de la colección para ventasRistos
    String salesPathRistos = 'ventasRistos/$monthPath/semana$weekNumber';

    // Guarda en ambas colecciones
    await saveSaleToCollection(
        salesPathCredito, userEmail, position, montoInicial);
    await saveSaleToCollection(
        salesPathRistos, userEmail, position, montoInicial);
  }

  Future<void> saveSaleToCollection(String salesPath, String? userEmail,
      Position position, double montoInicial) async {
    // Obtén una referencia a la colección
    final saleDocument = FirebaseFirestore.instance.collection(salesPath);

    final List<Map<String, dynamic>> productsData = [];
    for (final selectedProduct in selectedProducts) {
      // Agrega el producto a la lista de productos vendidos
      productsData.add({
        'nombre': selectedProduct.productName,
        'cantidad': selectedProduct.cantidad,
        'precio': selectedProduct.modifiedPrice != 0.0
            ? selectedProduct.modifiedPrice
            : selectedProduct.originalPrice,
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

    // Añade el monto inicial al mapa de datos
    final saleData = {
      'clienteNombre': selectedClient,
      'montoTotal': calculateTotalAmount(),
      'utilidad': await calculateTotalProfit(),
      'montoInicial': montoInicial,
      "vendedorCorreo": userEmail,
      'productos': productsData,
      'fechaVenta': DateTime.now(),
      'informacionAdicional': additionalInfo,
      'coordenadas': GeoPoint(
          position.latitude, position.longitude), // Guardar las coordenadas
    };

    // Guarda la venta en Firestore
    await saleDocument.add(saleData);

    // Muestra un mensaje de éxito
    // ignore: use_build_context_synchronously
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Venta Guardada'),
          content: const Text('La venta se ha guardado con éxito.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveSaleAlContadoToFirestore(bool isVentaCredito) async {
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

    DateTime currentDate = DateTime.now();

    // Obtén el número del mes actual
    int monthNumber = currentDate.month;
    String formattedMonth = monthNumber.toString().padLeft(2, '0');

    // Calcula la semana actual del mes (considerando que un mes tiene 4 semanas)
    int weekNumber = ((currentDate.day - 1) ~/ 7) + 1;

    // Construye la parte del camino correspondiente al mes en el formato deseado
    String monthPath = '${currentDate.year}-$formattedMonth';

    // Construye el camino completo de la colección
    String salesPath;
    if (isVentaCredito) {
      // Construye el camino completo de la colección para ventasCredito
      salesPath = 'ventasCredito/$monthPath/semana$weekNumber';
    } else {
      // Construye el camino completo de la colección para ventasRistos
      salesPath = 'ventasRistos/$monthPath/semana$weekNumber';
    }
    // Obtén una referencia a la colección
    final saleDocument = FirebaseFirestore.instance.collection(salesPath);

    // Crea un nuevo documento en la colección "ventas"
    // final saleDocument = FirebaseFirestore.instance.collection('ventas').doc();

    final List<Map<String, dynamic>> productsData = [];
    for (final selectedProduct in selectedProducts) {
      // Agrega el producto a la lista de productos vendidos
      productsData.add({
        'nombre': selectedProduct.productName,
        'cantidad': selectedProduct.cantidad,
        'precio': selectedProduct.modifiedPrice != 0.0
            ? selectedProduct.modifiedPrice
            : selectedProduct.originalPrice,
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
      'utilidad': await calculateTotalProfit(),
      "vendedorCorreo": userEmail,
      'productos': selectedProducts.map((product) {
        return {
          'nombre': product.productName,
          'cantidad': product.cantidad,
          'precio': product.modifiedPrice != 0.0
              ? product.modifiedPrice
              : product.originalPrice,
        };
      }).toList(),
      'fechaVenta': DateTime.now(),
      'informacionAdicional': additionalInfo,
      'coordenadas': GeoPoint(
          position.latitude, position.longitude), // Guardar las coordenadas
    };

    // Guarda la venta en Firestore
    await saleDocument.add(saleData);

    // Muestra un mensaje de éxito
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Venta Guardada'),
          content: const Text('La venta se ha guardado con éxito.'),
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

  String _getDayOfWeek(DateTime date) {
    // Obtiene el día de la semana en español
    List<String> weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];
    return weekdays[date.weekday - 1];
  }

//
}

class SelectedProduct {
  String productId;
  String productName;
  String productImage;
  int cantidad;
  double originalPrice;
  double modifiedPrice;
  int stock;

  SelectedProduct({
    required this.productId,
    required this.productImage,
    required this.productName,
    required this.cantidad,
    required this.originalPrice,
    this.modifiedPrice = 0.0,
    required this.stock,
  });
}
