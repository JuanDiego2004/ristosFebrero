import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ristos/screens/HomeScreen/EditProductAndClient/lista-de-clientes.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Product {
  final String name;
  final double price;
  final String imageUrl;
  final int stock;

  Product({
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });
}

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  bool isLoading = true; // Agregado

  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() {
      isLoading = true;
    });
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    final List<Product> loadedProducts = [];
    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      loadedProducts.add(Product(
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['image'] ?? '',
          stock: (data['stock'] as int?) ?? 0));
    });

    setState(() {
      _products = loadedProducts;
      isLoading = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterProducts('');
  }

  void _filterProducts(String query) {
    final filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = filteredProducts;
    });
  }

  // // Función para ordenar y guardar las ventas en la colección "ventasOrdenadas"
  // Future<void> orderAndSaveSales() async {
  //   try {
  //     // Obtén todas las ventas ordenadas por fecha
  //     List<DocumentSnapshot> sortedSales = await getSalesOrderedByDate();

  //     // Guarda las ventas ordenadas en la colección "ventasOrdenadas"
  //     for (var sale in sortedSales) {
  //       DateTime fechaVenta = (sale['fechaVenta'] as Timestamp).toDate();
  //       String formattedDate =
  //           '${fechaVenta.year}-${_twoDigits(fechaVenta.month)}';

  //       // Agrega las ventas al documento correspondiente en "ventasOrdenadas"
  //       await FirebaseFirestore.instance
  //           .collection('ventasOrdenadas')
  //           .doc(formattedDate)
  //           .collection('ventas')
  //           .add({
  //         'venta': sale.id,
  //         'clienteNombre': sale['clienteNombre'],
  //         'coordenadas': sale['coordenadas'],
  //         'facturada': sale['facturada'],
  //         'fechaVenta': sale['fechaVenta'],
  //         'informacionAdicional': sale['informacionAdicional'],
  //         'montoTotal': sale['montoTotal'],
  //       });
  //     }

  //     print('Ventas ordenadas y guardadas correctamente.');
  //   } catch (e) {
  //     print('Error al ordenar y guardar las ventas: $e');
  //     // Puedes manejar el error de la forma que prefieras
  //   }
  // }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // Función para obtener las ventas ordenadas por fecha
  Future<List<DocumentSnapshot>> getSalesOrderedByDate() async {
    try {
      // Realiza una consulta a la colección "ventas" ordenando por la fechaVenta
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ventas')
          .orderBy('fechaVenta', descending: true)
          .get();

      // Devuelve los documentos ordenados por fecha
      return querySnapshot.docs;
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir
      print('Error al obtener las ventas: $e');
      throw e; // Puedes manejar el error de la forma que prefieras
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Lista de Productos',
          style: GoogleFonts.concertOne(fontSize: 22, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                LineIcons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _clearSearch();
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar productos",
                  hintStyle: GoogleFonts.nunitoSans(
                      fontSize: 17,
                      color: const Color.fromARGB(255, 255, 255, 255)),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 113, 113, 114),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(
                    LineIcons.search,
                    color: Colors.white,
                  ),
                ),
                onChanged: (query) {
                  _filterProducts(query);
                },
              ),
            ),
          Visibility(
            visible: !isLoading,
            child: Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 264,
                  childAspectRatio: 1, // Ajusta según tus necesidades
                ),
                itemCount:
                    _isSearching ? _filteredProducts.length : _products.length,
                itemBuilder: (ctx, index) {
                  final product = _isSearching
                      ? _filteredProducts[index]
                      : _products[index];
                  return Card(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  height: 200,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                product.name,
                                style: GoogleFonts.akatab(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Alinear a la derecha
                                children: [
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.alatsi(
                                      fontSize: 17,
                                      color:
                                          const Color.fromARGB(255, 29, 28, 28),
                                    ),
                                  ),
                                  Text(
                                    'Stock: ${product.stock}', // Mostrar la cantidad de stock
                                    style: GoogleFonts.alatsi(
                                      fontSize: 17,
                                      color:
                                          const Color.fromARGB(255, 29, 28, 28),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Visibility(
            visible:
                isLoading, // Muestra el indicador de carga si isLoading es true
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
