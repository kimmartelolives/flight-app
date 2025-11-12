
import 'package:elective3project/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestDetailsScreen extends StatefulWidget {
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

  const GuestDetailsScreen({
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
  });

  @override
  _GuestDetailsScreenState createState() => _GuestDetailsScreenState();
}

class _GuestDetailsScreenState extends State<GuestDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  final _nationalityController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();

  final _contactFirstNameController = TextEditingController();
  final _contactLastNameController = TextEditingController();

  bool _hasDeclaration = false;
  bool _isPwd = false;
  bool _agreedToPolicy = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(() {
      _contactFirstNameController.text = _firstNameController.text;
    });
    _lastNameController.addListener(() {
      _contactLastNameController.text = _lastNameController.text;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _contactFirstNameController.dispose();
    _contactLastNameController.dispose();
    super.dispose();
  }

  String? _validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    if (_selectedDob != null) {
      final today = DateTime.now();
      final twelveYearsAgo = DateTime(today.year - 12, today.month, today.day);
      if (_selectedDob!.isAfter(twelveYearsAgo)) {
        return 'Guest must be at least 12 years old';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Please make sure that you enter your name exactly as it is shown on your Valid ID',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Mr.', 'Ms.']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter first name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your first name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter last name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your last name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Day Month Year',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDob = date;
                        _dobController.text = DateFormat('MMMM d, y').format(date);
                      });
                    }
                  },
                  validator: _validateDob,
                ),
                const SizedBox(height: 4),
                 const Text(
                  'Adults should be at least 12 years old on date of travel',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nationalityController,
                  decoration: const InputDecoration(
                    labelText: 'Nationality',
                    border: OutlineInputBorder(),
                  ),
                   validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your nationality' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('I have a declaration/request'),
                  value: _hasDeclaration,
                  onChanged: (value) {
                    setState(() {
                      _hasDeclaration = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('I am a Person with Disability'),
                  value: _isPwd,
                  onChanged: (value) {
                    setState(() {
                      _isPwd = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(height: 32),
                 const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                 const Text(
                  'Let us know how we may reach you if there are changes or questions related to your booking and payment',
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _contactFirstNameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                     filled: true,
                    fillColor: Colors.black12,
                  ),
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _contactLastNameController,
                   readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _contactNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                   validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your contact number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                   keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                 const SizedBox(height: 16),
                FormField<bool>(
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CheckboxListTile(
                          title: const Text(
                              'I confirm that I have read, understood, and agree to the FlyQuest Privacy Policy. I Consent to the collection, use, processing and sharing of my personal information in accordance therewith'),
                          value: _agreedToPolicy,
                          onChanged: (value) {
                            setState(() {
                              _agreedToPolicy = value!;
                              state.didChange(value);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          subtitle: state.errorText == null
                              ? null
                              : Text(
                                  state.errorText!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                        ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (!_agreedToPolicy) {
                      return 'You must agree to the Privacy Policy';
                    } else {
                      return null;
                    }
                  },
                ),
              ],
            ),
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
                  if (_formKey.currentState!.validate()) {
                    // Calculate the final total price
                    double finalTotalPrice = 0.0;
                    finalTotalPrice += (widget.departureFlight['price'] as num).toDouble();
                    if (widget.returnFlight != null) {
                      finalTotalPrice += (widget.returnFlight!['price'] as num).toDouble();
                    }
                    finalTotalPrice += widget.bundlePrice;
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                           // Pass all the necessary data
                          departureFlight: widget.departureFlight,
                          returnFlight: widget.returnFlight,
                          selectedBundle: widget.selectedBundle,
                          bundlePrice: finalTotalPrice, // Use the calculated final total price
                           origin: widget.origin,
                          destination: widget.destination,
                          origin2: widget.origin2,
                          destination2: widget.destination2,
                          departureDate: widget.departureDate,
                          returnDate: widget.returnDate,
                          tripType: widget.tripType,
                          title: _title!,
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          dob: _dobController.text,
                          nationality: _nationalityController.text,
                          contactNumber: _contactNumberController.text,
                          email: _emailController.text,
                        ),
                      ),
                    );
                  }
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
