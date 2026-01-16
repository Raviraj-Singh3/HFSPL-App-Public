import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Compress-Image/compress.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_update_account.dart';
import 'package:HFSPL/network/responses/cgt/clientwithBankDetails.dart';
import 'package:HFSPL/network/responses/cgt/loan_tenure_model.dart';
import 'package:HFSPL/network/responses/cgt/model_get_cgt_by_id.dart';
import 'package:HFSPL/utils/globals.dart';

class UpdateAccount extends StatefulWidget {
  final CGTById client;
  final String groupId;

  const UpdateAccount({super.key, required this.client, required this.groupId});

  @override
  State<UpdateAccount> createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  final DioClient _client = DioClient();
  final ImagePicker _picker = ImagePicker(); 
  ClientAccountDetailsResponse? clientWithBankResponse;
  LoanTenureModel? loanTenureResponse;
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController = TextEditingController();
  File? _image;
  String _imageName = "";

  String? selectedLoanPurpose;
  double? selectedProduct;
  String? selectedLoanTenure;
  bool isLoading = false;

  String? confirmAccountError; // Error message for confirm account number
  String? ifscError;

  @override
  void initState() {
    super.initState();
    fetchLoanTenure();
  }

  // Fetch loan tenure options and set the initial loan tenure
  fetchLoanTenure() async {
    setState(() {
      isLoading = true;
    });

    try {
      var loanTenure = await _client.getLoanTenure(widget.client.vid);
      setState(() {
        loanTenureResponse = loanTenure;
        selectedLoanTenure = '${loanTenure.loanTenures[0].value}_${loanTenure.loanTenures[0].text}'; // Default to first loan tenure value
      });

      // Fetch client details with the default loan tenure
      fetchClientDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching loan tenure: $e")),
      );
    }
  }

  // Fetch client details based on the selected loan tenure
  fetchClientDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await _client.getClientWithBank(
        loanTenureResponse!.branchId,
        widget.groupId,
        widget.client.vid,
        selectedLoanTenure!.split('_')[0],
      );

      setState(() {
        clientWithBankResponse = response;
        isLoading = false;

        // Populate text fields with fetched client data
        final client = response.client!;
        bankNameController.text = client.bankName ?? '';
        branchNameController.text = client.bankBranchName ?? '';
        ifscController.text = client.bankIfscCode ?? '';
        accountNumberController.text = client.bankAccNo ?? '';
        confirmAccountNumberController.text = client.bankAccNo ?? '';
        selectedLoanPurpose = client.loanPurpose;
        selectedProduct = client.selectedProduct;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching client details: $e")),
      );
    }
  }

   void validateConfirmAccount() {
    setState(() {
      // Compare account number and confirm account number
      if (confirmAccountNumberController.text != accountNumberController.text) {
        confirmAccountError = "Account numbers do not match!";
      } else {
        confirmAccountError = null; // Clear error if valid
      }
    });
  }

  bool validateIfscCode(String ifscCode) {
  // Check if the IFSC code is exactly 11 characters long
  if (ifscCode.length != 11) {
    ifscError = "Please fill Correct IFSC Code";
    return false;
  }

  // Check if the fifth character is '0'
  if (ifscCode[4] != '0') {
    ifscError = "5th character should be ZERO(0)";
    return false;
  }

  // Check if the last 6 characters are alphanumeric
 if (!ifscCode.substring(5).runes.every((int rune) {
        var char = String.fromCharCode(rune);
        return RegExp(r'[A-Za-z0-9]').hasMatch(char);
      })) {
    ifscError = "Invalid IFSC Code";
    return false;
  }

  return true;
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Update Account")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (loanTenureResponse == null || clientWithBankResponse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Update Account")),
        body: const Center(child: Text("No data available")),
      );
    }

    final loanPurposes = clientWithBankResponse!.loanpurpose ?? [];
    final products = clientWithBankResponse!.products ?? [];
    final client = clientWithBankResponse!.client!;
    // final loanPurposes = clientWithBankResponse!.loanpurpose ?? [];
    // final products = clientWithBankResponse!.products ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Update Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Tenure Dropdown
            const Text("Select Loan Tenure"),
            DropdownButton<String>(
              value: selectedLoanTenure,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLoanTenure = value;
                  });
                  fetchClientDetails(); // Fetch data on loan tenure change
                }
              },
              items: loanTenureResponse!.loanTenures
                  .map((loanTenure) => DropdownMenuItem<String>(
                        value: '${loanTenure.value}_${loanTenure.text}',
                        child: Text(loanTenure.text),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            Text("Client Details", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text("Client: ${client.name ?? ''}"),
            Text("Relative: ${client.relative ?? ''}"),
            Text("Eligible Amount: ${client.eligibleAmt.toString()}"),
            const SizedBox(height: 20),

            // Loan Purpose Dropdown
            const Text("Select Loan Purpose"),
            DropdownButton<String>(
              value: selectedLoanPurpose,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedLoanPurpose = value;
                });
              },
              items: loanPurposes
                  .map((purpose) => DropdownMenuItem<String>(
                        value: purpose,
                        child: Text(purpose),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Product Dropdown
            const Text("Select Product"),
            DropdownButton<double>(
              value: selectedProduct,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedProduct = value;
                });
              },
              items: products
                  .map((product) => DropdownMenuItem<double>(
                        value: product,
                        child: Text(product.toStringAsFixed(0)),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 20),
            const Text("Bank Details", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildTextField(controller: bankNameController, label: "Bank Name"),
            const SizedBox(height: 10),
            buildTextField(controller: branchNameController, label: "Branch Name"),
            const SizedBox(height: 10),
            buildTextField(controller: ifscController, label: "IFSC Code"),
            const SizedBox(height: 10),
            buildTextField(controller: accountNumberController, label: "Account Number", type: TextInputType.number),
            const SizedBox(height: 10),
            buildTextField(controller: confirmAccountNumberController, label: "Confirm Account Number", type: TextInputType.number,
             onChanged: validateConfirmAccount, // Validate on input change
              errorText: confirmAccountError, // Display validation error
            ),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: _pickImageFromCamera,
                child: Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(Icons.upload, size: 40, color: Colors.purple),
                          Text("Select Passbook", style: const TextStyle(color: Colors.purple)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // print("selected loan tenure: ${selectedLoanTenure!.split('_')[0]}");
                  validateConfirmAccount(); // Ensure validation before submission
                  if (confirmAccountError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fix errors before submitting")),
                    );
                    return ;
                  }

                  if(selectedLoanPurpose==null || selectedProduct==null || bankNameController.text.isEmpty || branchNameController.text.isEmpty || ifscController.text.isEmpty || accountNumberController.text.isEmpty || confirmAccountNumberController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All Fields Are Required!!")),
                    );
                    return ;
                  }

                  if (selectedProduct != null && clientWithBankResponse?.client?.eligibleAmt != null) {
                    // Convert eligibleAmt to an integer if it's a double
                    int eligibleAmt = clientWithBankResponse!.client!.eligibleAmt!.toInt();

                    if (selectedProduct! > eligibleAmt) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Selected Product is greater than Eligible Amount!!"),
                        ),
                      );
                      return;
                    }
                  }

                  if(_image == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Click Image To Proceed")),
                    );
                    return ;
                  }

                  if(!validateIfscCode(ifscController.text)){
                    ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(ifscError?? "IFSC ERROR"),
                        ),
                      );
                    return ;
                  }

                  submit();

                },
                child: const Text("Update Account"),
              ),
            ),
          
          const SizedBox(height: 40,),
          ],
        
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    void Function()? onChanged,
    String? errorText,
    TextInputType? type
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText, // Display error if not null
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {

       // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

      setState(() {
        _image = compressedFile; // Convert XFile to File and store it
        _imageName = pickedFile.name;
      });

    } else {
      print('No image selected.');
    }
  }

  submit() async {

    context.loaderOverlay.show();

    try {

      var client = clientWithBankResponse!.client;

        var  postClientAccountDetailsRequest = PostClientAccountDetailsRequest(
          
          clientId: client!.id,
          clientName: client.name,
          updateBy: int.parse(Global_uid),
          bankAccNo: accountNumberController.text,
          bankName: bankNameController.text,
          ifsc: ifscController.text,
          branchName: branchNameController.text,
          eligibleAmt: client.eligibleAmt!.toInt(),
          hospicashStatus: 2,
          loanPurpose: selectedLoanPurpose,
          selectedProduct: selectedProduct,
          selectedTenure: int.tryParse(selectedLoanTenure!.split('_')[0]),
          uid: client.uID
        );

        // print("postClientAccountDetailsRequest: ${postClientAccountDetailsRequest.toJson()}");

        var response = await _client.submitBankUpdate(postClientAccountDetailsRequest, _image!, _imageName);
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("$response")));
        Navigator.pop(context,true);
      
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("error submitting request $e")));
    }
    if (!mounted) return;
    context.loaderOverlay.hide();
  }

  
}
