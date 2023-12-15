import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ristos/screens/HomeScreen/EditProductAndClient/lista-de-clientes.dart';
import 'package:ristos/screens/inventario/add-product.dart';
import 'package:ristos/screens/inventario/inventario-screen.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          'Lista de Productos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!.docs;

          return Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(),
                    ),
                  );
                },
                child: Text('Agregar Productos'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ClientListScreen(),
                    ),
                  );
                },
                child: Text('Agregar Clientes'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    final productName = product['name'] ?? 'Nombre Desconocido';
                    final productPrice = product['price'] ?? 0.0;
                    final productImage = product['image'];
                    final productStock = product["stock"] ?? 0;
                    final productGanancia = product["gananciaPorPaquete"] ?? 0;

                    return ListTile(
                      leading: productImage != null
                          ? CachedNetworkImage(
                              imageUrl: productImage, // URL de la imagen
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(), // Widget de carga
                              errorWidget: (context, url, error) =>
                                  Icon(LineIcons.sdCard), // Widget de error
                            )
                          : Icon(Icons.image),
                      title: Text(
                        productName,
                        style: GoogleFonts.laila(
                            color: Colors.white, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio: \$${productPrice.toStringAsFixed(2)},',
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 173, 173, 173)),
                          ),
                          Text(
                            "Stock: $productStock",
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 173, 173, 173)),
                          ),
                          Text(
                            "Ganancia por Paquete: $productGanancia",
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 173, 173, 173)),
                          )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              LineIcons.edit,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              // Navegar a la pantalla de edición de producto y pasar el ID del producto
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditProductScreen(
                                      productId: products[index].id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              LineIcons.removeFormat,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Agregar la lógica para eliminar el producto aquí
                              eliminarProducto(products[index].id, context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> eliminarProducto(String productId, BuildContext context) async {
    // Mostrar un diálogo de confirmación
    final bool confirmacion = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de eliminar este producto?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // Si el usuario confirmó, eliminar el producto
    if (confirmacion == true) {
      // Obtén el producto actual de Firestore antes de eliminarlo
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);
      final productSnapshot = await productRef.get();
      final productData = productSnapshot.data() as Map<String, dynamic>;

      // Elimina el producto de Firestore
      await productRef.delete();

      // Verifica si el producto tenía una imagen asociada
      if (productData.containsKey('image')) {
        // Obtén la URL de la imagen del producto
        final imageUrl = productData['image'];

        // Divide la URL para obtener el nombre del archivo en Firebase Storage
        final imageUrlParts = imageUrl.split('/');
        final imageName = imageUrlParts.last;

        // Crea una referencia al archivo en Firebase Storage
        final storageRef =
            FirebaseStorage.instance.ref().child('product_images/$imageName');

        // Elimina el archivo de Firebase Storage
        await storageRef.delete();
      }
    }
  }
}

class EditProductScreen extends StatefulWidget {
  final String productId;

  EditProductScreen({required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController gananciaController;
  late XFile? imageFile;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    gananciaController = TextEditingController();
    imageFile = null;
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = pickedImage;
    });
  }

  _EditProductScreenState() {
    stockController =
        TextEditingController(); // Inicializa el controlador del stock
  }

  Future<String?> uploadImageToStorage(XFile imageFile) async {
    final storage = FirebaseStorage.instance;
    final Reference storageReference =
        storage.ref().child('product_images/${DateTime.now()}.jpg');
    final UploadTask uploadTask =
        storageReference.putFile(File(imageFile.path));
    final TaskSnapshot downloadUrl = await uploadTask;

    if (uploadTask.snapshot.state == TaskState.success) {
      final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            LineIcons.arrowLeft,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Editar Producto',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: nameController,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: 'Nombre de producto',
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
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: 'Precio',
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
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller:
                  stockController, // Asocia el controlador al campo de stock
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: 'Stock', // Etiqueta del campo de stock
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
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller:
                  gananciaController, // Asocia el controlador al campo de stock
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: "monto de ganancia", // Etiqueta del campo de stock
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
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Cargar Imagen'),
            ),
            if (imageFile != null)
              Image.file(
                File(imageFile!.path),
                width: 100,
                height: 100,
              )
            else
              Text('Imagen no cargada'),
            ElevatedButton(
              onPressed: () async {
                final updatedProductData = <String, dynamic>{};

                final newName = nameController.text;
                final newPrice = double.tryParse(priceController.text);
                final newStock = int.tryParse(stockController.text);
                final newGanancia = double.tryParse(gananciaController.text);

                if (newName.isNotEmpty) {
                  updatedProductData['name'] = newName;
                }
                if (newPrice != null && newPrice > 0) {
                  updatedProductData['price'] = newPrice;
                }
                if (newStock != null && newStock >= 0) {
                  updatedProductData['stock'] = newStock;
                }
                if (newGanancia != null && newGanancia >= 0) {
                  updatedProductData["gananciaPorPaquete"] = newGanancia;
                }
                if (imageFile != null) {
                  final imageUrl = await uploadImageToStorage(imageFile!);
                  if (imageUrl != null) {
                    updatedProductData['image'] = imageUrl;
                  }
                }

                if (updatedProductData.isNotEmpty) {
                  // Muestra el indicador de carga mientras se realiza la operación
                  setState(() {
                    isLoading = true;
                  });

                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.productId)
                      .update(updatedProductData);

                  // Oculta el indicador de carga una vez completada la operación
                  setState(() {
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto actualizado correctamente.'),
                    ),
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No se realizaron cambios en el producto.'),
                    ),
                  );
                }
              },
              // El contenido del botón puede ser el botón o el indicador de carga
              child: isLoading
                  ? CircularProgressIndicator() // Indicador de carga
                  : Text('Guardar Cambios'), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }
}
