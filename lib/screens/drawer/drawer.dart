import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Drawer(
        backgroundColor: Colors.black,
        child: Padding(
          padding: EdgeInsets.only(top: padding.top),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Column(
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.black, // Cambia el color de fondo a negro
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage("assets/userDrawer.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0), // Ajusta el espaciado según tus necesidades

                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Color de fondo al presionar
                    borderRadius:
                        BorderRadius.circular(10.0), // Agrega un BorderRadius
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/egresos");
                    },
                    title: Text('Egresos',
                        style: GoogleFonts.actor(color: Colors.white)),
                    leading: Icon(
                      CupertinoIcons.increase_indent,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0), // Ajusta el espaciado según tus necesidades

                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Color de fondo al presionar
                    borderRadius:
                        BorderRadius.circular(10.0), // Agrega un BorderRadius
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/ingresos");
                    },
                    title: Text('Ingresos',
                        style: GoogleFonts.actor(color: Colors.white)),
                    leading:
                        Icon(CupertinoIcons.eyeglasses, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Color de fondo al presionar
                    borderRadius:
                        BorderRadius.circular(10.0), // Agrega un BorderRadius
                  ),
                  child: ExpansionTile(
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.red,
                    title: Text(
                      "Historial Ventas",
                      style: GoogleFonts.actor(color: Colors.white),
                    ),
                    trailing: const Icon(
                      LineIcons.arrowCircleDown,
                      color: Colors.white,
                    ),
                    leading: Icon(
                      CupertinoIcons.line_horizontal_3_decrease,
                      color: Colors.white,
                    ),
                    children: [
                      // Subítems aquí, por ejemplo:
                      ListTile(
                        title: Text('Ventas a Credito',
                            style: GoogleFonts.actor(
                                color: Color.fromARGB(255, 202, 202, 202))),
                        onTap: () {
                          Navigator.pushNamed(context, "/ventas-credito");
                        },
                      ),
                      ListTile(
                        title: Text('Ventas al Contado',
                            style: GoogleFonts.actor(
                                color: Color.fromARGB(255, 202, 202, 202))),
                        onTap: () {
                          Navigator.pushNamed(context, "/ventas-contado");
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0), // Ajusta el espaciado según tus necesidades

                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                        255, 0, 0, 0), // Color de fondo al presionar
                    borderRadius:
                        BorderRadius.circular(10.0), // Agrega un BorderRadius
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/lista-clientes");
                    },
                    title: Text('Clientes',
                        style: GoogleFonts.actor(color: Colors.white)),
                    leading: Icon(
                      CupertinoIcons.person_add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0), // Ajusta el espaciado según tus necesidades

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 0, 0, 0), // Color de fondo al presionar
                    borderRadius:
                        BorderRadius.circular(10.0), // Agrega un BorderRadius
                  ),
                  child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/estadisticas");
                      },
                      title: Text('Estadisticas',
                          style: GoogleFonts.actor(color: Colors.white)),
                      leading: const Icon(
                        CupertinoIcons.app_badge,
                        color: Colors.white,
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0), // Ajusta el espaciado según tus necesidades
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 0, 0, 0), // Color de fondo al presionar
                      borderRadius:
                          BorderRadius.circular(10.0), // Agrega un BorderRadius
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/agregar-productos");
                      },
                      title: Text('Agregar Productos',
                          style: GoogleFonts.actor(color: Colors.white)),
                      leading: const Icon(
                        CupertinoIcons.arrow_up_right_diamond,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
