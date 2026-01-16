import 'dart:io';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/utils/New%20Image%20Picker/new_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/dde_request_models.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/messages_util.dart';
import 'package:HFSPL/utils/date_utils.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:geolocator/geolocator.dart';

class VerificationPerformSession extends StatefulWidget {
  final int ddeScheduleId;
  final String memberName;
  final String? scheduledDate;

  const VerificationPerformSession({
    Key? key,
    required this.ddeScheduleId,
    required this.memberName,
    required this.scheduledDate,
  }) : super(key: key);

  @override
  State<VerificationPerformSession> createState() => _VerificationPerformSessionState();
}

class _VerificationPerformSessionState extends State<VerificationPerformSession> {
  Map<String, dynamic>? memberDetails;
  bool isLoading = true;
  bool isSubmitting = false;
  final DioClient _client = DioClient();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sanctionAmountController = TextEditingController();
  final TextEditingController _bmRemarksController = TextEditingController();
  final TextEditingController _nameInBankController = TextEditingController();
  
  double? currentLatitude;
  double? currentLongitude;
  String? locationAddress;
  bool? verificationResult; // null = not selected, true = pass, false = fail
  bool bankVerified = false;
  bool documentsVerified = false;
  bool referencesVerified = false;
  final List<String> _riskFlagsOptions = const ['Address mismatch','Income mismatch','Bank name mismatch','Docs suspicious','Other'];
  final Set<String> _selectedRiskFlags = {};
  File? _houseImage;
  File? _businessImage;

  @override
  void initState() {
    super.initState();
    loadMemberDetails();
    getCurrentLocation();
  }

  Future<void> loadMemberDetails() async {
    setState(() => isLoading = true);
    try {
      final details = await _client.getVerificationDetailsById(widget.ddeScheduleId);
      setState(() {
        memberDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Failed to load member details: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await LocationUtil.getCurrentLocation();
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
      
      // Get address from coordinates
      // final address = await _client.getAddess(
      //   position);
      // setState(() {
      //   locationAddress = address['display_name'];
      // });
    } catch (e) {
      showMessage(context, 'Failed to get location: $e');
    }
  }

  Future<void> completeVerification() async {
    if (verificationResult == null) {
      showMessage(context, 'Please select verification result (Pass/Fail)');
      return;
    }

    if (_bmRemarksController.text.trim().isEmpty) {
      showMessage(context, 'Please add BM remarks');
      return;
    }

    if (currentLatitude == null || currentLongitude == null) {
      showMessage(context, 'Location not available. Please try again.');
      return;
    }

    if (_houseImage == null || _businessImage == null) {
      showMessage(context, 'Please capture house and business images');
      return;
    }

    setState(() => isSubmitting = true);
    context.loaderOverlay.show();

    try {
      final request = PostVerificationRequest(
        ddeScheduleId: widget.ddeScheduleId,
        verificationDateDone: DateTime.now().toIso8601String(),
        latitude: currentLatitude,
        longitude: currentLongitude,
        verificationPass: verificationResult!,
        notes: _notesController.text.trim(),
        sanctionAmount: double.tryParse(_sanctionAmountController.text.trim()),
        bankVerified: bankVerified,
        documentsVerified: documentsVerified,
        referencesVerified: referencesVerified,
        riskFlags: _selectedRiskFlags.join(','),
        bmRemarks: _bmRemarksController.text.trim(),
        nameInBank: _nameInBankController.text.trim(),
      );

      final result = await _client.postVerification(request, houseImage: _houseImage, businessImage: _businessImage);
      
      context.loaderOverlay.hide();
      setState(() => isSubmitting = false);
      
      final message = verificationResult! 
          ? 'Verification completed successfully! Member passed verification.'
          : 'Verification completed. Member failed verification.';
      
      showMessage(context, message);
      Navigator.pop(context, true); // Return true to indicate completion
    } catch (e) {
      context.loaderOverlay.hide();
      setState(() => isSubmitting = false);
      showMessage(context, 'Failed to complete verification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perform Verification')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberDetails == null
              ? const Center(child: Text('Failed to load member details'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Member Information',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Name', memberDetails!['Name'] ?? 'N/A'),
                              _buildInfoRow('Phone', memberDetails!['Phone']?.toString() ?? 'N/A'),
                              _buildInfoRow('Address', memberDetails!['Address'] ?? 'N/A'),
                              _buildInfoRow('Eligible Amount', 
                                memberDetails!['EligibleAmount'] != null 
                                  ? '₹${memberDetails!['EligibleAmount'].toStringAsFixed(0)}'
                                  : 'N/A'
                              ),
                              _buildInfoRow('DDE Date', 
                                memberDetails!['DDEDate'] != null
                                  ? DateFormat('dd-MM-yyyy').format(DateTime.parse(memberDetails!['DDEDate']))
                                  : 'N/A'
                              ),
                              _buildInfoRow('DDE Completion', 
                                memberDetails!['DDECompletionDate'] != null
                                  ? DateFormat('dd-MM-yyyy').format(DateTime.parse(memberDetails!['DDECompletionDate']))
                                  : 'N/A'
                              ),
                              if (memberDetails!['DDENotes'] != null)
                                _buildInfoRow('DDE Notes', memberDetails!['DDENotes']),
                            ],
                          ),
                        ),
                      ),
                      
                      // const SizedBox(height: 16),
                      
                      // Location Card
                      // Card(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Row(
                      //           children: [
                      //             Icon(Icons.location_on, color: Colors.green),
                      //             const SizedBox(width: 8),
                      //             Text(
                      //               'Current Location',
                      //               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 16),
                      //         if (currentLatitude != null && currentLongitude != null) ...[
                      //           _buildInfoRow('Latitude', currentLatitude!.toStringAsFixed(6)),
                      //           _buildInfoRow('Longitude', currentLongitude!.toStringAsFixed(6)),
                      //           if (locationAddress != null)
                      //             _buildInfoRow('Address', locationAddress!),
                      //         ] else
                      //           const Text(
                      //             'Getting location...',
                      //             style: TextStyle(color: Colors.orange),
                      //           ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      
                      const SizedBox(height: 16),
                      
                      // Verification Result Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user, color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verification Result',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  RadioListTile<bool>(
                                    title: const Text('Pass'),
                                    subtitle: const Text('Member meets requirements'),
                                    value: true,
                                    groupValue: verificationResult,
                                    onChanged: (bool? value) {
                                      setState(() => verificationResult = value);
                                    },
                                    activeColor: Colors.green,
                                  ),
                                  RadioListTile<bool>(
                                      title: const Text('Fail'),
                                      subtitle: const Text('Member does not meet requirements'),
                                      value: false,
                                      groupValue: verificationResult,
                                      onChanged: (bool? value) {
                                        setState(() => verificationResult = value);
                                      },
                                      activeColor: Colors.red,
                                    ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _sanctionAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Sanction Amount (<= Eligible Amount)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Verification Notes Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verification Notes',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _notesController,
                                // maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Enter verification notes and observations...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _bmRemarksController,
                                decoration: const InputDecoration(
                                  labelText: 'BM Remarks (required)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bank/Docs/Refs Checks
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.verified, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('Verification Checklist', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ]),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                title: const Text('Bank Verified'),
                                value: bankVerified,
                                onChanged: (v){ setState(()=> bankVerified = v ?? false); },
                              ),
                              CheckboxListTile(
                                title: const Text('Documents Verified'),
                                value: documentsVerified,
                                onChanged: (v){ setState(()=> documentsVerified = v ?? false); },
                              ),
                              CheckboxListTile(
                                title: const Text('References Verified'),
                                value: referencesVerified,
                                onChanged: (v){ setState(()=> referencesVerified = v ?? false); },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: _riskFlagsOptions.map((e) => FilterChip(
                                  label: Text(e),
                                  selected: _selectedRiskFlags.contains(e),
                                  onSelected: (sel){
                                    setState((){
                                      if(sel) _selectedRiskFlags.add(e); else _selectedRiskFlags.remove(e);
                                    });
                                  },
                                )).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('House Image'),
                                        const SizedBox(height: 8),
                                        OutlinedButton(
                                          onPressed: () async {
                                            final pickedImage = await getImage(ImageSource.camera);
                                            setState(()=> _houseImage = pickedImage);
                                          },
                                          child: Text(_houseImage==null? 'Capture' : 'Retake'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Business Image'),
                                        const SizedBox(height: 8),
                                        OutlinedButton(
                                          onPressed: () async {
                                            final pickedImage = await getImage(ImageSource.camera);
                                            setState(()=> _businessImage = pickedImage);
                                          },
                                          child: Text(_businessImage==null? 'Capture' : 'Retake'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Complete Button
                      AppButton(
                        text: isSubmitting ? 'Completing...' : 'Complete Verification',
                        onPressed: isSubmitting ? (dynamic _) => null : (dynamic _) => completeVerification(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
