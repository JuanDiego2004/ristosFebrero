import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/cupertino.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late XFile? imageFile = null;

  final ImagePicker _picker = ImagePicker();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = pickedImage;
      });
    }
  }

  Future<void> _saveProduct() async {
    final name = nameController.text;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final stock = int.tryParse(stockController.text) ?? 0;

    if (name.isEmpty || price <= 0 || stock <= 0) {
      // Validación de campos
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.white)),
            content: Text(
              'Por favor, complete todos los campos correctamente.',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (imageFile == null) {
      // Validación de imagen
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Error al subir el archivo'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pop(); // Regresar a la pantalla anterior
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Muestra el CircularProgressIndicator mientras se guarda
    setState(() {
      isSaving = true;
    });

    // Sube la imagen a Firebase Storage y obtén su URL.
    final productId =
        DateTime.now().millisecondsSinceEpoch.toString(); // ID del producto
    final imageFileName = '$productId.jpg'; // Nombre único del archivo
    final imageUrl = await uploadImageToStorage(imageFile!, imageFileName);

    // Guarda la información del producto en Firestore.
    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'price': price,
      'stock': stock,
      'image': imageUrl,
    });

    // Muestra un mensaje de éxito y regresa a la pantalla anterior.
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Aviso'),
          content: Text('Producto registrado con éxito'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Regresar a la pantalla anterior
              },
            ),
          ],
        );
      },
    );

    // Detiene el CircularProgressIndicator
    setState(() {
      isSaving = false;
    });
  }

  // Future<void> _saveProduct() async {
  //   final name = nameController.text;
  //   final price = double.tryParse(priceController.text) ?? 0.0;
  //   final stock = int.tryParse(stockController.text) ?? 0;

  //   if (name.isEmpty || price <= 0 || stock <= 0) {
  //     // Realiza una validación básica de los campos.
  //     // Puedes agregar más validaciones según tus necesidades.
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('Error', style: TextStyle(color: Colors.white)),
  //           content: Text(
  //             'Por favor, complete todos los campos correctamente.',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text('OK', style: TextStyle(color: Colors.white)),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }

  //   if (imageFile == null) {
  //     // Asegúrate de que se haya cargado una imagen.
  //     showCupertinoDialog(
  //       context: context,
  //       builder: (context) {
  //         return CupertinoAlertDialog(
  //           title: Text('Error'),
  //           content: Text('Error al subir el archivo'),
  //           actions: <Widget>[
  //             CupertinoDialogAction(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.of(context)
  //                     .pop(); // Regresar a la pantalla anterior
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }

  //   // Muestra el CircularProgressIndicator mientras se guarda
  //   setState(() {
  //     isSaving = true;
  //   });

  //   // Sube la imagen a Firebase Storage y obtén su URL.
  //   final imageUrl =
  //       await uploadImageToStorage(imageFile!, "assets/delete.png");

  //   // Guarda la información del producto en Firestore.
  //   await FirebaseFirestore.instance.collection('products').add({
  //     'name': name,
  //     'price': price,
  //     'stock': stock,
  //     'image': imageUrl,
  //   });

  //   // Muestra un mensaje de éxito y regresa a la pantalla anterior.
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) {
  //       return CupertinoAlertDialog(
  //         title: Text('Aviso'),
  //         content: Text('Producto registrado con exito'),
  //         actions: <Widget>[
  //           CupertinoDialogAction(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.of(context).pop(); // Regresar a la pantalla anterior
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   // Detiene el CircularProgressIndicator
  //   setState(() {
  //     isSaving = false;
  //   });
  // }

  Future<String> uploadImageToStorage(
      XFile imageFile, String imageFileName) async {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('productos/$imageFileName');

    final Uint8List imageBytes = await File(imageFile.path).readAsBytes();

    await storageRef.putData(imageBytes);

    final String imageUrl = await storageRef.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // Esto cierra la pantalla actual y vuelve al screen anterior
          },
          icon: Icon(
            LineIcons.arrowLeft,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        title: Text('Agregar Producto', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: nameController,
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 54, 54, 54),
                  filled: true,
                  labelText: "Nombre del Producto",
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
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 54, 54, 54),
                  filled: true,
                  labelText: 'Precio',
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
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 54, 54, 54),
                  filled: true,
                  labelText: 'Stock',
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
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Cargar Imagen'),
            ),
            if (imageFile != null)
              if (imageFile != null)
                Image.file(
                  File(imageFile!.path),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
            Text(
              'Imagen no cargada',
              style: TextStyle(color: Colors.white),
            ),
            const Divider(),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isSaving
                  ? CircularProgressIndicator() // Muestra un indicador de progreso cuando se está guardando
                  : ElevatedButton(
                      onPressed: () {
                        if (!isSaving) {
                          // Evita que el usuario haga clic mientras se guarda
                          _saveProduct();
                        }
                      },
                      child: Text(
                        'Guardar Producto',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
