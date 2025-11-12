import 'package:elective3project/database/database_helper.dart';
import 'package:elective3project/widgets/summary_flights_tab.dart';
import 'package:flutter/material.dart';
import 'package:elective3project/widgets/booking_tab.dart';
import 'package:elective3project/widgets/schedules_tab.dart';
import 'package:elective3project/widgets/booked_flights_tab.dart';
import 'package:elective3project/models/booking.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Booking> _bookedFlights = [];
  int? _userId;
  String? _initialDestination; // To hold the destination from the home screen

  final List<Map<String, String>> _bestOffers = [
    {'name': 'Siargao', 'imageUrl': 'assets/images/siargao.jpg'},
    {'name': 'Palawan', 'imageUrl': 'assets/images/palawan.jpg'},
    {'name': 'Bohol', 'imageUrl': 'assets/images/bohol.png'},
    {'name': 'Boracay', 'imageUrl': 'assets/images/boracay.jpg'},
    {'name': 'Siquijor', 'imageUrl': 'assets/images/siquijor.jpg'},
  ];

  final List<String> _dealImages = [
    'assets/images/sale1.png',
    'assets/images/sale2.png',
  ];

  // Navigate to the booking tab with a pre-selected destination
  void _navigateToBooking(String destination) {
    setState(() {
      _initialDestination = destination;
      _selectedIndex = 1; // Index of the BookingTab
    });
  }

  Widget get _homeTab => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.asset(
                'assets/images/intro.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore Our Best Offers From',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180, // Adjusted height for clickable image card
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bestOffers.length,
                itemBuilder: (context, index) {
                  final offer = _bestOffers[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 16.0, right: index == _bestOffers.length - 1 ? 16.0 : 0),
                    child: SizedBox(
                      width: 200,
                      child: GestureDetector( // Make the entire card clickable
                        onTap: () => _navigateToBooking(offer['name']!),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                offer['imageUrl']!,
                                width: 200,
                                height: 180, // Image fills the card
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Text(
                                offer['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(blurRadius: 10.0, color: Colors.black)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Best Deal for you',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dealImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(left: 16.0, right: index == _dealImages.length - 1 ? 16.0 : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        _dealImages[index],
                        width: 300,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );

  final Widget _profileTab = const Center(child: Text('Profile2'));

  @override
  void initState() {
    super.initState();
    // TODO: This should be replaced by a proper user session/login system
    // For now, we hardcode the user ID to 1 to match the one used in payment_screen.
    _userId = 1; 
    _loadBookings(); // Load bookings for the default user
  }

  Future<void> _loadBookings() async {
    if (_userId != null) {
      final db = DatabaseHelper();
      final bookings = await db.getBookings(_userId!);
      if (mounted) {
        setState(() {
          _bookedFlights = bookings;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _initialDestination = null; // Reset when manually changing tabs
    });
    // If the 'My Bookings' tab is selected (index 3), refresh the bookings list.
    if (index == 3) {
      _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _homeTab,
      BookingTab(initialDestination: _initialDestination),
      const SchedulesTab(),
      BookedFlightsTab(bookedFlights: _bookedFlights, onRefresh: _loadBookings),
      SummaryFlightsTab(bookedFlights: _bookedFlights, onRefresh: _loadBookings), //added new tab for summary of flights - Nov. 12, 2025
      _profileTab,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('FLYQUEST', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Book Flight'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'My Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Summary Flights'), //added new buttons for summary of flights - Nov. 12, 2025
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
