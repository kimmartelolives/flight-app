import 'dart:convert';
import 'dart:math';

import 'package:elective3project/models/booking.dart';
import 'package:elective3project/screens/booking_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> departureFlight;
  final Map<String, dynamic>? returnFlight;
  final String selectedBundle;
  final double bundlePrice;
  final String origin;
  final String destination;
  final String? origin2;
  final String? destination2;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String tripType;
  final String title;
  final String firstName;
  final String lastName;
  final String dob;
  final String nationality;
  final String contactNumber;
  final String email;

  const PaymentScreen({
    super.key,
    required this.departureFlight,
    this.returnFlight,
    required this.selectedBundle,
    required this.bundlePrice,
    required this.origin,
    required this.destination,
    this.origin2,
    this.destination2,
    required this.departureDate,
    this.returnDate,
    required this.tripType,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.nationality,
    required this.contactNumber,
    required this.email,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Card';
  String _selectedEWallet = 'GCash'; // To track GCash or PayMaya
  bool _saveCardDetails = false;
  bool _isProcessing = false;

  // Controllers for Card
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Controllers for E-wallet & Bank Transfer
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _onPaymentMethodChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPaymentMethod = value;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'Card' || _selectedPaymentMethod == 'E-wallet' || _selectedPaymentMethod == 'Bank Transfer') {
        if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final bool isPaymentSuccess = true; 

      if (isPaymentSuccess) {
        final dbHelper = DatabaseHelper();
        final bookingReference = 'CEB${Random().nextInt(999999).toString().padLeft(6, '0')}';

        String finalPaymentMethod = _selectedPaymentMethod;
        if (_selectedPaymentMethod == 'E-wallet') {
          finalPaymentMethod = 'E-wallet ($_selectedEWallet)';
        }

        // --- FIX: Convert DateTime objects in flight details to String before encoding ---
        final departureFlightDetailsEncodable = Map<String, dynamic>.from(widget.departureFlight);
        departureFlightDetailsEncodable.updateAll((key, value) {
          if (value is DateTime) {
            return value.toIso8601String();
          }
          return value;
        });

        Map<String, dynamic>? returnFlightDetailsEncodable;
        if (widget.returnFlight != null) {
          returnFlightDetailsEncodable = Map<String, dynamic>.from(widget.returnFlight!);
           returnFlightDetailsEncodable.updateAll((key, value) {
            if (value is DateTime) {
              return value.toIso8601String();
            }
            return value;
          });
        }
        // --- END FIX ---


        final newBooking = Booking(
          bookingReference: bookingReference,
          userId: 1, // Placeholder user ID
          origin: widget.origin,
          destination: widget.destination,
          origin2: widget.origin2,
          destination2: widget.destination2,
          departureDate: widget.departureDate,
          returnDate: widget.returnDate,
          tripType: widget.tripType,
          guestFirstName: widget.firstName,
          guestLastName: widget.lastName,
          departureFlightDetails: jsonEncode(departureFlightDetailsEncodable), // Use the fixed map
          returnFlightDetails: returnFlightDetailsEncodable != null ? jsonEncode(returnFlightDetailsEncodable) : null, // Use the fixed map
          selectedBundle: widget.selectedBundle,
          totalPrice: widget.bundlePrice,
          paymentMethod: finalPaymentMethod,
          status: 'Confirmed',
        );

        // Save to database
        await dbHelper.insertBooking(newBooking);

        // Navigate on success
        if (mounted) {
           Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(
                booking: newBooking,
              ),
            ),
            (Route<dynamic> route) => false, 
          );
        }
      } 
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _processPayment,
            ),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPaymentMethodSelector(),
              const SizedBox(height: 24),
              if (_selectedPaymentMethod == 'Card')
                _buildCardDetailsForm(),
              if (_selectedPaymentMethod == 'E-wallet')
                _buildEWalletDetailsForm(),
              if (_selectedPaymentMethod == 'Bank Transfer')
                _buildBankTransferDetailsForm(),
              const SizedBox(height: 24),
              _buildReviewAndConfirm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildPayNowButton(),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPaymentOption('Card', Icons.credit_card),
            _buildPaymentOption('E-wallet', Icons.account_balance_wallet),
            _buildPaymentOption('Bank Transfer', Icons.account_balance),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return RadioListTile<String>(
      title: Text(method),
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: _isProcessing ? null : _onPaymentMethodChanged,
      secondary: Icon(icon),
      contentPadding: EdgeInsets.zero,
    );
  }

  // --- FORM WIDGETS FOR EACH PAYMENT TYPE ---

  Widget _buildCardDetailsForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Card Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.isEmpty || value.length < 16) ? 'Enter a valid card number' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty || value.length < 3) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Save card for next time'),
              value: _saveCardDetails,
              onChanged: (bool? value) {
                setState(() {
                  _saveCardDetails = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEWalletDetailsForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('GCash'),
                  selected: _selectedEWallet == 'GCash',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedEWallet = 'GCash');
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('PayMaya'),
                  selected: _selectedEWallet == 'PayMaya',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedEWallet = 'PayMaya');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your number' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferDetailsForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
               validator: (value) => (value == null || value.isEmpty) ? 'Please enter your account name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter your account number' : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- REVIEW AND PAY BUTTON WIDGETS ---

  Widget _buildReviewAndConfirm() {
    final formatCurrency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final dateFormat = DateFormat('MMM d, yyyy');
    
    String finalPaymentMethod = _selectedPaymentMethod;
      if (_selectedPaymentMethod == 'E-wallet') {
        finalPaymentMethod = 'E-wallet ($_selectedEWallet)';
      }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review & Confirm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Text('${widget.origin} to ${widget.destination}', style: Theme.of(context).textTheme.titleMedium),
            Text(dateFormat.format(widget.departureDate)),
            const SizedBox(height: 16),
            _buildReviewDetailRow('Passenger:', '${widget.title} ${widget.firstName} ${widget.lastName}'),
            _buildReviewDetailRow('Bundle:', widget.selectedBundle),
            _buildReviewDetailRow('Payment Method:', finalPaymentMethod),
            const Divider(height: 24),
            _buildReviewDetailRow(
              'Total Amount:',
              formatCurrency.format(widget.bundlePrice),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
    final formatCurrency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total', style: TextStyle(color: Colors.black54)),
              Text(
                formatCurrency.format(widget.bundlePrice),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}
