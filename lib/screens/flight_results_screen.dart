import 'package:elective3project/screens/select_bundle_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:elective3project/database/database_helper.dart';

class FlightResultsScreen extends StatefulWidget {
  final String tripType;
  // Flight 1
  final String origin;
  final String destination;
  final DateTime departureDate;
  // Flight 2 (for multi-city)
  final String? origin2;
  final String? destination2;
  final DateTime? departureDate2;
  // Return date (for round-trip)
  final DateTime? returnDate;

  const FlightResultsScreen({
    super.key,
    required this.tripType,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.origin2,
    this.destination2,
    this.departureDate2,
  });

  @override
  _FlightResultsScreenState createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _dates = [];
  List<Map<String, dynamic>> _flights = [];
  DateTime? _selectedDate;
  final Random _random = Random();
  bool _isCalendarLoading = true;
  bool _isFlightLoading = false;

  Map<String, dynamic>? _selectedFlight1;
  late String _currentOrigin;
  late String _currentDestination;
  late String _currentSelectionMode; // 'flight1', 'flight2', or 'return'

  @override
  void initState() {
    super.initState();
    _initializeSelection();
    _loadInitialData();
  }

  void _initializeSelection() {
    _currentOrigin = widget.origin;
    _currentDestination = widget.destination;
    _selectedDate = widget.departureDate;
    
    if (widget.tripType == 'multi city') {
      _currentSelectionMode = 'flight1';
    } else {
      _currentSelectionMode = 'departure'; // For one-way and round-trip
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isCalendarLoading = true;
    });
    await _updateCalendarAndFlightsForDate(widget.departureDate);
    if (mounted) {
      setState(() {
        _isCalendarLoading = false;
      });
    }
  }

  Future<void> _updateCalendarAndFlightsForDate(DateTime centerDate) async {
    if (!mounted) return;
    setState(() {
      _isCalendarLoading = true;
    });
    final loadedDates = await _loadCalendarDates(centerDate);
    if (!mounted) return;
    setState(() {
      _dates = loadedDates;
      _isCalendarLoading = false;
      _selectedDate = centerDate; 
    });
    await _loadFlightsForDate(centerDate);
  }

  Future<List<Map<String, dynamic>>> _loadCalendarDates(DateTime centerDate) async {
    final List<Map<String, dynamic>> dates = [];
    final dest = _currentSelectionMode == 'flight2' ? widget.destination2! : widget.destination;
    for (int i = -5; i <= 5; i++) {
      final date = centerDate.add(Duration(days: i));
      double? price = await dbHelper.getDailyPrice(date, dest);
      dates.add({'date': date, 'price': price == -1.0 ? null : price});
    }
    return dates;
  }

  Future<void> _loadFlightsForDate(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _selectedDate = date;
      _isFlightLoading = true;
      _flights = [];
    });
    
    final dest = _currentSelectionMode == 'flight2' ? widget.destination2! : widget.destination;

    final dateInfo = _dates.firstWhere(
      (d) => (d['date'] as DateTime).isAtSameMomentAs(date),
      orElse: () => {'price': null},
    );

    if (dateInfo['price'] == null) {
      if (mounted) setState(() => _isFlightLoading = false);
      return;
    }

    List<Map<String, dynamic>> flightsForUi = [];
    var flightsFromDb = await dbHelper.getFlights(date, dest);

    if (flightsFromDb.isNotEmpty) {
      flightsForUi = flightsFromDb.map((dbFlight) {
        try {
          return {
            'startTime': DateTime.parse(dbFlight['departureTime'] as String),
            'endTime': DateTime.parse(dbFlight['arrivalTime'] as String),
            'duration': int.parse(dbFlight['duration'] as String),
            'price': dbFlight['price'] as double,
          };
        } catch (e) {
          return null;
        }
      }).where((flight) => flight != null).cast<Map<String, dynamic>>().toList();
    } else {
      flightsForUi = List.generate(5, (index) {
        final int startHour = _random.nextInt(20) + 4;
        final int startMinute = _random.nextInt(60);
        final DateTime startTime = DateTime(date.year, date.month, date.day, startHour, startMinute);
        final int durationMinutes = _random.nextInt(60) + 60;
        final DateTime endTime = startTime.add(Duration(minutes: durationMinutes));
        final double price = 1500 + _random.nextDouble() * 8000;
        return {'startTime': startTime, 'endTime': endTime, 'duration': durationMinutes, 'price': price};
      });
      final List<Map<String, dynamic>> flightsToSave = flightsForUi.map((f) => {
            'departureTime': f['startTime'].toIso8601String(),
            'arrivalTime': f['endTime'].toIso8601String(),
            'duration': f['duration'].toString(),
            'price': f['price'],
      }).toList();
      await dbHelper.saveFlights(date, dest, flightsToSave);
    }

    if (mounted) {
      setState(() {
        _flights = flightsForUi;
        _isFlightLoading = false;
      });
    }
  }

  void _handleFlightTap(Map<String, dynamic> tappedFlight) {
    if (widget.tripType == 'multi city') {
      if (_currentSelectionMode == 'flight1') {
        _selectedFlight1 = tappedFlight;
        setState(() {
          _currentSelectionMode = 'flight2';
          _currentOrigin = widget.origin2!;
          _currentDestination = widget.destination2!;
          _selectedDate = widget.departureDate2!;
        });
        _updateCalendarAndFlightsForDate(widget.departureDate2!);
      } else { // 'flight2'
        _navigateToSelectBundle(departure: _selectedFlight1!, returnF: tappedFlight);
      }
    } else { // One way or Round trip
      if (_currentSelectionMode == 'departure') {
        _selectedFlight1 = tappedFlight;
        if (widget.tripType == 'round trip' && widget.returnDate != null) {
          setState(() {
            _currentSelectionMode = 'return';
            _currentOrigin = widget.destination; // Swap for return
            _currentDestination = widget.origin;
            _selectedDate = widget.returnDate!;
          });
          _updateCalendarAndFlightsForDate(widget.returnDate!);
        } else {
          _navigateToSelectBundle(departure: tappedFlight);
        }
      } else { // 'return'
        _navigateToSelectBundle(departure: _selectedFlight1!, returnF: tappedFlight);
      }
    }
  }

  void _navigateToSelectBundle({required Map<String, dynamic> departure, Map<String, dynamic>? returnF}) {
     DateTime? finalReturnDate = widget.tripType == 'multi city' ? widget.departureDate2 : widget.returnDate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectBundleScreen(
          departureFlight: departure,
          returnFlight: returnF,
          tripType: widget.tripType,
          origin: widget.origin, 
          destination: widget.destination,
          origin2: widget.origin2,
          destination2: widget.destination2,
          departureDate: widget.departureDate,
          returnDate: finalReturnDate,
        ),
      ),
    );
  }

  String _formatDuration(int totalMinutes) {
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return '${hours}H ${minutes}M';
  }

  String _getHeaderText() {
    if (widget.tripType == 'multi city') {
      return _currentSelectionMode == 'flight1' ? 'Select Flight 1' : 'Select Flight 2';
    }
    return _currentSelectionMode == 'departure' ? 'Select your departing flight' : 'Select your return flight';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000080),
        title: Row(children: [Image.asset('assets/images/logo.png', height: 30, errorBuilder: (c, e, s) => const Icon(Icons.flight_takeoff, color: Colors.white)), const SizedBox(width: 8), const Text('FLYQUEST', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))]),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_getHeaderText(), style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentOrigin, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(width: 8),
                      const Icon(Icons.airplanemode_active, color: Colors.black87, size: 24),
                      const SizedBox(width: 8),
                      Text(_currentDestination, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), child: Text('Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            SizedBox(
              height: 90,
              child: _isCalendarLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final dateInfo = _dates[index];
                        final DateTime date = dateInfo['date'];
                        final double? price = dateInfo['price'];
                        final bool isSelected = _selectedDate != null && _selectedDate!.isAtSameMomentAs(date);
                        return GestureDetector(
                          onTap: () => _loadFlightsForDate(date),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                            decoration: BoxDecoration(color: isSelected ? Colors.blue.shade100 : Colors.white, borderRadius: BorderRadius.circular(12.0), border: Border.all(color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))]),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('MMM d').format(date), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade900 : Colors.black87)), const SizedBox(height: 8), Text(price != null ? '₱${NumberFormat('#,##0').format(price)}' : 'N/A', style: TextStyle(fontSize: 12, color: price != null ? Colors.green.shade800 : Colors.red.shade700, fontWeight: price != null ? FontWeight.bold : FontWeight.normal))]),
                          ),
                        );
                      },
                    ),
            ),
            const Padding(padding: EdgeInsets.all(16.0), child: Text('Flights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
            Expanded(
              child: _isFlightLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _flights.isEmpty
                      ? const Center(child: Text('No flights available for this date.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: _flights.length,
                          itemBuilder: (context, index) {
                            final flight = _flights[index];
                            final DateTime startTime = flight['startTime'];
                            final DateTime endTime = flight['endTime'];
                            final int duration = flight['duration'];
                            final double price = flight['price'];
                            return Card(
                              elevation: 4.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              child: InkWell(
                                onTap: () => _handleFlightTap(flight),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [Text(DateFormat.jm().format(startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), Transform.rotate(angle: 0.785398, child: const Icon(Icons.airplanemode_active, color: Colors.grey, size: 20)), const SizedBox(width: 8), Text(DateFormat.jm().format(endTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                                            const SizedBox(height: 8),
                                            Row(children: [const Icon(Icons.flight_takeoff, color: Colors.grey, size: 20), const SizedBox(width: 4), Text(_currentOrigin, style: const TextStyle(color: Colors.grey)), const SizedBox(width: 8), const Icon(Icons.flight_land, color: Colors.grey, size: 20), const SizedBox(width: 4), Text(_currentDestination, style: const TextStyle(color: Colors.grey))]),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [Text(_formatDuration(duration), style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text('PHP ${NumberFormat('#,##0.00').format(price)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003366)))],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
