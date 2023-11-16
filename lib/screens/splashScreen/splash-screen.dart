import 'dart:async';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../HomeScreen/home-screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      // Navegar a la HomeScreen después de 2 segundos.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckAuthState(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Personaliza el color de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Puedes agregar un logotipo o una imagen de SplashScreen aquí
            Image.asset(
              'assets/logo_app.jpeg', // Ruta de la imagen de SplashScreen
              width: 150.0, // Personaliza el tamaño de la imagen
              height: 150.0,
            ),
            SizedBox(height: 20.0), // Espacio entre la imagen y el texto
            Text(
              'Mi Aplicación', // Cambia el texto según tu marca
              style: TextStyle(
                color: Colors.white, // Personaliza el color del texto
                fontSize: 24.0, // Personaliza el tamaño del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}
