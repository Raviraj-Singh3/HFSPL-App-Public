import 'package:HFSPL/Audit/dummy.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Other_Loans/apply_form.dart';
import 'package:HFSPL/Other_Loans/apply_form_self_implyoed.dart';
import 'package:HFSPL/Other_Loans/offer_list_page.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Offer%20Response/lead_details_response.dart';
import 'package:HFSPL/network/responses/Offer%20Response/mobile_response.dart';
import 'package:HFSPL/network/responses/Offer%20Response/offer_response_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class MobileCheck extends StatefulWidget {
  const MobileCheck({super.key});

  @override
  State<MobileCheck> createState() => _MobileCheckState();
}

class _MobileCheckState extends State<MobileCheck> {
  final TextEditingController _mobileController = TextEditingController();
  final DioClient _client = DioClient();
  String? message;
  int employmentStatus = 1;
  String? mobileNo;
  bool _isMobileFieldDisabled = false;
  MobileCheckResponse? mobileCheckResponse;
  LeadDetailsResponse? leadDetailsResponse;
  List<LeadData> filteredLeads = [];
  OfferResponseModel? offerResponse;
  String errorMsg = "";

void _checkMobileEligibility() async {
  final mobile = _mobileController.text.trim();
  if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
    showMessage(context, "Please enter a valid 10-digit mobile number");
    return;
  }
  // TODO: Call your API or logic here
  // showMessage(context, "Checking eligibility for $mobile");
context.loaderOverlay.show();
  try {
    var response =  await _client.checkMobileForLoan({
      "mobileNumber": mobile,
  });

  mobileCheckResponse = response;
  mobileNo = mobile;

  if (mobileCheckResponse?.success == "true") {
      _isMobileFieldDisabled = true;
  }

    setState(() {
    });

  } catch (e) {
    showMessage(context, "Error: $e");
  }
context.loaderOverlay.hide();


}

fetchLeads() async {
  try {
    var response = await _client.getLeadDetails(Global_uid);
    print("response: ${response}");
    setState(() {
      leadDetailsResponse = response;
      filteredLeads = response.data;
    });
    print("response: ${response}");
  } catch (e) {
    print("Error fetching leads: $e");
    showMessage(context, "Error fetching leads: $e");
  }
}

void onHistoryTap(LeadData lead) async {
  print("Tapped on lead ID: ${lead.leadId}");
  try {
    final offerResponseVar = await _client.getOffers(lead.leadId);
    setState(() {
      offerResponse = offerResponseVar;
      errorMsg = "";
    });
    // Navigate to the offer page and pass the data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferListPage(
          offerResponse: offerResponseVar,
           leadId: lead.leadId,
            email: lead.email ?? "",
             name: lead.name, 
             mobileNo: lead.mobileNo.toString(),
             panNo:  "",
             pincode:  "",
             saved: false,
             ),
      ),
    );
  } catch (offerError) {
    print("Error fetching offers: $offerError");
    // errorMsg = "Offer fetch failed: $offerError";
    showMessage(context, "$offerError");
    offerResponse = null;
    setState(() {});
  }
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLeads();
    _mobileController.addListener(() {
    filterLeads(_mobileController.text);
  });
  }
  void filterLeads(String query) {
  setState(() {
    filteredLeads = leadDetailsResponse?.data
        .where((lead) => lead.mobileNo.toString().contains(query))
        .toList() ?? [];
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Check'),
      ),
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// --- MOBILE CHECK BOX ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Check Loan Eligibility",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !_isMobileFieldDisabled,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  hintText: "Enter 10-digit mobile",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                onPressed: () {
                  if (_isMobileFieldDisabled) {
                    showMessage(context, "Already checked eligibility.");
                    return;
                  }
                  _checkMobileEligibility();
                },
                text: "Check Now",
              ),
              const SizedBox(height: 8),

              if (mobileCheckResponse != null)
                Center(
                  child: Text(
                    mobileCheckResponse?.message == "Eligible"?
                        "Congratulations! You are eligible for a loan." :
                        "Sorry, you are not eligible for a loan.",
                    style: TextStyle(
                      fontSize: 16,
                      color: mobileCheckResponse?.message == "Eligible"
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (mobileCheckResponse?.message == "Eligible") ...[
                const SizedBox(height: 20),
                const Text(
                  "Employment Type",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: employmentStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Salaried')),
                    DropdownMenuItem(value: 2, child: Text('Self-Employed')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      employmentStatus = val!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: _applyForm,
                  text: "Apply Now",
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// --- PREVIOUS APPLICATIONS ---
        if (leadDetailsResponse != null && filteredLeads.isNotEmpty) ...[
          const Text(
            "Previous Applications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredLeads.where((lead) => lead.loanType == 'Personal').toList().length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final lead = filteredLeads.where((lead) => lead.loanType == 'Personal').toList()[index];
              return InkWell(
                onTap: () => onHistoryTap(lead),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.history, color: Colors.blue),
                    ),
                    title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                              lead.mobileNo.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMM yyyy').format(lead.createdDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    ),
  ),
      ),
    );
  }
  void _applyForm() {
    if (mobileNo == null) {
      showMessage(context, "Please check your eligibility first.");
      return;
    }
    if (employmentStatus == 1) {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApplyForm(mobileNo: mobileNo!, employmentStatus: employmentStatus,)),
    );
    }
    else {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApplyFormSelfImplyoed(mobileNo: mobileNo!, employmentStatus: employmentStatus,)),
      );
    }
  }
}