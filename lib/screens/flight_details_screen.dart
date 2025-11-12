import 'dart:convert';
import 'package:elective3project/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:elective3project/models/booking.dart';

class FlightDetailsScreen extends StatefulWidget {
  const FlightDetailsScreen({super.key});

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  Future<void> _showCancelDialog(Booking booking) async {
    String? selectedReason;
    final otherReasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reasons = [
      'Change of travel plans',
      'Found a cheaper flight',
      'Scheduling conflict',
      'Health or personal emergency',
      'Weather or safety concerns',
      'Duplicate booking',
      'Others (please specify)',
    ];

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reason for cancellation'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...reasons.map((reason) {
                          return RadioListTile<String>(
                            title: Text(reason),
                            value: reason,
                            groupValue: selectedReason,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          );
                        }),
                        if (selectedReason == 'Others (please specify)')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              controller: otherReasonController,
                              decoration: const InputDecoration(
                                hintText: 'Please specify your reason',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please specify your reason';
                                }
                                return null;
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Back'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () async {
                    if (selectedReason == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a reason')),
                      );
                      return;
                    }

                    String finalReason = selectedReason!;

                    if (selectedReason == 'Others (please specify)') {
                      if (formKey.currentState?.validate() ?? false) {
                        finalReason = otherReasonController.text;
                      } else {
                        return; 
                      }
                    }
                    
                    final db = DatabaseHelper();
                    await db.cancelBooking(booking.id!, finalReason);

                    Navigator.of(context).pop(); 

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Flight has been cancelled.')),
                    );

                    if (mounted) {
                       Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)!.settings.arguments as Booking;
    final departureDetails = json.decode(booking.departureFlightDetails);
    final arrivalTime = departureDetails['arrivalTime'] ?? 'N/A';
    final departureTime = departureDetails['departureTime'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.flight_takeoff),
            SizedBox(width: 8),
            Text('FlyQuest'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(booking.destination, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    Chip(
                      label: Text(booking.status),
                      backgroundColor: booking.status == 'Cancelled' ? Colors.red : Colors.green,
                    ),
                  ],
                ),
                 if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Reason: ${booking.cancellationReason}', style: TextStyle(color: Colors.red[700])),
                  ),
                const SizedBox(height: 16.0),
                Text('Departure: ${booking.departureDate.toLocal().toString().split(' ')[0]} at $departureTime',
                    style: const TextStyle(fontSize: 16)),
                Text('Arrival: ${booking.departureDate.toLocal().toString().split(' ')[0]} at $arrivalTime',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16.0),
                Text('Passenger: ${booking.guestFirstName} ${booking.guestLastName}',
                    style: const TextStyle(fontSize: 16)),
                Text('Bundle: ${booking.selectedBundle}', style: const TextStyle(fontSize: 16)),
                Text('Trip Type: ${booking.tripType}', style: const TextStyle(fontSize: 16)),
                if (booking.returnDate != null)
                  Text('Return Date: ${booking.returnDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16)),
                const Divider(height: 32.0),
                if (booking.status != 'Cancelled')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCancelDialog(booking),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancel Flight'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
