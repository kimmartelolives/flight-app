import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elective3project/models/booking.dart';

class SummaryFlightsTab extends StatelessWidget {
  final List<Booking> bookedFlights;
  final Function() onRefresh;

  const SummaryFlightsTab({
    super.key,
    required this.bookedFlights,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookedFlights.isEmpty) {
      return const Center(
        child: Text('You have no flight history yet.'),
      );
    }

    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);

    // Filter only past or current flights
    final filteredFlights = bookedFlights.where((booking) {
      final dep = DateTime(booking.departureDate.year, booking.departureDate.month, booking.departureDate.day);
      final ret = booking.returnDate != null
          ? DateTime(booking.returnDate!.year, booking.returnDate!.month, booking.returnDate!.day)
          : null;

      // Include flight if it has already started or finished
      return dep.isBefore(normalizedNow) ||
             dep.isAtSameMomentAs(normalizedNow) ||
             (ret != null && (ret.isBefore(normalizedNow) || ret.isAtSameMomentAs(normalizedNow)));
    }).toList();

    if (filteredFlights.isEmpty) {
      return const Center(
        child: Text('No past or current flights found.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: filteredFlights.length,
      itemBuilder: (context, index) {
        final booking = filteredFlights[index];
        final departureDetails = json.decode(booking.departureFlightDetails);
        final departureTime = departureDetails['departureTime'] ?? 'N/A';

        // Determine flight status based on date
        String flightStatus;
        final dep = booking.departureDate;
        final ret = booking.returnDate;

        if (booking.status == 'Cancelled') {
          flightStatus = 'Cancelled';
        } else if (ret != null && ret.isBefore(now)) {
          flightStatus = 'Completed';
        } else if (dep.isBefore(now) && (ret == null || ret.isAfter(now))) {
          flightStatus = 'Ongoing';
        } else {
          flightStatus = 'Confirmed';
        }

        // Color based on status
        Color chipColor;
        switch (flightStatus) {
          case 'Completed':
            chipColor = Colors.green;
            break;
          case 'Ongoing':
            chipColor = Colors.orange;
            break;
          case 'Cancelled':
            chipColor = Colors.red;
            break;
          default:
            chipColor = Colors.blueAccent;
        }

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.destination,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(flightStatus),
                      backgroundColor: chipColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text('${booking.tripType} - ${booking.selectedBundle}'),
                const SizedBox(height: 8.0),
                Text('Departure: ${booking.departureDate.toLocal().toString().split(' ')[0]} at $departureTime'),
                if (booking.returnDate != null)
                  Text('Return: ${booking.returnDate!.toLocal().toString().split(' ')[0]}'),
                const SizedBox(height: 8.0),
                Text('Passenger: ${booking.guestFirstName} ${booking.guestLastName}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
