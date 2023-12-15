import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstadisticaVentas extends StatefulWidget {
  const EstadisticaVentas({Key? key}) : super(key: key);

  @override
  State<EstadisticaVentas> createState() => _EstadisticaVentasState();
}

class _EstadisticaVentasState extends State<EstadisticaVentas> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime.now();
  DateTime _lastDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchFirstAndLastSaleDates();
  }

  fetchFirstAndLastSaleDates() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot sales = await _firestore.collection('ventas').get();

    // Crear una lista para almacenar todas las fechas de las ventas
    List<DateTime> saleDates = [];

    // Iterar sobre todos los documentos en la colección "ventas"
    for (var sale in sales.docs) {
      // Añadir la fecha de cada venta a la lista saleDates
      saleDates.add((sale.get('fechaVenta') as Timestamp).toDate());
    }

    // Ordenar la lista de fechas
    saleDates.sort();

    // Establecer _firstDay y _lastDay a la primera y última fecha en la lista
    if (saleDates.isNotEmpty) {
      setState(() {
        _firstDay = saleDates.first;
        _lastDay = saleDates.last;
        _focusedDay = saleDates.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Estadistica",
            style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: TableCalendar(
                headerStyle: HeaderStyle(
                  rightChevronIcon: Icon(LineIcons.arrowRight),
                  leftChevronIcon: Icon(LineIcons.arrowLeft),
                  formatButtonShowsNext: false,
                  formatButtonVisible: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            ElevatedButton(
              child: Text('Ver todos los días del mes'),
              onPressed: () {
                setState(() {
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.twoWeeks
                      : CalendarFormat.month;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
