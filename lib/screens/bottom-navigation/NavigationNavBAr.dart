import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ristos/screens/inventario/editar-productos.dart';
import 'package:ristos/screens/inventario/inventario-screen.dart';
import 'package:flutter/cupertino.dart';

import '../HomeScreen/NuevaVenta.dart';
import '../HomeScreen/Ventas/historial-ventas.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static List<Widget> _widgetOptions = <Widget>[
    InventarioScreen(),
    NuevaVenta(),
    ProductListScreen(),
    HistorialVentasScreen(),
  ];

  // Método que maneja el evento de retroceso en el teléfono.
  Future<bool> onWillPop() async {
    final shouldExit = await showExitConfirmationDialog(context);
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? userName = user.displayName;

      if (userName != null && userName.isNotEmpty) {
        // El nombre del usuario está disponible, puedes mostrarlo en tu AppBar o en cualquier otro lugar.
        print('Nombre del usuario: $userName');
      }
    }

    return WillPopScope(
        child: Scaffold(
          // appBar: AppBar(
          //   toolbarHeight: 30,
          //   backgroundColor:
          //       const Color.fromARGB(255, 0, 0, 0), // Color de fondo del AppBar
          //   elevation: 10, // Elevación del AppBar
          //   flexibleSpace: SafeArea(
          //     child: Container(
          //       padding: const EdgeInsets.all(
          //           12), // Espaciado interno del contenedor flexibleSpace
          //       child: Row(
          //         children: [
          //           // Agrega elementos de encabezado aquí

          //           const SizedBox(
          //               width: 16), // Espacio entre el icono y el título
          //           Text(
          //             "Hola,", // Muestra el nombre del usuario aquí
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: const Color.fromARGB(255, 116, 114, 114)!,
                  hoverColor: const Color.fromARGB(255, 136, 135, 135)!,
                  gap: 8,
                  activeColor: const Color.fromARGB(255, 63, 62, 62),
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: const Color.fromARGB(255, 241, 240, 240),
                  tabs: const [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: LineIcons.addToShoppingCart,
                      text: 'ventas',
                    ),
                    GButton(
                      icon: LineIcons.fileInvoice,
                      text: 'Products',
                    ),
                    GButton(
                      icon: LineIcons.list,
                      text: 'historial',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        onWillPop: onWillPop);
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool confirmExit = false;

  await showDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('¿Estás seguro de que deseas salir de la aplicación?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
              confirmExit = false;
            },
          ),
          CupertinoDialogAction(
            child: Text('Sí'),
            onPressed: () {
              Navigator.of(context).pop();
              confirmExit = true;
            },
          ),
        ],
      );
    },
  );

  return confirmExit;
}
