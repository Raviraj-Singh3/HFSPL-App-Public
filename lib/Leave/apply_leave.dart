import 'dart:convert';
import 'dart:io';

import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Functions/image_picker.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/leave_request_model.dart';
import 'package:HFSPL/network/responses/LeaveResponse/reporting_person_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_response.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:loader_overlay/loader_overlay.dart'; // Add this dependency

class ApplyLeave extends StatefulWidget {
  final LeaveModelResponse leaveResponse;

  const ApplyLeave({super.key, required this.leaveResponse});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  final DioClient _client = DioClient();
  List<DateTime> selectedDates = [];
   List<ReportingPersonModel> reportingPerson = [];
  int? selectedReportingPerson;

  File? _selectedImage;

 TextEditingController descrpitionController = TextEditingController();

  _openDatePicker(BuildContext context) async {
    List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.multi,
        selectedDayHighlightColor: Colors.blue,
      ),
      dialogSize: const Size(325, 400),
      value: selectedDates,
      borderRadius: BorderRadius.circular(15),
    );

    if (pickedDates != null) {
      setState(() {
        selectedDates = pickedDates.whereType<DateTime>().toList();
      });
    }
  }

  _getReporitngPerson() async {
    try {
      var response = await _client.getReportingPerson(Global_uid);
      setState(() {
        reportingPerson = response;
      });
    } catch (e) {
      showMessage(context, "$e");
    }
  }

  @override
  void initState() {
    _getReporitngPerson();
    super.initState();
  }

  @override
  void dispose() {
    descrpitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave Type and Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.leaveResponse.leaveName!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      backgroundColor: Colors.teal.withOpacity(0.2),
                      label: Text(
                        '${widget.leaveResponse.balance} Days',
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Select Dates Button
                ElevatedButton.icon(
                  onPressed: () => _openDatePicker(context),
                  icon: const Icon(Icons.date_range, size: 20),
                  label: const Text('Select Dates'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Selected Dates as Chips
                if (selectedDates.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: selectedDates.map((date) {
                      return Chip(
                        label: Text('${date.day}/${date.month}/${date.year}'),
                        backgroundColor: Colors.blue.shade50,
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () {
                          setState(() {
                            selectedDates.remove(date);
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),

                // Reporting Person Dropdown
                if (reportingPerson.isNotEmpty)
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Reporting Person',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: selectedReportingPerson,
                    items: reportingPerson.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReportingPerson = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),

                // Description Input
                TextField(
                  controller: descrpitionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter details about your leave...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Proof if Required
                if (widget.leaveResponse.isProofRequired == true)
                  Center(
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.upload, size: 40, color: Colors.teal),
                                  Text("Upload Proof", style: TextStyle(color: Colors.teal.shade700)),
                                ],
                              ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Submit Button
                
                PrimaryButton(onPressed: _submit, text: "Apply Leave"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectImage() async {

    File image = await pickImageFromGallary();
      setState(() {
        _selectedImage = image;
      });
  }

  _submit() async {
    if (selectedDates.isEmpty) {
      showMessage(context, 'Please select dates');
      return;
    }

    if (selectedReportingPerson == null) {
      showMessage(context, 'Please select reporting person');
      return;
    }

    if(descrpitionController.text.isEmpty) {
      showMessage(context, 'Please enter description');
      return;
    }

    FormData formData = FormData();

    if(widget.leaveResponse.isProofRequired == true) {
      if (_selectedImage == null) {
        showMessage(context, 'Please select image');
        return;
      }
      Map<int, File> files = {};
      files[1] = _selectedImage!;

      for (var map in files.entries) {
      formData.files.add(MapEntry(
          map.key.toString(),
          await MultipartFile.fromFile(
            _selectedImage!.path,
            filename: _selectedImage!.path.split('/').last // Specify the filename
          ),
        ));
        }
    }
    
    var request = selectedDates.map((e) {
      return LeaveRequestModel(
        createdBy: int.parse(Global_uid),
        description: descrpitionController.text.trim(),
        isApproved: false,
        lID: widget.leaveResponse.lid,
        lTypeDay: 1,
        leaveDate: '${e.year}-${e.month}-${e.day}',
        staffif: int.parse(Global_uid),
        toReport: selectedReportingPerson,
      );
    }).toList();

    context.loaderOverlay.show();

    var json= request.map((e) => e.toJson()).toList();

    formData.fields.add(MapEntry("listAdded", jsonEncode(json)));
    
    try {
      var response = await _client.applyLeave(
        formData
      );
      showMessage(context, "Application Submitted Successfully.. You Will receive an Email Response");
      Navigator.pop(context, true);
    } catch (e) {
      showMessage(context, "$e");
    }
    context.loaderOverlay.hide();
  }
  
}
