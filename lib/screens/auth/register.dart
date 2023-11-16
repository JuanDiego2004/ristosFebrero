import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ristos/screens/bottom-navigation/NavigationNavBAr.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              "assets/cool.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Fondo naranja opaco
          Positioned.fill(
            child: Container(
              color: Color.fromARGB(255, 44, 44, 44).withOpacity(0.7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/ristos_logo.png',
                    width: 110,
                    height: 110,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Inversiones Ristos E.I.R.L',
                    style: GoogleFonts.alef(
                        color: Color.fromARGB(255, 226, 223, 223),
                        fontSize: 19),
                  ),
                ],
              ),
            ),
          ),

          // Contenido en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 32, 32, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(role: "almacen")));
                      },
                      child: const Text("Encargado de almacen",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 226, 223, 223))),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 32, 32, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(role: "vendedor")));
                      },
                      child: const Text("Vendedor",
                          style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 226, 223, 223))),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 32, 32, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(role: "administrador")));
                      },
                      child: const Text(
                        "Encargado de administrador",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                  // Agrega más contenido aquí si es necesario
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String role;

  LoginScreen({required this.role});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  String? errorMessage;
  bool _obscureText = true;

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message),
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

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Verificar si el usuario existe en la colección de "users"
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userCredential.user != null) {
        // Usuario autenticado con éxito, guardar el estado de inicio de sesión.
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('userLoggedIn', true);

        if (userDoc.exists) {
          // El usuario está registrado y la autenticación es exitosa.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BottomNav()),
          );
        } else {
          // El usuario no está registrado, muestra un mensaje de advertencia.
          _showErrorDialog('Primero debes crear una cuenta.');
        }
      } else {
        // Si userCredential.user es null, indica un problema de autenticación.
        _showErrorDialog('Ocurrió un error durante el inicio de sesión.');
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Manejo de otros errores, como contraseña incorrecta.
        _showErrorDialog('Ocurrió un error durante el inicio de sesión.');
        print('Error durante el inicio de sesión: $e');
      }
      setState(() {
        isLoading = false;
      });
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
            )),
        backgroundColor: Colors.black,
        title: Text(
          'Iniciar Sesión como ${widget.role}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: emailController,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: 'Correo electronico',
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
            SizedBox(height: 10),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: passwordController,
              obscureText:
                  _obscureText, // Controla la visibilidad de la contraseña
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 54, 54, 54),
                filled: true,
                labelText: 'Contraseña',
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
                // Agrega un ícono para mostrar u ocultar la contraseña
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? LineIcons.eye : LineIcons.eyeSlash,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 90),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      loginUser().then((_) {
                        // Cuando el inicio de sesión se complete, establece isLoading en false
                        setState(() {
                          isLoading = false;
                        });
                      });
                    },
              child: isLoading
                  ? CircularProgressIndicator() // Muestra el indicador de carga
                  : Text('Iniciar Sesión'), // Muestra el texto "Iniciar Sesión"
            ),
            TextButton(
              onPressed: () {
                // Navegar a la pantalla de registro según el rol.
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegistrationScreen(role: widget.role),
                ));
              },
              child: Text(
                'Registrarse como ${widget.role}',
                style:
                    TextStyle(color: const Color.fromARGB(255, 119, 119, 119)),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  final String role;

  RegistrationScreen({required this.role});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  String? _selectedRole;
  bool _obscureText = true;

  Future<void> registerUser(String email, String password, String? selectedRole,
      String code, String name) async {
    String expectedCode; // El código esperado según el rol

    if (selectedRole == "vendedor") {
      expectedCode = "12345";
    } else if (selectedRole == "administrador") {
      expectedCode = "54321";
    } else if (selectedRole == "almacen") {
      expectedCode = "7899";
    } else {
      // Manejo de rol no válido
      return;
    }

    if (code != expectedCode) {
      // Muestra un diálogo estilo Cupertino si el código no coincide.
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content:
                Text('Código de acceso incorrecto para el rol $selectedRole.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo.
                },
              ),
            ],
          );
        },
      );
      return; // Sale de la función sin intentar el registro.
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Crear un documento en la colección "users" con el UID como identificador
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'email': email, 'role': selectedRole, "name": name});

        // Usuario autenticado con éxito, guardar el estado de inicio de sesión.
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('userLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNav(),
          ),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // El correo electrónico ya está en uso, muestra un diálogo en estilo Cupertino.
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('La cuenta ya existe. Por favor, inicia sesión.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo.
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Manejo de otros errores, puedes mostrar un mensaje de error al usuario.
        print("Error al registrar usuario: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar usuario. Inténtalo de nuevo.'),
          ),
        );
      }
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
                LineIcons.arrowCircleLeft,
                color: Colors.white,
              )),
          backgroundColor: Colors.black,
          title: Text(
            'Registro como ${widget.role}',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: nameController,
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 54, 54, 54),
                      filled: true,
                      labelText: 'Nombre',
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: emailController,
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 54, 54, 54),
                      filled: true,
                      labelText: 'Correo electronico',
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
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: passwordController,
                    obscureText:
                        _obscureText, // Controla la visibilidad de la contraseña
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 54, 54, 54),
                      filled: true,
                      labelText: 'Contraseña',
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
                      // Agrega un ícono para mostrar u ocultar la contraseña
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? LineIcons.eye : LineIcons.eyeSlash,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: codeController,
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 54, 54, 54),
                      filled: true,
                      labelText: 'Codigo ',
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
                DropdownButton<String>(
                  value: _selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  icon: Icon(
                    LineIcons.arrowDown,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.black45,
                  items: <String>['almacen', 'vendedor', 'administrador']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          SizedBox(
                              width: 10), // Espacio entre el icono y el texto
                          Text(
                            'Rol: $value',
                            style: TextStyle(
                                color: const Color.fromARGB(
                                    255, 255, 255, 255)), // Color del texto
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  hint: Text(
                    'Selecciona un rol',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 90),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          String roleCode = codeController.text;

                          if (roleCode.isEmpty) {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'El campo de código de acceso está vacío.'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text('Aceptar'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              isLoading =
                                  true; // Establece isLoading en true para mostrar el indicador de carga
                            });

                            registerUser(
                              emailController.text,
                              passwordController.text,
                              _selectedRole,
                              roleCode,
                              nameController.text,
                            ).then((_) {
                              // Cuando el registro se complete, establece isLoading en false
                              setState(() {
                                isLoading = false;
                              });
                            });
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator() // Muestra el indicador de carga
                      : Text('Registrarse'), // Muestra el texto "Registrarse"
                ),
              ],
            ),
          ),
        ));
  }
}
