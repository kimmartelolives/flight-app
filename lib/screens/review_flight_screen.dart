import 'package:elective3project/screens/guest_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewFlightScreen extends StatelessWidget {
  final Map<String, dynamic> departureFlight;
  final Map<String, dynamic>? returnFlight;
  final String selectedBundle;
  final double bundlePrice;
  final String origin;
  final String destination;
  final String? origin2;
  final String? destination2;
  final String tripType;
  final DateTime departureDate;
  final DateTime? returnDate;

  const ReviewFlightScreen({
    super.key,
    required this.departureFlight,
    this.returnFlight,
    required this.selectedBundle,
    required this.bundlePrice,
    required this.origin,
    required this.destination,
    this.origin2,
    this.destination2,
    required this.tripType,
    required this.departureDate,
    this.returnDate,
  });

  Widget _buildFlightCard(BuildContext context, String title, Map<String, dynamic> flight, DateTime date, String flightOrigin, String flightDestination) {
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, y').format(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flightOrigin, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.flight, color: Colors.blue),
                Text(flightDestination, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.jm().format(flight['startTime']), style: TextStyle(color: Colors.grey[600])),
                Text(DateFormat.jm().format(flight['endTime']), style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const Divider(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    const Text('Flight Price:'),
                    Text('PHP ${currencyFormat.format(flight['price'])}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleCard(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bundle for all flights', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedBundle, style: const TextStyle(fontSize: 16)),
                if (bundlePrice > 0)
                  Text('+PHP ${currencyFormat.format(bundlePrice)}/guest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                if (bundlePrice == 0)
                  const Text('Included', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    double totalFlightPrice = departureFlight['price'];
    if (returnFlight != null) {
      totalFlightPrice += returnFlight!['price'];
    }
    final double totalPrice = totalFlightPrice + bundlePrice;

    final bool isMultiCity = tripType == 'multi city';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Flight'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightCard(context, isMultiCity ? 'FLIGHT 1' : 'Your departing flight', departureFlight, departureDate, origin, destination),
            if (returnFlight != null)
              _buildFlightCard(
                context, 
                isMultiCity ? 'FLIGHT 2' : 'Your returning flight', 
                returnFlight!, 
                returnDate!, 
                isMultiCity ? origin2! : destination, 
                isMultiCity ? destination2! : origin
              ),
            const SizedBox(height: 16),
            _buildBundleCard(context),
             const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('PHP ${currencyFormat.format(totalPrice)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),  
              ),
            ),
          ],
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
                      builder: (context) => GuestDetailsScreen(
                        departureFlight: departureFlight,
                        returnFlight: returnFlight,
                        selectedBundle: selectedBundle,
                        bundlePrice: bundlePrice,
                        origin: origin,
                        destination: destination,
                        origin2: origin2,
                        destination2: destination2,
                        departureDate: departureDate,
                        returnDate: returnDate,
                        tripType: tripType,
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
