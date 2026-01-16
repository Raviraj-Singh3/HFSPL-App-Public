import 'dart:async';
import 'package:HFSPL/Attendance/attendance_history.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/custom_views/location.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Attendance/attendance_model.dart';
import 'package:HFSPL/utils/globals.dart';

class MarkAttendence extends StatefulWidget {
  const MarkAttendence({super.key});

  @override
  State<MarkAttendence> createState() => _MarkAttendenceState();
}

class _MarkAttendenceState extends State<MarkAttendence> {
  final DioClient _client = DioClient();

  List<AttendanceModel> attendanceResponse = [];
  //  dynamic att;

  String _currentDateTime = '';
  String _currentAddress = '';
  bool _isAttendanceIn = false;
  bool _isAttendanceOut = false;
  Timer? _timer;
  bool isLoading = true;
  
  fetchAttendance() async {
    // context.loaderOverlay.show();
    try {
      
      var response = await _client.getAttendance(Global_uid);

      attendanceResponse = response;

      if(attendanceResponse.isNotEmpty){
          await getAddressFromLatLng();
        }
      
      if (mounted) {
      setState(() {
        // attendanceResponse = response;
        isLoading = false;
      });
    }

    }
    catch(e) {
      print("Error fetching Attendance: $e");

      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
      setState(() {
        isLoading = false;
      });
      
    }
    // context.loaderOverlay.hide();
  }}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAttendance();
    startTimeClock();
    // checkTodayAttendance();
    // getAddressFromLatLng();
  }

  void startTimeClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      
      if (mounted) { // Check if the widget is mounted
      setState(() {
        _currentDateTime = DateFormat('dd MMM yyyy\nhh:mm:ss a').format(DateTime.now());
      });
    }

    });
  }


   getAddressFromLatLng() async {

    try {

        Position position = await getCurrentLocation();

        if (!mounted) return;

      try {

        final response = await _client.getAddess(position);

        setState(() {
          _currentAddress = '${response?['display_name']}';
        });

      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${e}')),
        );
    }
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${e}')),
        );
        Navigator.pop(context, true);
      }
    
  }

    markAttendance() async {

        context.loaderOverlay.show();

        try {
          Position position = await getCurrentLocation();
          final response = await _client.postAttendance({
          'Uid': Global_uid,
          'Ip': '0', // "IN" or "OUT"
          'lat': position.latitude, // Add logic to get latitude
          'lng': position.longitude,
          "IsIn": attendanceResponse[0].pTime == null // Add logic to get longitude
        });
          fetchAttendance();
      
    } catch (e) {
        showMessage(context, '$e');
        print("error: $e");
     }
     context.loaderOverlay.hide();
  }

  @override
void dispose() {
  // Cancel the Timer
  _timer?.cancel();

  // Ensure to only clean up resources and avoid invoking lifecycle-dependent methods
  super.dispose();
}

  

  @override
  Widget build(BuildContext context) {

  if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance"),),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (attendanceResponse.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance"),),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance"),),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                children: [
                  const Text("Current Location:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.redAccent),),
                  const SizedBox(height: 10,),
                  Text(_currentAddress , textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10,),
                  Text(_currentDateTime , style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,)),
                ],
              ),
            ),
            // Expanded(child: Container()),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),

              child: attendanceResponse[0].pTime == null 
               ? ElevatedButton(
                onPressed: markAttendance, child: const Text('Mark Attendance IN')
                )
                : attendanceResponse[0].pTime != null && attendanceResponse[0].oTime == null
               ? Column(
                children: [
                  Text(" Makerd In At ${attendanceResponse[0].pTime}", style: const TextStyle(fontSize: 16),),
                   const SizedBox(height: 10,),
                  ElevatedButton(
                  onPressed: markAttendance,
                  child: const Text('Mark Attendance OUT'),
                )
                ],
                )
                : Text('Makerd Out At ${attendanceResponse[0].oTime}' , style: const TextStyle(fontSize: 16 , color: Colors.amber),),
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(onPressed: (){
                Navigator.pop(context, true);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceHistory()));
              }, text: "View Attendance History",),
            ),
            const SizedBox(height: 80),
          ]



        )
      ),
    );
  }
}