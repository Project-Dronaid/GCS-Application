import 'package:flutter/material.dart';
import 'package:gcs_application/components/dropDown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Home Screen',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // CustomDropdownWithButtons(
            //   dropdownItems: [],
            //   buttonLabels: ['Button 1', 'Button 2', 'Button 3'],
            //   buttonCallbacks: [
            //     () => print('Button 1 pressed'),
            //     () => print('Button 2 pressed'),
            //     () => print('Button 3 pressed'),
            //   ],
            //   onDropdownChanged: (value) {
            //     print('Selected: $value');
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
