import 'package:elective3project/screens/flight_results_screen.dart';
import 'package:elective3project/widgets/passenger_counter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingTab extends StatefulWidget {
  final String? initialDestination;

  const BookingTab({
    super.key,
    this.initialDestination,
  });

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab> {
  final _formKey = GlobalKey<FormState>();
  int _selectedTripTypeIndex = 0; // 0: One Way, 1: Round Trip, 2: Multi-city

  // Controllers for Flight 1
  final String _origin1 = 'Manila';
  String? _destination1;
  DateTime _departureDate1 = DateTime.now();

  // Controllers for Round Trip
  DateTime? _returnDate;

  // Controllers for Flight 2 (Multi-city)
  String _origin2 = 'Manila';
  String? _destination2;
  DateTime? _departureDate2;

  // Passenger and Class
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _flightClass = 'economy';

  final Map<String, List<String>> _destinations = {
    'Luzon': [
      'Clark', 'Subic', 'Baguio', 'Basco', 'Laoag',
      'Tuguegarao', 'Cauayan', 'Vigan', 'Naga', 'Legazpi',
      'Virac', 'Marinduque', 'Masbate', 'Tablas', 'San Jose',
      'Busuanga', 'El Nido', 'Cuyo', 'Palawan', 'PuertoPrincesa'
    ],
    'Visayas': [
      'Cebu', 'Bacolod', 'Iloilo', 'Kalibo', 'Caticlan',
      'Roxas', 'Tacloban', 'Ormoc', 'Bohol', 'Dumaguete',
      'Catarman', 'Biliran', 'Maasin', 'Bantayan'
    ],
    'Mindanao': [
      'Davao', 'GenSan', 'Cdo', 'Butuan', 'Surigao', 'Siargao',
      'Tandag', 'Dipolog', 'Pagadian', 'Ozamiz', 'Cotabato',
      'Zamboanga', 'Jolo', 'TawiTawi', 'Camiguin'
    ]
  };

  final List<String> _flightClasses = ['economy', 'premium economy', 'business', 'first class'];

  @override
  void initState() {
    super.initState();
    for (var key in _destinations.keys) {
      _destinations[key]!.sort();
    }
    if (widget.initialDestination != null) {
      _setInitialDestination(widget.initialDestination!);
    }
  }

  @override
  void didUpdateWidget(BookingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDestination != null &&
        widget.initialDestination != oldWidget.initialDestination) {
      _setInitialDestination(widget.initialDestination!);
    }
  }

  void _setInitialDestination(String destination) {
    final Map<String, String> destinationMap = {
      'Boracay': 'Kalibo',
      'Siquijor': 'Bohol',
      'Siargao': 'Siargao',
      'Palawan': 'Palawan',
      'Bohol': 'Bohol',
    };

    String finalDestination = destinationMap[destination] ?? destination;

    String? group;
    for (var entry in _destinations.entries) {
      if (entry.value.contains(finalDestination)) {
        group = entry.key;
        break;
      }
    }

    if (group != null) {
      setState(() {
        _destination1 = finalDestination;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, int flightSegment) async {
    DateTime initialDate;
    if (flightSegment == 1) {
      initialDate = _departureDate1;
    } else if (flightSegment == 2 && _selectedTripTypeIndex == 1) { // Round trip return
      initialDate = _returnDate ?? _departureDate1;
    } else { // Multi-city flight 2
      initialDate = _departureDate2 ?? _departureDate1;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (flightSegment == 1) {
          _departureDate1 = picked;
        } else if (flightSegment == 2 && _selectedTripTypeIndex == 1) { // Round trip return
          _returnDate = picked;
        } else { // Multi-city flight 2
          _departureDate2 = picked;
        }
      });
    }
  }

  Future<String?> _selectLocationDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedGroup;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tempSelectedGroup == null ? 'Select Island Group' : 'Select Destination'),
              content: SizedBox(
                width: double.maxFinite,
                child: tempSelectedGroup == null
                    ? ListView(
                        shrinkWrap: true,
                        children: _destinations.keys.map((group) {
                          return ListTile(
                            title: Text(group),
                            onTap: () {
                              setState(() {
                                tempSelectedGroup = group;
                              });
                            },
                          );
                        }).toList(),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: _destinations[tempSelectedGroup!]!.map((destination) {
                          return ListTile(
                            title: Text(destination),
                            onTap: () {
                              Navigator.of(context).pop(destination);
                            },
                          );
                        }).toList(),
                      ),
              ),
              actions: [
                if (tempSelectedGroup != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tempSelectedGroup = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _searchFlights() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tripType = ['one way', 'round trip', 'multi city'][_selectedTripTypeIndex];

    if (tripType == 'multi city') {
      if (_destination1 == null || _destination2 == null || _departureDate2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields for multi-city flights.')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightResultsScreen(
            tripType: tripType,
            // Flight 1
            origin: _origin1,
            destination: _destination1!,
            departureDate: _departureDate1,
            // Flight 2
            origin2: _origin2,
            destination2: _destination2,
            departureDate2: _departureDate2,
          ),
        ),
      );
    } else { // One way or Round Trip
      if (_destination1 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a destination.')),
        );
        return;
      }
      if (tripType == 'round trip' && _returnDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a return date for a round trip.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightResultsScreen(
            origin: _origin1,
            destination: _destination1!,
            departureDate: _departureDate1,
            tripType: tripType,
            returnDate: _returnDate,
          ),
        ),
      );
    }
  }
  
  Widget _buildLocationField({required String label, required String? value, required VoidCallback onTap, bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled ? onTap : null,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: label == 'FROM' ? const Icon(Icons.flight_takeoff) : const Icon(Icons.flight_land),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              filled: !isEnabled,
              fillColor: Colors.grey[200],
            ),
            child: Text(
              value ?? 'Select Location',
              style: TextStyle(fontSize: 16, color: isEnabled ? Colors.black : Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required DateTime? date, required VoidCallback onTap}) {
     return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today), border: const OutlineInputBorder()),
        child: Text(date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select Date'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search Your Flight', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24.0),
                Center(
                  child: ToggleButtons(
                    isSelected: [_selectedTripTypeIndex == 0, _selectedTripTypeIndex == 1, _selectedTripTypeIndex == 2],
                    onPressed: (index) {
                      setState(() {
                        _selectedTripTypeIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('One Way')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Round Trip')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Multi-city')),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // === Conditionally build flight forms ===
                if (_selectedTripTypeIndex < 2) // One Way & Round Trip
                  _buildStandardFlightForm(),
                if (_selectedTripTypeIndex == 2) // Multi-city
                  _buildMultiCityFlightForm(),

                const SizedBox(height: 24.0),
                const Text('Passengers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                PassengerCounter(label: 'Adults', count: _adults, onChanged: (count) => setState(() => _adults = count >= 1 ? count : 1)),
                PassengerCounter(label: 'Children', count: _children, onChanged: (count) => setState(() => _children = count >= 0 ? count : 0)),
                PassengerCounter(label: 'Infants', count: _infants, onChanged: (count) => setState(() => _infants = count >= 0 ? count : 0)),
                const SizedBox(height: 24.0),
                DropdownButtonFormField<String>(
                  initialValue: _flightClass,
                  decoration: const InputDecoration(labelText: 'Class', prefixIcon: Icon(Icons.airline_seat_recline_normal), border: OutlineInputBorder()),
                  items: _flightClasses.map((fClass) => DropdownMenuItem(value: fClass, child: Text(fClass))).toList(),
                  onChanged: (value) => setState(() => _flightClass = value!),
                  validator: (value) => value == null ? 'Please select a class' : null,
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _searchFlights, child: const Text('Search Flights')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for One Way and Round Trip
  Widget _buildStandardFlightForm() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLocationField(label: 'FROM', value: _origin1, onTap: () {}, isEnabled: false)),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildLocationField(
                label: 'TO',
                value: _destination1,
                onTap: () async {
                  final result = await _selectLocationDialog(context);
                  if (result != null) setState(() => _destination1 = result);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildDateField(label: 'Departure Date', date: _departureDate1, onTap: () => _selectDate(context, 1))),
            if (_selectedTripTypeIndex == 1) ...[ // Show Return Date for Round Trip
              const SizedBox(width: 16.0),
              Expanded(child: _buildDateField(label: 'Return Date', date: _returnDate, onTap: () => _selectDate(context, 2))),
            ],
          ],
        ),
      ],
    );
  }

  // Widget for Multi-city
  Widget _buildMultiCityFlightForm() {
    return Column(
      children: [
        // --- Flight 1 ---
        const Text("Flight 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLocationField(
                label: 'FROM', 
                value: _origin1, // Default to Manila
                onTap: () {},
                isEnabled: false,
              )
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildLocationField(
                label: 'TO',
                value: _destination1,
                onTap: () async {
                  final result = await _selectLocationDialog(context);
                  if (result != null) setState(() => _destination1 = result);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildDateField(label: 'Depart', date: _departureDate1, onTap: () => _selectDate(context, 1)),
        const Divider(height: 32, thickness: 1),

        // --- Flight 2 ---
        const Text("Flight 2", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLocationField(
                label: 'FROM',
                value: _origin2,
                onTap: () async {
                  final result = await _selectLocationDialog(context);
                  if (result != null) setState(() => _origin2 = result);
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildLocationField(
                label: 'TO',
                value: _destination2,
                onTap: () async {
                  final result = await _selectLocationDialog(context);
                  if (result != null) setState(() => _destination2 = result);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildDateField(label: 'Depart', date: _departureDate2, onTap: () => _selectDate(context, 3)),
      ],
    );
  }
}
