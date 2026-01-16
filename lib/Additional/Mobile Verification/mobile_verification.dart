import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Additional%20pages%20response/non_verified_groups.dart';
import 'package:HFSPL/network/responses/Additional%20pages%20response/non_verified_members.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MobileVerification extends StatefulWidget {
  const MobileVerification({super.key});

  @override
  State<MobileVerification> createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  final DioClient _client = DioClient();

  List<ActiveFeModel> feList = [];
  List<VerifyOwnFundNonVerifiedGroups> nonVerifiedGroups = [];
  List<VerifyOwnFundNonVerifiedMembers> nonVerifiedMembers = [];
  int? selectedFeId;
  int? selectedGroupId;
  
  // Map to store OTP text controllers for each member
  final Map<int, TextEditingController> otpControllers = {};
  // final Map<int, bool> verificationStatus = {};
  final Map<int, bool> isVerifying = {};

  bool isLoading = true;
  bool isLoadingGroups = false;
  bool isLoadingMembers = false;

  fetchFeList() async {
    try {
      var response = await _client.getAllActiveFeForBM(int.parse(Global_uid));
      setState(() {
        feList = response;
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  fetchNonVerifiedGroups() async {
    setState(() {
      isLoadingGroups = true;
      nonVerifiedGroups = [];
      nonVerifiedMembers = [];
      selectedGroupId = null;
    });
    
    try {
      var response = await _client.getNonVerifiedGroups(selectedFeId ?? 0);
      setState(() {
        nonVerifiedGroups = response;
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    } finally {
      setState(() {
        isLoadingGroups = false;
      });
    }
  }

  fetchNonVerifiedMembers() async {
    setState(() {
      isLoadingMembers = true;
      nonVerifiedMembers = [];
    });
    
    try {
      // Find the selected group to get its name
      var selectedGroup = nonVerifiedGroups.firstWhere(
        (group) => group.id == selectedGroupId,
        orElse: () => VerifyOwnFundNonVerifiedGroups(id: 0, name: ""),
      );
      
      var response = await _client.getNonVerifiedMembers(
        selectedGroupId ?? 0,
        groupName: selectedGroup.name,
        feId: selectedFeId ?? 0,
      );
      setState(() {
        nonVerifiedMembers = response;
        // Initialize controllers for new members
        for (var member in response) {
          if (!otpControllers.containsKey(member.id)) {
            otpControllers[member.id] = TextEditingController();
            // verificationStatus[member.id] = false;
            isVerifying[member.id] = false;
          }
        }
      });
    } catch (e) {
      showMessage(context, "Error: $e");
    } finally {
      setState(() {
        isLoadingMembers = false;
      });
    }
  }

  Future<void> verifyOTP(int memberId, String otp) async {
    if(otp.isEmpty){
      showMessage(context, "Please enter OTP");
      return;
    }
    setState(() {
      isVerifying[memberId] = true;
    });

    try {
      var response = await _client.verifyOwnfundNonVerifiedMember({
        "clientId": memberId,
        "otp": otp,
      });
      showMessage(context, response["message"]);
      if (response["status"] == true) {
        fetchNonVerifiedMembers();
      }
    } catch (e) {
      showMessage(context, "OTP verification failed: $e");
    } finally {
      setState(() {
        isVerifying[memberId] = false;
      });
    }
  }

  Future<void> resendOTP(int memberId, String phone) async {
    try {
      var response = await _client.sendOtpForOwnfundNonVerifiedMember(memberId);
      showMessage(context, response["message"]);
    } catch (e) {
      showMessage(context, "Failed to resend OTP: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFeList();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in otpControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Verification'),
        elevation: 2,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Field Executive',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: selectedFeId,
                          hint: const Text("Select FE"),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: feList.map((e) => DropdownMenuItem<int>(
                            value: e.feId,
                            child: Text(e.feName ?? ""),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFeId = value;
                            });
                            fetchNonVerifiedGroups();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoadingGroups)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!isLoadingGroups && nonVerifiedGroups.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Group',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<VerifyOwnFundNonVerifiedGroups>(
                            selectedItem: nonVerifiedGroups.firstWhere(
                              (element) => element.id == selectedGroupId,
                              orElse: () => nonVerifiedGroups.first,
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps:  TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Search group...",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              constraints: BoxConstraints(maxHeight: 300),
                            ),
                            items: nonVerifiedGroups,
                            itemAsString: (item) => item.name,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedGroupId = value.id;
                                });
                                fetchNonVerifiedMembers();
                              }
                            },
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Select Group",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isLoadingMembers)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!isLoadingMembers && nonVerifiedMembers.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: nonVerifiedMembers.length,
                      padding: const EdgeInsets.only(top: 8, bottom: 50),
                      itemBuilder: (context, index) {
                        final member = nonVerifiedMembers[index];
                        // final isVerified = verificationStatus[member.id] ?? false;
                        final isProcessing = isVerifying[member.id] ?? false;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
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
                                          if (member.relativeName != null)
                                            Text(
                                              member.relativeName!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // if (isVerified)
                                    //   const Icon(
                                    //     Icons.verified,
                                    //     color: Colors.green,
                                    //   ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      member.memberPhone1 ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                // if (!isVerified) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: otpControllers[member.id],
                                                decoration: const InputDecoration(
                                                  labelText: 'Enter OTP',
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  hintText: 'Enter OTP',
                                                ),
                                                keyboardType: TextInputType.number,
                                                // maxLength: 6,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            SizedBox(
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed: isProcessing
                                                    ? null
                                                    : () => verifyOTP(
                                                        member.id,
                                                        otpControllers[member.id]?.text ?? '',
                                                      ),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                ),
                                                child: isProcessing
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : const Text('Verify'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: () => resendOTP(
                                            member.id,
                                            member.memberPhone1 ?? "",
                                          ),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Resend OTP'),
                                        ),
                                      ],
                                    ),
                                  ),
                                // ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}