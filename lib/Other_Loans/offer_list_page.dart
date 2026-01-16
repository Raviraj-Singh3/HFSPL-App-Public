import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Offer%20Response/offer_response_model.dart';
import 'package:HFSPL/network/responses/Offer%20Response/summary_offer_response.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferListPage extends StatefulWidget {
  final OfferResponseModel? offerResponse;
  final String leadId;
  final String name;
  final String email;
  final String mobileNo;
  final String panNo;
  final String pincode;
  final bool saved;

  const OfferListPage({super.key, required this.offerResponse, required this.leadId, required this.name, required this.email, required this.mobileNo, required this.panNo, required this.pincode, required this.saved});

  @override
  State<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends State<OfferListPage> {

  final DioClient _client = DioClient();
  SummaryOfferResponse? summaryOfferResponse;

  saveLead() async {
    var data = {
        "MobileNo": widget.mobileNo,
        "Name": widget.name,
        "Email": widget.email,
        "LeadId": widget.leadId,
        "MisUserLoginId": Global_uid,
        "PanNo": widget.panNo,
        "PinCode": widget.pincode,
        "LoanType": "Personal",
      };

    try {
      var response = await _client.saveLeadDetails(data);
    } catch (e) {
      print("Error saving lead: $e");
      showMessage(context, "Error saving lead: $e");
    }
  }

  fetchSummaryDetails() async {
    try {
      var response = await _client.summaryOfferApi(widget.leadId);

      if (response["success"] == "true") {
        
        summaryOfferResponse = SummaryOfferResponse.fromJson(response);
        setState(() {
          
        });
      }
      
    } catch (e) {
      print("error $e");
    }
  }

  sendOfferEmail(String lenderName, String offerAmountUpTo, String offerTenure, String offerInterestRate, String offerLink) async {

    var data = {
    "CustomerEmail": widget.email,
    "CustomerName": widget.name,
    "Offers": [
      {
        "LenderName": lenderName,
        "OfferAmountUpTo": offerAmountUpTo,
        "OfferTenure": offerTenure,
        "OfferInterestRate": offerInterestRate,
        "OfferLink": offerLink,
      }
    ]
  };
  context.loaderOverlay.show();
    try {

      var response = await _client.sendOfferEmail(data);
      
      print("response $response");
      showMessage(context, "Email sent successfully to ${widget.email}");

    } catch (e) {
      print("error $e");
    }
    context.loaderOverlay.hide();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSummaryDetails();
    if(widget.saved == true) {
      saveLead();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Offers")),
      body: widget.offerResponse!.offers.isEmpty
          ? const Center(child: Text("No offers available"))
        :
       Column(
  children: [
    Expanded(
      child: ListView.builder(
        itemCount: widget.offerResponse!.offers.length,
        itemBuilder: (context, index) {
          final offer = widget.offerResponse!.offers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Image.network(
                offer.lenderLogo,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
              title: Text(offer.lenderName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loan up to ₹${offer.offerAmountUpTo}"),
                  Text("Tenure: ${offer.offerTenure}"),
                  Text("Interest: ${offer.offerInterestRate}"),
                  Text("Fees: ${offer.offerProcessingFees}"),
                  Text("Status: ${offer.status}"),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  sendOfferEmail(offer.lenderName, offer.offerAmountUpTo, offer.offerTenure, offer.offerInterestRate, offer.offerLink);
                  // _launchURL(context, offer.offerLink);
                },
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(height: 10),

    if (summaryOfferResponse != null)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.blue.shade50,
          child: ListTile(
            leading: const Icon(Icons.auto_graph_rounded, color: Colors.blue, size: 40),
            title: const Text("Summary of Offers", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Offers: ${summaryOfferResponse!.summary.offersTotal}"),
                Text("Max Loan Amount: ₹${summaryOfferResponse!.summary.maxLoanAmount}"),
                Text("MPR: ${summaryOfferResponse!.summary.minMPR}% - ${summaryOfferResponse!.summary.maxMPR}%"),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () {
                sendOfferEmail("Summary Offer", summaryOfferResponse!.summary.maxLoanAmount, "", "MPR: ${summaryOfferResponse!.summary.minMPR}% - ${summaryOfferResponse!.summary.maxMPR}%", summaryOfferResponse!.redirectionUrl);
                // _launchURL(context, summaryOfferResponse!.redirectionUrl);
              },
            ),
          ),
        ),
      ),

    const SizedBox(height: 12),
  ],
),
    );
  }

 void _launchURL(BuildContext context, String url) async {
  
  final uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              throw Exception('Could not launch $uri');
      }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}
