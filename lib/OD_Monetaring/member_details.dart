import 'dart:convert';
import 'dart:io';

import 'package:HFSPL/Collection/location.dart';
import 'package:HFSPL/OD_Monetaring/call_screen.dart';
import 'package:HFSPL/OD_Monetaring/payment.dart';
import 'package:HFSPL/network/requests/od_post_visit_model.dart';
import 'package:HFSPL/network/requests/post_collection_data_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/open_google_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/OD/member_past_visit_details_model.dart';
import 'package:HFSPL/network/responses/OD/od_group_list.dart';

import '../Review_Update_KYC_Photos/Functions/image_picker.dart';

class MemberDetails extends StatefulWidget {
  final OdMember member;
  const MemberDetails({super.key, required this.member});

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  final DioClient _client = DioClient();
  GetMemberPastVisitDetails? memberDetails;
  bool isLoading = true;
  Map<int, dynamic> rawImageBytes = {};
  bool showHistory = false;
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController? _amtToPayController = TextEditingController();
  DateTime? selectedDate;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _getMemberDetails();
    
  }

  _getMemberDetails() async {
    try {
      var response = await _client.getMemberPastDetails(widget.member.misId);
      setState(() {
        memberDetails = response;
        _amtToPayController?.text = memberDetails?.demand?.demand.toString() ?? widget.member.totAmtPayable.toString();
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  _selectImage() async {

    File image = await pickImageFromCamera();
      setState(() {
        _selectedImage = image;
      });
  }

  Future<void> _pickDate(BuildContext context) async {
   
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now.add(Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "Select Date For next visit",
      initialDate: tomorrow, // Set today as the initial date
      firstDate: tomorrow, // Set minimum date to today
      lastDate:
          DateTime(2079, 1, 1), // Max date is 14 days from today
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _submitVisit() async {
    if (_observationController.text.isEmpty) {
      showMessage(context, "Please enter an observation.");
      return;
    }

    if(memberDetails?.details == null){
      showMessage(context, "Member Details are not available");
      return ;
    }
  
  await _pickDate(context);

  if(selectedDate == null ){
    showMessage(context, "visit date is not selected");
      return ;
  }

  var selectedReason = await _showClientReasons();

  if(selectedReason == null){
    showMessage(context, "Please select reason");
      return ;
  }

  await _selectImage();

  if(_selectedImage == null ){
    showMessage(context, "Please select Image");
      return ;
  }


  var detail = memberDetails!.details![0];

    try {

      Position position = await getCurrentLocation();

    var dataModel= PostMemberVisitingRequestModel(

      centerId: detail.centerId,
      clientId: detail.clientId,
      groupId: detail.groupId,
      meetingTypeId: 2,
      visitorId: int.parse(Global_uid),
      observation: _observationController.text,
      lat: position.latitude.toString(),
      lng: position.longitude.toString(),
      nextVisitDate: '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
      clientReason: selectedReason
    );

    FormData formData = FormData();

    formData.files.add(MapEntry(
      "file",
      await MultipartFile.fromFile(
        _selectedImage!.path,
        filename: _selectedImage!.path.split('/').last,
      ),
    ));

    formData.fields.add(MapEntry("listAdded", jsonEncode(dataModel)));

      if (!mounted) return;
      context.loaderOverlay.show();
      await _client.postMonitoring(formData);
      // showMessage(context, response);
      if (!mounted) return;
      showMessage(context, "Visit submitted successfully.");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, "Error: $e");
    }
    if (mounted) {
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    OdMember member = widget.member;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : memberDetails == null
              ? const Center(child: Text("No Data Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))
              : Stack(
                children: [
                SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Member Info Card
                        _buildInfoCard(member),
                
                        const SizedBox(height: 16),
                
                        // Demand Details
                        _buildDemandDetails(),
                
                        const SizedBox(height: 16),
                
                        // Toggle Button for Visit History
                        _buildVisitHistoryToggle(),
                
                        // Previous Visits (Collapsible)
                        if (showHistory) _buildVisitHistory(),
                
                        const SizedBox(height: 16),
                
                        const SizedBox(height: 16),
                
                        TextField(
                          controller: _observationController,
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: 
                            InputDecoration(
                              labelText: "Observation. . .",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, // Makes the button take full width
                          child: ElevatedButton.icon(
                            onPressed: _submitVisit,
                            icon: const Icon(Icons.save, size: 24, color: Colors.white),
                            label: const Text("Submit Visit", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4, // Adds subtle shadow
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                
                
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 28,  // Adjust this value to move it up/down
                    right: 10, // Adjust this value to move it left/right
                    child: SpeedDial(
                      animatedIcon: AnimatedIcons.menu_close,
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      overlayColor: Colors.black54,
                      spacing: 8,
                      spaceBetweenChildren: 12,
                      children: [
                        SpeedDialChild(
                          child: const Icon(Icons.directions, color: Colors.white),
                          backgroundColor: Colors.blue,
                          label: 'Get Directions',
                          labelStyle: const TextStyle(fontSize: 14),
                          onTap: () {
                            if(memberDetails?.latestLocation?.latitude == null || memberDetails?.latestLocation?.longitude == null){
                              showMessage(context, "No Location Available.");
                              return;
                            }
                            openGoogleMaps(
                            memberDetails!.latestLocation!.latitude!,
                            memberDetails!.latestLocation!.longitude!,
                            );
                          } 
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.call, color: Colors.white),
                          backgroundColor: Colors.green,
                          label: 'Call Member',
                          labelStyle: const TextStyle(fontSize: 14),
                          onTap: _openCallingPage, // Implement call function
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.currency_rupee, color: Colors.white),
                          backgroundColor: Colors.orange,
                          label: 'Payments',
                          labelStyle: const TextStyle(fontSize: 14),
                          onTap: _openEnterAmtDialog, // Implement message function
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  void _postOnline() async {

    Navigator.pop(context); // Close payment method dialog

    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentOd(member: widget.member, demandAmount: _amtToPayController!.text),));
    // if(result){
    //   setState(() {
    //     _getMemberDetails();
    //   });
    // }
  }

  void _openCallingPage (){
    Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(member: widget.member, clientId: memberDetails!.details![0].clientId!,)));
    // if(result){
    //   setState(() {
    //     _getMemberDetails();
    //   });
    // }
  }

  void _openEnterAmtDialog() {
    String error = "";
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInner) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter Amount to Pay.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  TextField(
                    controller: _amtToPayController,
                    keyboardType: TextInputType.number,
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      labelText: "Enter Amount", 
                      errorText: error.isNotEmpty ? error : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.teal, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      if (_amtToPayController?.text.isEmpty ?? true) {
                        setStateInner(() {
                          error = "Amount cannot be empty";
                        });
                      } else if (double.tryParse(_amtToPayController?.text ?? '') == null) {
                        setStateInner(() {
                          error = "Please enter a valid number";
                        });
                      } else if (double.parse(_amtToPayController?.text ?? '0') <= 0) {
                        setStateInner(() {
                          error = "Amount must be greater than 0";
                        });
                      } else {
                        error = "";
                        Navigator.pop(context); // Close amount dialog first
                        _openPaymentDialog(); // Then open payment method dialog
                      }
                    },
                    child: const Text("Ok")
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _openPaymentDialog() {
    
    // Don't close any dialog here since we already closed the amount dialog
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Divider(),
            ListTile(
              leading: Icon(Icons.money, color: Colors.green),
              title: Text("Cash"),
              onTap: () async {
                Navigator.pop(context); // Close payment method dialog
                // Wait a bit for the dialog to close, then proceed
                await Future.delayed(Duration(milliseconds: 100));
                if (mounted) {
                  postCollection();
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: Text("Online"),
              onTap: () async {
                Navigator.pop(context); // Close payment method dialog
                // Wait a bit for the dialog to close, then proceed
                await Future.delayed(Duration(milliseconds: 100));
                if (mounted) {
                  _postOnline();
                }
              }, 
            ),
          ],
        ),
      ),
    ),
  );
}


 void postCollection () async{

  // print("Posting Collection...");

  if (!mounted) return;
  context.loaderOverlay.show();

  try {

    Position position = await getCurrentLocation();

    if (!mounted) return;

    List <PostCollectionDataModel> items = [];

    items.add(
      PostCollectionDataModel(
        isPresent: true,
        amount: double.tryParse(_amtToPayController!.text),
        lat: position.latitude,
        lng: position.longitude,
        mId: widget.member.misId,
        postedBy: int.parse(Global_uid),
      )
    );

    await _client.postCollection(jsonEncode(items));

    if (!mounted) return;
    showMessage(context, "Collection posted successfully!");

    // Close the amount entry dialog
    if (mounted) {
      Navigator.pop(context, true);
    }
        
       
  } catch (e) {
    if (!mounted) return;
    showMessage(context, "Error Posting...");
    // Close the amount entry dialog even on error
    if (mounted) {
      Navigator.pop(context, true);
    }
  }
  if (mounted) {
    context.loaderOverlay.hide();
  }
 }



  Widget _buildInfoCard(OdMember member) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.person, "Member Name", member.memberName),
            _infoRow(Icons.family_restroom, "Spouse Name", member.spouse),
            _infoRow(Icons.confirmation_number, "Loan Number", member.loanNo),
            _infoRow(Icons.date_range, "Loan Date", member.loanDate),
            _infoRow(Icons.schedule, "OD Start Date", member.odStartDate),
            _infoRow(Icons.money, "Total OD Amount", member.totAmtPayable.toString()),
            _infoRow(Icons.account_balance_wallet, "OD POS", member.principleOS.toString()),
            _infoRow(Icons.attach_money, "OD IOS", member.interestOS.toString()),
            _infoRow(Icons.calculate, "Total OS", member.totalOS.toString()),
            _infoRow(Icons.account_balance, "Total POS", member.prAmtPayable.toString()),
            _infoRow(Icons.paid, "Total IOS", member.intrAmt.toString()),
            _infoRow(Icons.calendar_today, "Last Transaction", member.lastTransactionDate),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.teal),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 28),
          if (label == "Loan Number" || label == "Observation")
            Text(value ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400))
          else
            Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
        ],
      ),
    ),
  );
}


  Widget _buildDemandDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _infoRow(Icons.warning, "Current Penalty", memberDetails?.demand?.penalty.toString() ?? "0.0"),
            _infoRow(Icons.money_off, "Today's Demand", memberDetails?.demand?.demand.toString()?? widget.member.totAmtPayable.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitHistoryToggle() {
    return GestureDetector(
      onTap: () => setState(() => showHistory = !showHistory),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Previous Visits", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Icon(showHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitHistory() {
    return Column(
      children: [
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberDetails?.history?.length,
          itemBuilder: (context, index) {
            var visit = memberDetails!.history![index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.date_range, "Visit Date", visit.cDate),
                    _infoRow(Icons.person, "Visited By", visit.visitedBy),
                    _infoRow(Icons.notes, "Observation", visit.observation),
                    _infoRow(Icons.event, "Next Visit", visit.nextVisitDate),
                    _infoRow(Icons.question_answer, "Reason", visit.clientReason),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewPhoto(visit.id),
                        icon: const Icon(Icons.image),
                        label: const Text("View Photo"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  _viewPhoto(int? id) async {
    try {
      if (rawImageBytes[id] != null) {
        _showImageDialog(rawImageBytes[id]);
        return;
      }
      if (!mounted) return;
      context.loaderOverlay.show();
      var response = await _client.getMonitaring(id!);
      if (!mounted) return;
      setState(() => rawImageBytes[id] = response);
      _showImageDialog(response);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, "Error: $e");
    }
    if (mounted) {
      context.loaderOverlay.hide();
    }
  }

  void _showImageDialog(dynamic imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Image.memory(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  // void openGoogleMaps(String lat, String lng) async {
    
  //     String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
  //     if (await canLaunchUrl(Uri.parse(googleUrl))) {
  //       await launchUrl(Uri.parse(googleUrl));
  //     } else {
  //       throw 'Could not open Google Maps';
  //     }
  //   }

    Future _showClientReasons() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: ListBody(
              children: memberDetails!.reasons!
                  .map((item) {
                    return ListTile(
                        title: Text(item),
                        onTap: () => Navigator.pop(context, item),
                      );
                  })
                  .toList(), // Ensures it returns List<Widget>
            ),
        ),
      ),
    );
  }
}
