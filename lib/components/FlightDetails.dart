import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FlightDetails extends StatefulWidget {
  Map<dynamic, dynamic> data={};

     FlightDetails({super.key});

  @override
  State<FlightDetails> createState() => _FlightDetailsState();
}

class _FlightDetailsState extends State<FlightDetails> {

  static const platform = MethodChannel('com.example.gcs_application/channel');

  late String altitude="0.0";
  late String ground_speed="0.0";
  late String mag1="0.0";
  late String mag2="0.0";
  late String bat_voltage="0.0";
  late String vertical_speed="0.0";

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == 'updateTelemetry') {
        final newData = Map<String, dynamic>.from(call.arguments);
        setState(() {
          widget.data = newData; // or use a state variable to store it
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final data=widget.data;
    final altitude = data["latitude"]?.toStringAsFixed(2) ?? "0.0";
    final ground_speed = data["speed"]?.toStringAsFixed(2) ?? "0.0";
    return Container(
      height: MediaQuery.of(context).size.height/2.3,
      decoration: BoxDecoration(
        color: Color(0xff3C3C3C),
        borderRadius: BorderRadius.circular(20)

      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('      Altitude(m)     ',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(altitude, style: TextStyle(fontSize: 45, color: Color(0xffD8B6FF)),)
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('  Ground Speed(m)  ',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(ground_speed,style: TextStyle(fontSize: 45, color: Color(0xffF4B87C)),)
                ],
              ),
            ],
          ),
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('       Mag 1       ',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(mag1,style: TextStyle(fontSize: 45, color: Color(0xffCD9394)),)
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('       Mag 2       ',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(mag2,style: TextStyle(fontSize: 45, color: Color(0xff8CCA7B)),)
                ],
              ),
            ],
          ),
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Vertical Speed (m/s)',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(vertical_speed,style: TextStyle(fontSize: 45, color: Color(0xffDCD678)),)
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('   Bat Voltage(V)   ',style: TextStyle(fontSize: 18, color: Colors.white),),
                  Text(bat_voltage,style: TextStyle(fontSize: 45, color: Color(0xff62AFB3)),)
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
