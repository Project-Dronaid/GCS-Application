import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcs_application/components/FlightDetails.dart';
import 'package:gcs_application/components/GoogleMapsWidget.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedMode;

  final List<String> modes = ['STABILIZE', 'GUIDED', 'AUTO', 'RTL', 'LOITER','ALT_HOLD'];
  static const platform = MethodChannel('com.example.gcs_application/channel');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeCalls);
    connectToDrone();
  }
  Future<void> connectToDrone() async{
    try {
      final result = await platform.invokeMethod('connectDrone');
      print('Result from native: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke method: ${e.message}');
    }
  }

  Future<void> _handleNativeCalls(MethodCall call) async {
    switch(call.method) {
      case 'showToast':
        final String message= call.arguments;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            TextButton(
              onPressed: () async {
                try {
                  final result = await platform.invokeMethod('connectDrone');
                  print('Result from native: $result');
                } on PlatformException catch (e) {
                  print('Failed to invoke method: ${e.message}');
                }
              },
              child: Text('Connect') ,
            ),
            TextButton(
              onPressed: () async {
                try {
                  final result = await platform.invokeMethod('toggleArmDisarm');
                  print('Result from native: $result');
                } on PlatformException catch (e) {
                  print('Failed to invoke method: ${e.message}');
                }
              },
              child: Text('Arm/Disarm') ,
            ),
            TextButton(
              onPressed: () async {
                try {
                  final result = await platform.invokeMethod('startMission');
                  print('Result from native: $result');
                } on PlatformException catch (e) {
                  print('Failed to invoke method: ${e.message}');
                }
              },
              child: Text('Start Mission') ,
            ),
            TextButton(
              onPressed: () async {
                try {
                  final result = await platform.invokeMethod('abortMission');
                  print('Result from native: $result');
                } on PlatformException catch (e) {
                  print('Failed to invoke method: ${e.message}');
                }
              },
              child: Text('Abort Mission') ,
            ),
            DropdownButton<String>(
              value: selectedMode,
              hint: Text("Select Mode"),
              items: modes.map((mode) {
                return DropdownMenuItem<String>(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMode = value;
                });

                // Send to Java using MethodChannel
                if (value != null) {
                  MethodChannel('com.example.gcs_application/channel')
                      .invokeMethod('changeFlightMode', {'mode': value});
                }
              },
            ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child:  SingleChildScrollView(
            //     scrollDirection: Axis.vertical,
            //     child: GoogleMapsWidget(height: MediaQuery.of(context).size.height/1.1,),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlightDetails(),
            )
          ],
        ),
      ),
    );
  }
}
