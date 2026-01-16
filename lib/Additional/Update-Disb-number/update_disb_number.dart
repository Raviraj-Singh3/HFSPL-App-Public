import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Funder/funder_details_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_branch_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_center_response.dart';
import 'package:HFSPL/network/responses/Funder/funder_member_response.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:dio/dio.dart';

class UpdateDisbNumber extends StatefulWidget {
  const UpdateDisbNumber({super.key});

  @override
  State<UpdateDisbNumber> createState() => _UpdateDisbNumberState();
}

class _UpdateDisbNumberState extends State<UpdateDisbNumber> {
  final DioClient _client = DioClient();
  
  // Data lists
  FunderDetailsResponse? funderDetails;
  Funder? selectedFunder;
  FunderBranch? selectedBranch;
  List<ActiveFeModel> feList = [];
  ActiveFeModel? selectedFe;
  List<FunderCenterResponse> centers = [];
  FunderCenterResponse? selectedCenter;
  List<FunderMemberResponse> members = [];
  List<FunderMemberResponse> filteredMembers = [];
  
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController mobileEditController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      // Load funder details using Global_uid
      final details = await _client.getFunderDetails(Global_uid);
      setState(() {
        funderDetails = details;
        // If there's only one funder, select it automatically
        if (details.funders.length == 1) {
          selectedFunder = details.funders.first;
          selectedBranch = null; // Reset branch selection
        }
      });
    } catch (e) {
      _showError('Error loading funder details');
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadBranches() async {
    if (selectedFunder == null) return;
    setState(() {
      selectedBranch = null;
      selectedFe = null;
      selectedCenter = null;
      centers = [];
      members = [];
      filteredMembers = [];
    });
  }

  Future<void> _loadFe() async {
    if (selectedBranch == null) return;
    setState(() => isLoading = true);
    try {
      final feData = await _client.getAllActiveFe(selectedBranch!.branchId);
      
      setState(() {
        feList = Global_designationName == "FE" ? feData.where((fe) => fe.feId == int.parse(Global_uid)).toList() : feData;
        selectedFe = null;
        selectedCenter = null;
        members = [];
        filteredMembers = [];
      });
    } catch (e) {
      _showError('Error loading FE list');
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadCenters() async {
    if (selectedFe?.feId == null) return;
    setState(() => isLoading = true);
    try {
      final centerList = await _client.getAllActiveCenters(selectedFe!.feId!);
      setState(() {
        centers = centerList;
        selectedCenter = null;
        members = [];
        filteredMembers = [];
      });
    } catch (e) {
      _showError('Error loading centers');
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadMembers() async {
    if (selectedCenter == null) return;
    setState(() => isLoading = true);
    try {
      final memberList = await _client.getAllDisbursedMembers(selectedCenter!.centerId);
      setState(() {
        members = memberList;
        filteredMembers = memberList;
      });
    } catch (e) {
      _showError('Error loading members');
    }
    setState(() => isLoading = false);
  }

  void _filterMembers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredMembers = members;
      });
      return;
    }
    setState(() {
      filteredMembers = members
          .where((member) =>
              member.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      //make this 6 seconds
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showOtpDialog(FunderMemberResponse member, String newPhone) {
    otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter OTP sent to $newPhone',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (otpController.text.length != 6) {
                _showError('Please enter valid 6-digit OTP');
                return;
              }
              Navigator.pop(context);
              await _verifyAndUpdatePhone(member, newPhone, otpController.text);
            },
            child: const Text('VERIFY'),
          ),
        ],
      ),
    );
  }

  void _showEditMobileDialog(FunderMemberResponse member) {
    mobileEditController.text = member.memberPhone1.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Mobile Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mobileEditController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: isUpdating 
              ? null 
              : () async {
                  if(mobileEditController.text.isEmpty || mobileEditController.text.length != 10){
                    _showError('Please enter a valid mobile number');
                    return;
                  }
                  Navigator.pop(context);
                  await _initiatePhoneUpdate(member, mobileEditController.text);
                },
            child: isUpdating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showDetailedErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePhoneUpdate(FunderMemberResponse member, String newPhone) async {
    setState(() => isUpdating = true);
    try {
      dynamic response = await _client.initiatePhoneUpdate(
        member.clientId,
        newPhone,
        member.name,
        int.parse(Global_uid),
      );

      // Handle response as Map
      if (response is Map<String, dynamic>) {
        if (response['requiresOtp'] == true) {
          _showOtpDialog(member, newPhone);
        } else if (response['updated'] == true) {
          String successMessage = (response['message'] ?? 'Mobile number updated successfully').toString();
          _showSuccess(successMessage);
          // Refresh the member list
          if (selectedCenter != null) {
            await _loadMembers();
          }
        } else {
          String errorMessage = (response['error'] ?? 
                              response['message'] ?? 
                              'Failed to update mobile number').toString();
          _showDetailedErrorDialog('Update Failed', errorMessage);
        }
      }
    } catch (e) {
      // Show error dialog instead of snackbar for better visibility
      _showDetailedErrorDialog('Update Failed', e.toString());
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _verifyAndUpdatePhone(FunderMemberResponse member, String newPhone, String otp) async {
    setState(() => isUpdating = true);
    try {
      dynamic response = await _client.verifyPhoneUpdate(
        member.clientId,
        newPhone,
        otp,
        int.parse(Global_uid),
      );

      // Handle response as Map
      if (response is Map<String, dynamic>) {
        if (response['verified'] == true) {
          String successMessage = (response['message'] ?? 'Mobile number updated successfully').toString();
          _showSuccess(successMessage);
          // Refresh the member list
          if (selectedCenter != null) {
            await _loadMembers();
          }
        } else {
          String errorMessage = (response['error'] ?? 
                              response['message'] ?? 
                              'Failed to verify OTP').toString();
          _showDetailedErrorDialog('Verification Failed', errorMessage);
        }
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      // Show error dialog instead of snackbar for better visibility
      _showDetailedErrorDialog('Verification Failed', e.toString());
    } finally {
      setState(() => isUpdating = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMemberCard(FunderMemberResponse member) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Relative: ${member.relativeName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Mobile with edit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          member.memberPhone1.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditMobileDialog(member),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            // Bottom section - Group info
            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    member.groupName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Disbursed Number'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Scrollable Form Section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdowns Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Funder Dropdown
                            if (funderDetails != null)
                              Column(
                                children: [
                                  DropdownButtonFormField<Funder>(
                                    decoration: const InputDecoration(
                                      labelText: 'Select Funder',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedFunder,
                                    items: funderDetails!.funders.map((funder) {
                                      return DropdownMenuItem(
                                        value: funder,
                                        child: Text(funder.funderName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFunder = value;
                                        if (value != null) {
                                          _loadBranches();
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),

                            // Branch Dropdown
                            DropdownButtonFormField<FunderBranch>(
                              decoration: const InputDecoration(
                                labelText: 'Select Branch',
                                border: OutlineInputBorder(),
                              ),
                              value: selectedBranch,
                              items: selectedFunder?.branches.map((branch) {
                                return DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch.branchName),
                                );
                              }).toList() ?? [],
                              onChanged: (value) {
                                setState(() {
                                  selectedBranch = value;
                                  if (value != null) {
                                    _loadFe();
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // FE Dropdown
                            DropdownButtonFormField<ActiveFeModel>(
                              decoration: const InputDecoration(
                                labelText: 'Select FE',
                                border: OutlineInputBorder(),
                              ),
                              value: selectedFe,
                              items: feList.map((fe) {
                                return DropdownMenuItem(
                                  value: fe,
                                  child: Text(fe.feName ?? 'Unknown FE'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedFe = value;
                                  if (value?.feId != null) {
                                    _loadCenters();
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Center Dropdown
                            DropdownButtonFormField<FunderCenterResponse>(
                              decoration: const InputDecoration(
                                labelText: 'Select Center',
                                border: OutlineInputBorder(),
                                isCollapsed: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              isExpanded: true,
                              value: selectedCenter,
                              items: centers.map((center) {
                                return DropdownMenuItem(
                                  value: center,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 250),
                                    child: Text(
                                      center.centerName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCenter = value;
                                  if (value != null) {
                                    _loadMembers();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Members',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => _filterMembers(searchController.text),
                        ),
                      ),
                      onChanged: _filterMembers,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Members List Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMembers.isEmpty
                      ? Center(
                          child: Text(
                            'No members found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            return _buildMemberCard(filteredMembers[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mobileEditController.dispose();
    otpController.dispose();
    searchController.dispose();
    super.dispose();
  }
}