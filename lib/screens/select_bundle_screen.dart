import 'package:elective3project/screens/review_flight_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectBundleScreen extends StatefulWidget {
  final Map<String, dynamic> departureFlight;
  final Map<String, dynamic>? returnFlight;
  final String origin;
  final String destination;
  final String? origin2;
  final String? destination2;
  final String tripType;
  final DateTime departureDate;
  final DateTime? returnDate;

  const SelectBundleScreen({
    super.key,
    required this.departureFlight,
    this.returnFlight,
    required this.origin,
    required this.destination,
    this.origin2,
    this.destination2,
    required this.tripType,
    required this.departureDate,
    this.returnDate,
  });

  @override
  _SelectBundleScreenState createState() => _SelectBundleScreenState();
}

class _SelectBundleScreenState extends State<SelectBundleScreen> {
  String _selectedBundle = 'GO Basic';
  double _bundlePrice = 0.0;
  final Map<String, bool> _isExpanded = {
    'GO Basic': false,
    'GO Easy': false,
    'GO Flexi': false,
  };

  Widget _buildFlightSummaryCard(String title, Map<String, dynamic> flight, DateTime date) {
    final departureTime = flight['startTime'] ;
    final arrivalTime = flight['endTime'];
    final price = flight['price'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(DateFormat('MMMM d, y').format(date)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat.jm().format(departureTime)} - ${DateFormat.jm().format(arrivalTime)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('PHP ${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
   Icon _getIconForDetail(String detail) {
    if (detail.contains('hand-carry')) {
      return const Icon(Icons.shopping_bag_outlined, size: 18);
    } else if (detail.contains('checked baggage')) {
      return const Icon(Icons.luggage_outlined, size: 18);
    } else if (detail.contains('Seat')) {
      return const Icon(Icons.chair_outlined, size: 18);
    } else if (detail.contains('CEB Flexi')) {
      return const Icon(Icons.swap_horiz_outlined, size: 18);
    }
    return const Icon(Icons.check_circle_outline, size: 18);
  }


  Widget _buildBundleOption({
    required String title,
    required String subtitle,
    required double price,
    required List<String> details,
  }) {
    final isSelected = _selectedBundle == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBundle = title;
          _bundlePrice = price;
        });
      },
      child: Card(
        color: isSelected ? Colors.blue[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (price > 0)
                    Text('+PHP ${price.toStringAsFixed(0)}/guest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const Divider(height: 24),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded[title] = !_isExpanded[title]!;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show details', style: TextStyle(color: Colors.blue)),
                    Icon(_isExpanded[title]! ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  ],
                ),
              ),
              if (_isExpanded[title]!)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                       child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getIconForDetail(detail),
                          const SizedBox(width: 8),
                          Expanded(child: Text(detail)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiCity = widget.tripType == 'multi city';

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Bundle')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Selected Flights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildFlightSummaryCard(isMultiCity ? 'Flight 1 Departure' : 'Departure', widget.departureFlight, widget.departureDate),
              if (widget.returnFlight != null)
                _buildFlightSummaryCard(isMultiCity ? 'Flight 2 Departure' : 'Return', widget.returnFlight!, widget.returnDate!),
              const SizedBox(height: 24),
              const Text('Select a bundle for all flights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildBundleOption(
                title: 'GO Basic',
                subtitle: 'Buy other add-ons later at regular price',
                price: 0,
                details: [
                  '1 pc hand-carry bag (Max weight of 7kg)',
                  'Random Seat (Seat assigned upon check-in)',
                ],
              ),
              const SizedBox(height: 16),
              _buildBundleOption(
                title: 'GO Easy',
                subtitle: 'Get discounts on baggage and seats',
                price: 1320,
                details: [
                  '1 pc hand-carry bag (Max weight of 7kg)',
                  '1 pc checked baggage (Max weight of 20kg)',
                  'Preferred Seat (Standard seat of your choice)',
                ],
              ),
              const SizedBox(height: 16),
              _buildBundleOption(
                title: 'GO Flexi',
                subtitle: 'Enjoy free cancellation when your plans change',
                price: 2480,
                details: [
                  '1 pc hand-carry bag (Max weight of 7kg)',
                  '1 pc checked baggage (Max weight of 20kg)',
                  'Preferred Seat (Standard seat of your choice)',
                  'CEB Flexi (Convert your booking into non-expiring Travel Fund for future use)',
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewFlightScreen(
                        departureFlight: widget.departureFlight,
                        returnFlight: widget.returnFlight,
                        selectedBundle: _selectedBundle,
                        bundlePrice: _bundlePrice,
                        origin: widget.origin,
                        destination: widget.destination,
                        origin2: widget.origin2,
                        destination2: widget.destination2,
                        departureDate: widget.departureDate,
                        returnDate: widget.returnDate,
                        tripType: widget.tripType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
