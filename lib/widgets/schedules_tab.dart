import 'package:flutter/material.dart';
import 'package:elective3project/models/flight.dart';

class SchedulesTab extends StatelessWidget {
  const SchedulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Flight> flights = [
      Flight(destination: 'Japan', departureTime: '10:00 AM', arrivalTime: '03:00 PM'),
      Flight(destination: 'South Korea', departureTime: '12:00 PM', arrivalTime: '05:00 PM'),
      Flight(destination: 'Singapore', departureTime: '02:00 PM', arrivalTime: '07:00 PM'),
      Flight(destination: 'Thailand', departureTime: '04:00 PM', arrivalTime: '09:00 PM'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: const Icon(Icons.flight, color: Colors.blue),
            title: Text(flight.destination, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Departs: ${flight.departureTime} - Arrives: ${flight.arrivalTime}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
