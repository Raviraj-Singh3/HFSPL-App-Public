import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Leave/apply_leave.dart';
import 'package:HFSPL/Leave/leave_card.dart';
import 'package:HFSPL/Leave/leave_history.dart';
import 'package:HFSPL/network/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_response.dart';
import 'package:HFSPL/utils/globals.dart';

class Leave extends StatefulWidget {
  const Leave({super.key});

  @override
  State<Leave> createState() => _LeaveState();
}

class _LeaveState extends State<Leave> {

  final DioClient _client = DioClient();

  bool isLoading = true;

   List<LeaveModelResponse>? leaveResponse;

  

fetch() async {

  try {
  var response = await _client.getLeaveBalance(Global_uid);
  setState(() {
    leaveResponse = response;
    isLoading = false;
  });
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
  setState(() {
    isLoading = false;
  });
}

}





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    
    if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('LEAVE')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (leaveResponse == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('LEAVE')),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(title: const Text('LEAVE')),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeaveCard(
                  color: Colors.green[300],
                  title: 'Sick Leave',
                  icon: Icons.sick,
                  balance: leaveResponse?[0].balance ?? 0.0,
                  used: leaveResponse?[0].usedLeave ?? 0.0,
                  onTap: () {
                  // Navigate to the Apply Leave page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyLeave(leaveResponse: leaveResponse![0]),
                    ),
                  );
                },
                ),
                LeaveCard(
                  color: Colors.teal[300],
                  title: 'Casual Leave',
                  icon: Icons.beach_access,
                  balance: leaveResponse![1].balance ?? 0.0,
                  used: leaveResponse![1].usedLeave ?? 0.0,
                   onTap: () {
                  // Navigate to the Apply Leave page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyLeave(leaveResponse: leaveResponse![1]),
                    ),
                  );
                },
                ),
                // SizedBox(height: 20),
                LeaveCard(
                        color: Colors.amber[300],
                        title: 'Earned Leave',
                        icon: Icons.wallet,
                        balance: leaveResponse![2].balance ?? 0.0,
                        used: leaveResponse![2].usedLeave ?? 0.0,
                        onTap: () {
                        // Navigate to the Apply Leave page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ApplyLeave(leaveResponse: leaveResponse![2]),
                          ),
                        );
                      },
                      ),

                SizedBox(height: 40),

                PrimaryButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveHistory()));
                }, text: "Leave History",),

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
