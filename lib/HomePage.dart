import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcs_application/components/FlightDetails.dart';
import 'package:gcs_application/components/GoogleMapsWidget.dart';
import 'package:gcs_application/screens/homeScreen.dart';
import 'package:gcs_application/screens/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // late Map<dynamic, dynamic> data={};

  int _selectedIndex = 2;
  final List<Widget> _pages = <Widget>[
    const Text('Drone Dashboard'),
    const Text('WayPoints'),
    const HomeScreen(),
    const Text('VRC'),
    const Settings(),
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        unselectedFontSize: 11.0,
        selectedFontSize: 15.0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        unselectedIconTheme:
            const IconThemeData(size: 24.0, color: Colors.black),
        selectedIconTheme: const IconThemeData(size: 30.0, color: Colors.blue),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'DD'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'WayPoints'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'VRC'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
