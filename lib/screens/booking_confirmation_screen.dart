import 'package:elective3project/models/booking.dart';
import 'package:elective3project/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Booking Successful!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your flight has been booked successfully.\nYour booking reference is:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                booking.bookingReference,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 32),
              _buildBookingSummary(context),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                   Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                   minimumSize: const Size(double.infinity, 50),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm'), // <--- UPDATED TEXT
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formatCurrency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  '${booking.origin} to ${booking.destination}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(booking.status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.zero,
                )
              ],
            ),
            const Divider(height: 20),
            Text('${booking.guestFirstName} ${booking.guestLastName}'),
            const SizedBox(height: 8),
            Text('Departure: ${dateFormat.format(booking.departureDate)}'),
            if (booking.returnDate != null)
               Text('Return: ${dateFormat.format(booking.returnDate!)}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid:', style: TextStyle(fontSize: 16)),
                Text(
                  formatCurrency.format(booking.totalPrice),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
    );
  }
}
