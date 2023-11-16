import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedCategory = 'Todas'; // La categoría seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LineIcons.arrowCircleLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Lista de Clientes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryDropdown(), // Dropdown para seleccionar categoría
          _buildSearchBar(), // Barra de búsqueda por nombre o código
          _buildClientList(), // Lista de clientes
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // Lista de categorías disponibles
    final categories = ['Todas', 'Tarma', 'Huancayo', 'Chupaca', 'Otros'];

    return DropdownButton<String>(
      icon: Icon(LineIcons.arrowDown, color: Colors.white),
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: TextStyle(color: Color.fromARGB(255, 11, 218, 114)),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
      value: _selectedCategory,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: _searchController,
        decoration: InputDecoration(
          fillColor: Color.fromARGB(255, 54, 54, 54),
          filled: true,
          labelText: 'Buscar Cliente por Nombre o por Código',
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
        onChanged: _onSearchTextChanged,
      ),
    );
  }

  void _onSearchTextChanged(String query) {
    // Manejar cambios en el campo de búsqueda
    setState(() {
      // Tu lógica de búsqueda aquí
      // Puedes filtrar la lista de clientes en función de 'query'
      // y la categoría seleccionada '_selectedCategory'
    });
  }

  void showEditClientDialog(String clientCode) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _numeroDocumentoController =
        TextEditingController();
    final TextEditingController _lugarController = TextEditingController();
    final TextEditingController _direccionController = TextEditingController();
    final TextEditingController _tipoDocumentoController =
        TextEditingController(); // Nuevo controlador

    FirebaseFirestore.instance
        .collection('clientes')
        .where('codigoCliente', isEqualTo: clientCode)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final clientDocument = querySnapshot.docs.first;
        final clientData = clientDocument.data() as Map<String, dynamic>;

        _nameController.text = clientData['nombre'];
        _numeroDocumentoController.text = clientData['numeroDocumento'];
        _lugarController.text = clientData['lugar'];
        _direccionController.text = clientData['direccion'];
        _tipoDocumentoController.text = clientData[
            'tipoDocumento']; // Establece el valor inicial del tipo de documento

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Editar Cliente"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Nombre"),
                  ),
                  TextFormField(
                    controller: _numeroDocumentoController,
                    decoration:
                        InputDecoration(labelText: "Número de Documento"),
                  ),
                  TextFormField(
                    controller: _lugarController,
                    decoration: InputDecoration(labelText: "Lugar"),
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: InputDecoration(labelText: "Dirección"),
                  ),
                  DropdownButton<String>(
                    icon: Icon(LineIcons.arrowDown),
                    value: _tipoDocumentoController
                        .text, // Usa el valor del controlador del tipo de documento
                    items: <String>['RUC', 'DNI'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _tipoDocumentoController.text =
                            newValue!; // Establece el valor seleccionado en el controlador
                      });
                    },
                  ),
                  // Otros campos de edición aquí según tus necesidades
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Guardar"),
                  onPressed: () {
                    final newClientName = _nameController.text;
                    final newNumeroDocumento = _numeroDocumentoController.text;
                    final newLugar = _lugarController.text;
                    final newDireccion = _direccionController.text;

                    // Actualiza los datos del cliente en Firebase Firestore
                    clientDocument.reference.update({
                      'nombre': newClientName,
                      'numeroDocumento': newNumeroDocumento,
                      'lugar': newLugar,
                      'direccion': newDireccion,
                      'tipoDocumento': _tipoDocumentoController
                          .text, // Utiliza el valor del controlador del tipo de documento
                      // Agrega otros campos que desees actualizar aquí
                    }).then((value) {
                      // Muestra un mensaje de éxito o realiza otras acciones después de la actualización
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cliente actualizado correctamente.'),
                        ),
                      );
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      // Maneja el error en caso de que la actualización falle
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar el cliente.'),
                        ),
                      );
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  Widget _buildClientList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('clientes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          // Filtra la lista de clientes en función de la categoría seleccionada
          final filteredClients = snapshot.data!.docs.where((clientDoc) {
            final clientData = clientDoc.data() as Map<String, dynamic>;
            final clientCategory = clientData['lugar'];

            // Si la categoría seleccionada es "Todas", muestra todos los clientes
            return _selectedCategory == 'Todas' ||
                clientCategory == _selectedCategory;
          }).where((clientDoc) {
            final clientData = clientDoc.data() as Map<String, dynamic>;
            final clientName = clientData['nombre'];
            final clientCode = clientData['codigoCliente'];

            // Filtra los clientes en función del texto introducido en el campo de búsqueda
            return (clientName != null &&
                    clientName
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase())) ||
                (clientCode != null &&
                    clientCode
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()));
          }).toList();

          if (filteredClients.isEmpty) {
            return Center(
                child: Text('No se encontraron resultados',
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: filteredClients.length,
            itemBuilder: (context, index) {
              final clientData =
                  filteredClients[index].data() as Map<String, dynamic>;
              final clientName = clientData['nombre'];
              final clientCode = clientData['codigoCliente'];
              final clientCategory = clientData['lugar'];
              final clientDocumentId = snapshot.data?.docs[index].id;

              return ListTile(
                title: Text(
                  clientName,
                  style: GoogleFonts.labrada(color: Colors.white),
                ),
                subtitle: Text('Código: $clientCode - Lugar: $clientCategory',
                    style:
                        TextStyle(color: Color.fromARGB(255, 202, 201, 201))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(LineIcons.edit, color: Colors.white),
                      onPressed: () {
                        showEditClientDialog(clientData['codigoCliente']);
                        ;
                      },
                    ),
                    IconButton(
                      icon: Icon(LineIcons.react, color: Colors.white),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text("Eliminar Cliente"),
                              content: Text(
                                  "¿Estás seguro de que deseas eliminar este cliente?"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text("Cancelar"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text("Eliminar"),
                                  onPressed: () {
                                    // Elimina el cliente de Firebase Firestore usando el campo 'codigoCliente' como identificador
                                    _firestore
                                        .collection('clientes')
                                        .where('codigoCliente',
                                            isEqualTo:
                                                clientData['codigoCliente'])
                                        .get()
                                        .then((querySnapshot) {
                                      querySnapshot.docs.first.reference
                                          .delete();
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
