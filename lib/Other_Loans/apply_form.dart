import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Other_Loans/offer_list_page.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/Offer%20Response/offer_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ApplyForm extends StatefulWidget {
  final int employmentStatus; 
  final String mobileNo;
  const ApplyForm({super.key, required this.employmentStatus, required this.mobileNo});

  @override
  State<ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends State<ApplyForm> {
  final DioClient _client = DioClient();
  String? leadId;
  String? ip;
  final _formKey = GlobalKey<FormState>();
  OfferResponseModel? offerResponse;
  String errorMsg = "";
  DateTime? consentDate;
  String? gender;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController employerController = TextEditingController();
  final TextEditingController officePincodeController = TextEditingController();

  



  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final data = {
      "mobileNumber": widget.mobileNo,
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "pan": panController.text,
      "dob": dobController.text,
      "email": emailController.text,
      "pincode": pincodeController.text,
      "monthlyIncome": int.tryParse(incomeController.text) ?? 0,
      // "consumerConsentDate": '${consentDate?.toIso8601String()}',
      // "consumerConsentIp": ip,
      "employmentStatus": widget.employmentStatus,
      "employerName": employerController.text,
      "officePincode": officePincodeController.text,
      "gender": gender
    };

    context.loaderOverlay.show();
    try {
      final response = await _client.createLead(data);

      if (response["success"] == "true") {
        final message = response["message"]?.toString().toLowerCase() ?? "";
        leadId = response["leadId"];

        if (message.contains("already created") || message.contains("successfully")) {
          // Fetch offer for the existing or new lead
          try {
            final offerResponseVar = await _client.getOffers(leadId!);
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
                  leadId: leadId!, 
                  email: emailController.text, 
                  name: firstNameController.text, 
                  mobileNo: widget.mobileNo,
                  panNo: panController.text,
                  pincode: pincodeController.text,
                  saved: true,
                  ),
              ),
            );
          } catch (offerError) {
            errorMsg = "Offer fetch failed: $offerError";
            offerResponse = null;
            setState(() {});
          }
        } else {
          errorMsg = "Unknown response: $message";
          offerResponse = null;
          setState(() {});
        }
      } else {
        errorMsg = "Failed to create lead.";
        offerResponse = null;
        setState(() {});
      }
    } catch (e) {
      errorMsg = "Error: $e";
      offerResponse = null;
      setState(() {});
    }

    context.loaderOverlay.hide();
  }
}


  // getIp() async {
  //   var response = await _client.getPublicIpWithDio();
  //   ip = response;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getIp();
    consentDate = DateTime.now();
    if (kDebugMode) {
      firstNameController.text = "Raviraj";
      lastNameController.text = "Singh";
      panController.text = "MEKPS1034L";
      dobController.text = "1998-09-13";
      emailController.text = "iamtheraviraj@gmail.com";
      pincodeController.text = "212108";
      incomeController.text = "30000";
      employerController.text = "humana";
      officePincodeController.text = "110070";
      gender = "male";
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salaried'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: errorMsg.isNotEmpty 
        ?
          Center(
            child: Text(
              errorMsg,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            )
          )
        :
         Form(
          key: _formKey,
          child: 
            Column(
            children: [
              _buildTextField(
                controller: firstNameController,
                label: 'First Name',
              ),
              _buildTextField(
                controller: lastNameController,
                label: 'Last Name',
              ),
              _buildTextField(
                controller: panController,
                label: 'PAN',
                textCapitalization: TextCapitalization.characters,
              ),
              _buildDateField(dobController, 'Date of Birth'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: gender,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                items: const [
                  DropdownMenuItem(value: "male", child: Text('Male')),
                  DropdownMenuItem(value: "female", child: Text('Female')),
                  // DropdownMenuItem(value: 3, child: Text('Unemployed')),
                ],
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                inputType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: pincodeController,
                label: 'Pincode',
                inputType: TextInputType.number,
              ),
              _buildTextField(
                controller: incomeController,
                label: 'Monthly Income',
                inputType: TextInputType.number,
              ),
              // _buildDateField(consentDateController, 'Consent Date'),
              
              const SizedBox(height: 12),
              _buildTextField(
                controller: employerController,
                label: 'Employer Name',
              ),
              _buildTextField(
                controller: officePincodeController,
                label: 'Office Pincode',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}
