import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ristos/screens/BarraEstadistica/BarraEstadistica.dart';
import 'package:ristos/screens/HomeScreen/EditProductAndClient/lista-de-clientes.dart';
import 'package:ristos/screens/HomeScreen/NuevaVenta.dart';
import 'package:ristos/screens/HomeScreen/Ventas/Contado/historial-ventas.dart';
import 'package:ristos/screens/HomeScreen/Ventas/Credito/HistorialVentasCredito.dart';
import 'package:ristos/screens/IngresosEgresos/EgresosScreen.dart';
import 'package:ristos/screens/IngresosEgresos/IngresosScreen.dart';
import 'package:ristos/screens/auth/register.dart';
import 'package:ristos/screens/bottom-navigation/NavigationNavBAr.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ristos/screens/inventario/add-product.dart';
import 'package:ristos/screens/inventario/inventario-screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 8));
  FlutterNativeSplash.remove();
  await Firebase.initializeApp();
  //pesistencia firestore pero da error
  //await FirebaseFirestore.instance.enablePersistence();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CheckAuthState(),
      routes: {
        '/inicio': (context) => InventarioScreen(),
        '/buscar': (context) => NuevaVenta(),
        '/configuracion': (context) => HistorialVentasScreen(),
        '/historial': (context) => HistorialVentasScreen(),
        "/egresos": (context) => EgresosScreen(),
        "/ingresos": (context) => IngresosScreen(),
        "/estadisticas": (context) => BarraEstadistica(),
        "/ventas-contado": (context) => HistorialVentasScreen(),
        "/ventas-credito": (context) => HistorialVentaCreditoScreen(),
        "/agregar-productos": (context) => AddProductScreen(),
        "/lista-clientes": (context) => ClientListScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class CheckAuthState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return AuthenticationScreen();
          } else {
            return BottomNav();
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
