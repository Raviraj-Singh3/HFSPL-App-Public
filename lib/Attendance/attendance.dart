import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Attendance/attendance_model.dart';
import 'package:HFSPL/utils/globals.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {


  final DioClient _client = DioClient();
  List<AttendanceModel> attendanceResponse = [];
  bool _isLoading = true;

  fetchAttendance() async {
    context.loaderOverlay.show();
    try {
      
      var response = await _client.getAttendanceHistory(int.parse(Global_uid));

      setState(() {
        attendanceResponse = response;
      });
    }
    catch(e) {
      showMessage(context, "Error fetching Attendance: $e");
    }
    context.loaderOverlay.hide();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAttendance();
  }
  @override
  Widget build(BuildContext context) {

    if(_isLoading){
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body:  const Center(child: Text('Loading. . .'))
      );
    }

  return Scaffold(
    appBar: AppBar(title: const Text('Dashboard')),
    body: attendanceResponse.isEmpty? const Center(child: Text('Data not available')) : Column(
      children: [
        Expanded(
          child: ListView.builder(itemCount: attendanceResponse.length, itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green.shade700, // Border color
                  width: 2.0, // Border width
                ),
              ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Date : "),
                      Text(attendanceResponse[index].dateTime ?? " ")
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      const Text("In Time : "),
                      Text(attendanceResponse[index].pTime ?? " ")
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      const Text("Out Time : "),
                      Text(attendanceResponse[index].oTime ?? " ")
                    ],
                  ),
                ],
              ),
            );
          // 
          },),
            
        ),
        const SizedBox(height: 40,),
        

      ],
    )
  )
  ;
}
}