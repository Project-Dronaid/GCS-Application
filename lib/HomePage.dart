import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.gcs_application/channel');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeCalls);
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
      body: FloatingActionButton(
        onPressed: () async {
          try {
            final result = await platform.invokeMethod('connectDrone');
            print('Result from native: $result');
          } on PlatformException catch (e) {
            print('Failed to invoke method: ${e.message}');
          }
        },
        child: Text('Press me to connect') ,
      ),
    );
  }
}
