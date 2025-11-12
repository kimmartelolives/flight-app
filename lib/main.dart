import 'package:elective3project/screens/admin_home_screen.dart';
import 'package:elective3project/screens/flight_details_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart'; // Import the new splash screen

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navyBlue = Color(0xFF000080);
    const gold = Color(0xFFFFD700);
    const white = Colors.white;

    return MaterialApp(
      title: 'FlyQuest',
      theme: ThemeData(
        primaryColor: navyBlue,
        colorScheme: const ColorScheme.light(
          primary: navyBlue,
          secondary: gold,
          onPrimary: white,
          onSecondary: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: white,
        appBarTheme: const AppBarTheme(
          backgroundColor: navyBlue,
          foregroundColor: gold,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navyBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: navyBlue,
          selectedItemColor: gold,
          unselectedItemColor: white,
        ),
      ),
      // Set the splash screen as the initial route
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // The app will start here
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/flight_details': (context) => const FlightDetailsScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
      },
    );
  }
}
