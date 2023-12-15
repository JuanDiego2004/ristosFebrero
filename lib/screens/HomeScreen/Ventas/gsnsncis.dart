import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_icons/line_icons.dart';

class GananciasScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> sales;
  final DateTime selectedDate;

  GananciasScreen({required this.sales, required this.selectedDate});

  double calcularGananciasDiarias() {
    double gananciasDiarias = 0;

    // Filtrar las ventas por la fecha seleccionada
    List<QueryDocumentSnapshot> ventasDiarias = sales.where((venta) {
      final fechaVenta = venta['fechaVenta'] as Timestamp;
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(fechaVenta.toDate());
      return formattedDate == DateFormat('yyyy-MM-dd').format(selectedDate);
    }).toList();

    // Sumar los montos totales de las ventas filtradas
    gananciasDiarias = ventasDiarias
        .map((venta) => (venta['montoTotal'] ?? 0.0) as double)
        .fold(0, (prev, monto) => prev + monto);

    return gananciasDiarias;
  }

  String formatearComoMoneda(double monto) {
    // Formatear el monto con comas y puntos
    return NumberFormat.currency(
      symbol:
          '\$', // Puedes cambiar el símbolo de la moneda según tus necesidades
      decimalDigits: 2,
    ).format(monto);
  }

  Future<void> exportarExcel(BuildContext buildContext) async {
    try {
      var excel = Excel.createExcel();

      // Cambia el título de la hoja según tus necesidades
      var hoja = excel['VentasDiarias'];

      // Reemplaza 'sales' con la estructura de tus datos reales
      List<List<dynamic>> data = [
        ['Nombre', 'Monto'],
        for (var venta in sales)
          [
            venta['clienteNombre'] ?? 'Nombre Desconocido',
            (venta['montoTotal'] ?? 0.0) as double,
          ],
      ];

      for (var row in data) {
        hoja.appendRow(row);
      }

      // Generar el nombre del archivo con la fecha actual
      var formatoFecha = DateFormat('yyyy_MM_dd');
      var fechaActual = formatoFecha.format(DateTime.now());

      // Obtener o crear el directorio
      var directorioVentas = Directory('/storage/emulated/0/ventas_ristos');
      if (!await directorioVentas.exists()) {
        print('El directorio no existe, creándolo...');
        await directorioVentas.create(recursive: true);
      }

      // Buscar archivos existentes con la misma fecha
      var archivosExistentes = directorioVentas.listSync();
      var archivosMismaFecha = archivosExistentes.where((archivo) {
        return archivo is File && archivo.path.contains('ventas_$fechaActual');
      }).toList();

      // Obtener el índice para el nuevo archivo
      var nuevoIndice = archivosMismaFecha.length + 1;

      // Generar el nombre del archivo con el índice
      var nombreArchivo =
          'ventas_$fechaActual${nuevoIndice > 1 ? '_$nuevoIndice' : ''}.xlsx';

      // Combinar el directorio y el nombre del archivo para obtener la ruta completa
      var ruta = join(directorioVentas.path, nombreArchivo);
      print('Ruta completa del archivo: $ruta');
      // Mostrar un mensaje si no se otorgan permisos
      bool permissionStatus;
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      if (deviceInfo.version.sdkInt > 32) {
        permissionStatus = await Permission.photos.request().isGranted;
      } else {
        permissionStatus = await Permission.storage.request().isGranted;
      }

      if (!permissionStatus) {
        // Muestra un mensaje al usuario
        ScaffoldMessenger.of(buildContext).showSnackBar(
          SnackBar(
            content: Text('No se otorgaron los permisos necesarios.'),
          ),
        );
        return; // Sal del método si no se otorgaron permisos
      }

      // Escribir los datos en el archivo
      var archivo = File(ruta);
      var bytes = excel.encode();

      if (bytes != null) {
        await archivo.writeAsBytes(bytes, flush: true);
        print('Excel exportado correctamente a: $ruta');

        // Muestra un diálogo para confirmar si desea compartir el archivo
        showDialog(
          context: buildContext,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('¿Desea compartir el archivo?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Cierra el diálogo antes de compartir
                    Navigator.of(dialogContext).pop();

                    // Compartir el archivo a través de WhatsApp
                    await Share.shareFiles(
                      [ruta],
                      text:
                          'Adjunto el archivo de ventas para el día ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    );
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    // Cierra el diálogo si no desea compartir
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancelar'),
                ),
              ],
            );
          },
        );
      } else {
        print('Error al exportar: la lista de bytes es nula.');
      }
    } catch (e) {
      print('Error durante la exportación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String gananciasDiariasFormateadas =
        formatearComoMoneda(calcularGananciasDiarias());

    return Scaffold(
      appBar: AppBar(
        title: Text('Ganancias'),
        actions: [
          IconButton(
            icon: Icon(LineIcons.fileDownload),
            onPressed: () async {
              await exportarExcel(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganancias Diarias para ${DateFormat('yyyy-MM-dd').format(selectedDate)}:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              gananciasDiariasFormateadas,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
