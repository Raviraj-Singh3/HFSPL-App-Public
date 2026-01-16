import 'dart:convert';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/group_training/attendence_radio.dart';
import 'package:HFSPL/group_training/update_account.dart';
import 'package:HFSPL/network/responses/cgt/cgt_model.dart';
import 'package:HFSPL/network/responses/cgt/model_get_cgt_by_id.dart';
import 'package:HFSPL/network/requests/post_cgt_model.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/utils/globals.dart';

class PerformGroupTrainingDay1To3 extends StatefulWidget {
  final CGTModel cgtGroup;
  const PerformGroupTrainingDay1To3({super.key, required, required this.cgtGroup });

  @override
  State<PerformGroupTrainingDay1To3> createState() =>
      _PerformGroupTrainingDay1To3State();
}

class _PerformGroupTrainingDay1To3State extends State<PerformGroupTrainingDay1To3> {
  bool varify = false;
  final DioClient _client = DioClient();
  List<CGTById> cgtByIdResponseList = [];
  Map<String, bool> isMemberDropped = {};
  Map<String, bool> isMemberPresent = {};
  final List<TextEditingController> _controllers = [];
  int day = 0;
  bool isLoading = true;

  // Fetch groups
  fetch() async {
    try {
      var response = await _client.getCGTById(widget.cgtGroup.cgtid!);
      setState(() {
        cgtByIdResponseList = response;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("$e")));
    }
    setState(() {
      isLoading = false;
    });
  }
  // Method to pick date
  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final String calenderText;
    if(day == 1){
      calenderText = 'DAY 2';
    }
    else if(day == 2){
      calenderText = 'DAY 3';
    }
    else {
      calenderText = 'Pre GRT';
    }
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Select Date For $calenderText",
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

  resendOtp(String clientId) async {
   
    try {

      if (!mounted) return;
      context.loaderOverlay.show();

      var response = await _client.resendOtp(clientId);
      cgtByIdResponseList.firstWhere((x)=>x.vid == clientId).otp = response;
      
      if (!mounted) return;
      context.loaderOverlay.hide();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP has been sent!')),
      );

      // print("Fetched response: ${response[0].name}");
    } catch (e) {
      print("Error sending otp: $e");
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Error sending otp: $e")));
    }
    
  }

  submitOtp(String clientId,String otp) async {
    context.loaderOverlay.show();

    try {

      var localOtp = cgtByIdResponseList.firstWhere((x)=>x.vid == clientId).otp.toString();
      
      if (localOtp == otp) {

         var response = await _client.submitOtp(clientId,otp);

         cgtByIdResponseList.firstWhere((x)=>x.vid == clientId).otpEntered = int.tryParse(otp);
         setState(() {
           
         });
        showMessage(context, "Successfully verified OTP");
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect OTP!')),
      );
      }
    } catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error Submitting OTP $e')),
      );

    }
    context.loaderOverlay.hide();
  }

  bool getIsMemberDropped(String vId){
    if (!isMemberDropped.containsKey(vId)) {
      return false;
    }
    return isMemberDropped[vId] ?? false;
  }
   String getIsMemberPresent(String vId){
    if (!isMemberPresent.containsKey(vId)) {
      return "false";
    }
    return (isMemberPresent[vId] ?? false).toString();
  }

  onSubmitClick() async{

    // if(day == 3 && cgtByIdResponseList.length < 3){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Minimum 3 members required to proceed')),
    //   );
    //   return;
    // }

    // if(day == 3 ){
    //     var otpfind = cgtByIdResponseList.map((e) => e.otpEntered).toList();
    //     bool containsZero = otpfind.contains(0);
    //     if (containsZero) {
    //       // Show SnackBar
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('OTP Required to Proceed')),
    //       );
    //       return;
    //     }
    //     print("otppp: $otpfind");
      
    // }

    await _pickDate(
        context); // Show date picker if at least one checkbox is checked

    if (selectedDate == null) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      
      return;
    }

     List<RequestPostCGTItem> items = [];
      var now = DateTime.now().toIso8601String();
      // var selectedDate = DateTime.now().toIso8601String();
      List<Member> listMembers = cgtByIdResponseList.map((m) {
        return Member(
          name: m.name,
          vid: m.vid,
          cgtmemberid: m.cgtmemberid, // Set as empty string, modify as necessary
          relative: m.relative,
          phone: m.phone.toString(),
          otp: m.otp,
          otpEntered: m.otpEntered,
          isDropped: getIsMemberDropped(m.vid!),
          day1: day == 1 ? getIsMemberPresent(m.vid!):null,
          day2: day == 2 ? getIsMemberPresent(m.vid!):null,
          day3: day == 3 ? getIsMemberPresent(m.vid!):null,
        );
      }).toList();

        var groupModel = RequestPostCGTItem(
          cgtid: widget.cgtGroup.cgtid,


          cgtday1done : day == 1 ? now : null,
          cgtday2 : day == 1 ? selectedDate.toString() : null,

          cgtday2done : day == 2 ? now : null,
          cgtday3 : day == 2 ? selectedDate.toString() : null,

          cgtday3done  : day == 3 ? now : null,
          pregrtday : day == 3 ? selectedDate.toString() : null,

          feid: Global_uid,
          groupid: widget.cgtGroup.groupid!,
          group: widget.cgtGroup.group,
          isSync: "true",
          members: listMembers,
        );
      
        items.add(groupModel);
    // submit items
    print(jsonEncode(items));
       context.loaderOverlay.show();
     try {
        var response = await _client.postCGT(items);
       

          if (response.statusCode == 200) {
          // Handle success
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Completed Successfully!')),
          );
          context.loaderOverlay.hide();
          Navigator.pop(context, true);
          
        } else {
          // Handle API error
          if (!mounted) return;
          context.loaderOverlay.hide();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule CGT.')),
          );
          
        }
        context.loaderOverlay.hide();
     }
     catch (e){
         print("error... $e");
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('$e')),
          );
         context.loaderOverlay.hide();
     }
  }

  @override
  void initState() {
    super.initState();
    if (widget.cgtGroup.status == 0) {
      day=1;
    }
    else if (widget.cgtGroup.status == 2) {
      day=2;
    }
    else if (widget.cgtGroup.status == 4) {
      day=3;
    }
    fetch();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perform CGT')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (cgtByIdResponseList.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perform CGT')),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perform CGT"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
              child: Text("GROUP NAME: ${widget.cgtGroup.group}")
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cgtByIdResponseList.length,
              padding: const EdgeInsets.only(bottom: 30),
              itemBuilder: (context, index) {
                _controllers.add(TextEditingController());
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(''),
                            Text(
                              cgtByIdResponseList[index].name!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                              Row(
                                children: [
                                  const Text("Drop"),
                                  Checkbox(
                                          value: isMemberDropped[
                                                  cgtByIdResponseList[index].vid!] ??
                                              false,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isMemberDropped[cgtByIdResponseList[index]
                                                  .vid!] = value!;
                                            });
                                          },
                                  ),
                                ],
                              ),
                          ],
                        ),
                        ListTile(
                          // leading: Text('${index + 1}'),
                          title: Text(
                              'Spouse Name : ${cgtByIdResponseList[index].relative}'),
                          subtitle: Text(
                              'Mobile : ${cgtByIdResponseList[index].phone}'),
                        ),
                         AttendanceRadio(
                          onChanged: (isPresent) {
                            isMemberPresent[cgtByIdResponseList[index]
                                              .vid!] = isPresent;
                          },
                        ),
                        cgtByIdResponseList[index].otp != cgtByIdResponseList[index].otpEntered ? Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _controllers[index],
                                  onTapOutside: (PointerDownEvent event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  },
                                  decoration: const InputDecoration(
                                      label: Text("OTP"),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                onPressed: () {
                                  submitOtp(cgtByIdResponseList[index].vid!,_controllers[index].text);
                                }, child: const Text("VERIFY")),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                onPressed: () {
                                    resendOtp(cgtByIdResponseList[index].vid!);
                                }, child: const Text("RESEND")),
                          ],
                        ) : FilledButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateAccount(client: cgtByIdResponseList[index], groupId: widget.cgtGroup.groupid ?? "4029"),));
                        }, child: const Text("UPDATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.w600),)),

                        
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.deepPurple[800],
            width: double.infinity,
            child: TextButton(
                onPressed: () {
                  // print("button");
                  onSubmitClick();
                },
                child: Text(
                  'SUBMIT DAY $day',
                  style: const TextStyle(color: Color.fromARGB(255, 236, 208, 208)),
                )),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
