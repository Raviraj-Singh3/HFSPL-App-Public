
import 'dart:convert';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/radio_with_text_heading.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_pregrt_model.dart';
import 'package:HFSPL/network/responses/grt/grt_by_id_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PreGRTPage extends StatefulWidget {
  final GRTById cgtGroup;
  const PreGRTPage({super.key, required this.cgtGroup});

  @override
  State<PreGRTPage> createState() => _PreGRTPageState();
}

class _PreGRTPageState extends State<PreGRTPage> {
  final DioClient _client = DioClient();
  List<GRTById> grtByIdResponseList = [];
  List<int> id = [];
  Map<String, bool> isMemberDropped = {};
  Map<String, bool> isMemberPresent = {};
  Map<String, bool> isMemberPass = {};
  Map<String, bool> isBankCheck = {};

  fetch() async {
    try {
      var response = await _client.getGRTById(id);
      setState(() {
        grtByIdResponseList = response; //

        // Initialize isMemberPresent with default values (false for "Absent")
      for (var member in grtByIdResponseList) {
        isMemberPresent[member.memberCgtId.toString()] = false;
        isBankCheck[member.memberCgtId.toString()] = false;
        isMemberPass[member.memberCgtId.toString()] = false; // Default to "Absent"
      }
      });
      // print("Fetched response:.... ${grtByIdResponseList[0].groupName}");
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('$e')),
          );
          Navigator.pop(context,);
    }
  }

  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Select Date For GRT",
      initialDate: now, // Set today as the initial date
      firstDate: now, // Set minimum date to today
      lastDate:
          now.add(const Duration(days: 14)), // Max date is 14 days from today
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Update selected date
      });
    }
  }

  bool getIsMemberPresent(String memberCgtId){
    if (!isMemberPresent.containsKey(memberCgtId)) {
      return false;
    }
    return (isMemberPresent[memberCgtId] ?? false);
  }

  bool getisMemberPass(String memberCgtId){
    if (!isMemberPass.containsKey(memberCgtId)) {
      return false;
    }
    return (isMemberPass[memberCgtId] ?? false);
  }

  bool getIsBankCheck(String memberCgtId){
    if (!isBankCheck.containsKey(memberCgtId)) {
      return false;
    }
    return (isBankCheck[memberCgtId] ?? false);
  }

  bool getIsMemberDropped(String cgtId){
    if (!isMemberDropped.containsKey(cgtId)) {
      return false;
    }
    return isMemberDropped[cgtId] ?? false;
  }


  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

  // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, do something like showing a dialog
      // return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
  }

  // If permissions are granted, get the current position
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

  onSubmitClick()async {
    
    Position position = await _getCurrentLocation();

    await _pickDate(
        context); // Show date picker if at least one checkbox is checked

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    context.loaderOverlay.show();

    List<RequestPostPreGRT> items = [];

    List<PreGRTMember> listMembers = grtByIdResponseList.map((m) {
      return PreGRTMember(
        memberCGTId: m.memberCgtId.toString(),
        isDropped: getIsMemberDropped(m.memberCgtId.toString()),
        isPresent: getIsMemberPresent(m.memberCgtId.toString()),
        isPassed: getisMemberPass(m.memberCgtId.toString()),
        bankAcCheck: getIsBankCheck(m.memberCgtId.toString()),
        
      );
    }).toList();

    var groupModel = RequestPostPreGRT(
      cGTId: [widget.cgtGroup.groupCgtId.toString()],
      userId: Global_uid,
      grtDay: selectedDate,
      gRTMembers: listMembers,
      lat: position.latitude,
      lng: position.longitude,
      // lat: to be done
    );

    items.add(groupModel);
    // Convert your list of items to JSON
  // String jsonString = jsonEncode(items.map((item) => item.toJson()).toList());

  Map<String, dynamic> requestPayload = groupModel.toJson(); // Assuming you have a toJson() method in your model class

  try {
        var response = await _client.postPreGRT(requestPayload);
       
          if (response.statusCode == 200) {
          // Handle success
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pre GRT Completed Successfully!')),
          );
          // context.loaderOverlay.hide();
          Navigator.pop(context, true);
          
        } else {
          // Handle API error
          if (!mounted) return;
          // context.loaderOverlay.hide();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule GRT.')),
          );
          
        }
     }
     catch (e){
        showMessage(context, "$e");
     }
    context.loaderOverlay.hide();
  } 
  @override
  void initState() {
    // TODO: implement initState
    id.add(widget.cgtGroup.groupCgtId!);
    super.initState();
    fetch();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pre GRT"),),
      body: Column(
          children: [
            Expanded(
              child: grtByIdResponseList.isEmpty
                ? const Center(
                          child: CircularProgressIndicator(
                          ),
                        )
                : ListView.builder(
                  itemCount: grtByIdResponseList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(grtByIdResponseList[index].memberName!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
                            SizedBox(height: 20,),
                            RowWithData(
                                title: 'Group Name :',
                                data: grtByIdResponseList[index].groupName,
                                ),
                            
                            RowWithData(
                                title: 'Spouse Name :',
                                data: grtByIdResponseList[index].spouseName,
                                ),
                            RowWithData(
                                title: 'Nominee Name :',
                                data: grtByIdResponseList[index].nomineeName,
                                ),
                            RowWithData(
                                title: 'Mobile :',
                                data: grtByIdResponseList[index].phoneNumber.toString(),
                                ),
                            RowWithData(
                                title: 'Eligible Amount :',
                                data: grtByIdResponseList[index].eligibleAmount.toString(),
                                ),
                            
                            RadioWithTextHeading(
                              heading: 'Bank Details', 
                              radioTitle1: 'Correct',
                               radioTitle2: 'Incorrect', 
                               groupValue: isBankCheck[grtByIdResponseList[index].memberCgtId.toString()], 
                               onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isBankCheck[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                                row1Title: 'Account Number :',
                                row1Data: grtByIdResponseList[index].bankAcNo,
                                row2Title: 'IFSC :',
                                row2Data: grtByIdResponseList[index].bankIFSC,
                               ),
                            
                            RadioWithTextHeading(
                              heading: "Attendance",
                              radioTitle1: 'Present',
                              radioTitle2: 'Absent',
                              groupValue: isMemberPresent[grtByIdResponseList[index].memberCgtId.toString()],
                              onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isMemberPresent[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                              ),
                            
                            RadioWithTextHeading(
                              heading: "Member GRT",
                              radioTitle1: 'Pass',
                              radioTitle2: 'Fail',
                              groupValue: isMemberPass[grtByIdResponseList[index].memberCgtId.toString()],
                              onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isMemberPass[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                              ),
                            Row(
                                children: [
                                  const Text("Drop Member", style: TextStyle(fontSize: 16),),
                                  Checkbox(
                                          value: isMemberDropped[
                                                  grtByIdResponseList[index].memberCgtId.toString()] ??
                                              false,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isMemberDropped[grtByIdResponseList[index]
                                                  .memberCgtId.toString()] = value!;
                                                // check = value!;
                                            });
                                          },
                                  ),
                                ],
                              ),

                            // SizedBox(height: 20,),
                          ],
                        ),
                      ),
                    );
                  },),
            ),
            const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(onPressed: onSubmitClick, text: 'SUBMIT PRE GRT'),
          ),
          ],
      )
    );
  }
}