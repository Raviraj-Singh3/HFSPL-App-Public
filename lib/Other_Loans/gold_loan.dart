import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:HFSPL/network/responses/Offer Response/gold_loan_response.dart';

// Custom formatter for uppercase text
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class GoldLoan extends StatefulWidget {
  const GoldLoan({super.key});

  @override
  State<GoldLoan> createState() => _GoldLoanState();
}

class _GoldLoanState extends State<GoldLoan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  final DioClient _client = DioClient();

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _loanAmountController.dispose();
    _panController.dispose();
    _mobileController.dispose();
    _pincodeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateLoanAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter loan amount';
    }
    final amount = int.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid loan amount';
    }
    return null;
  }

  String? _validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter PAN number';
    }
    // PAN format: ABCDE1234F
    final panRegExp = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegExp.hasMatch(value)) {
      return 'Enter valid PAN (e.g., ABCDE1234F)';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    }
    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter PIN code';
    }
    if (value.length != 6) {
      return 'PIN code must be 6 digits';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    // Email regex pattern
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _submitForm() async{
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        GoldLoanResponse response = await _client.applyGoldLoan(
          mobileNumber: _mobileController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          pan: _panController.text,
          email: _emailController.text,
          pincode: _pincodeController.text,
          loanAmount: int.parse(_loanAmountController.text),
        );
        setState(() {
          _isSubmitting = false;
        });
        if (response.success == "true") {
          _showOffersDialog(response);
          var saveData = {
            "MobileNo": _mobileController.text,
            "Name": '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            "Email": _emailController.text,
            "LeadId": response.leadId,
            "MisUserLoginId": Global_uid,
            "PanNo": _panController.text,
            "PinCode": _pincodeController.text,
            "LoanType": "Gold",
          };
          await _client.saveLeadDetails(saveData);
        } else {
          showMessage(context, response.message ?? "Unknown error");
        }
      } catch (e) {
        showMessage(context, "Error saving lead: $e");
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showOffersDialog(GoldLoanResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text('Application Submitted'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(response.message ?? ''),
                const SizedBox(height: 16),
                if (response.offers != null && response.offers!.isNotEmpty)
                  ...response.offers!.map((offer) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (offer.lenderLogo != null)
                          Image.network(offer.lenderLogo!, width: 40, height: 40),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.lenderName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(offer.message ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.of(context).pop(); // Go back to dashboard
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    int? maxLength,
    bool capitalize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: capitalize ? TextCapitalization.characters : TextCapitalization.none,
        maxLength: maxLength,
        style: capitalize ? const TextStyle(fontFeatures: [FontFeature.enable('smcp')]) : null,
        onChanged: capitalize ? (value) {
          final cursorPos = controller.selection;
          controller.text = value.toUpperCase();
          controller.selection = cursorPos;
        } : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Loan Application'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Apply for Gold Loan',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please fill in your details below',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildInputField(
                    label: 'First Name',
                    controller: _firstNameController,
                    validator: _validateFirstName,
                    keyboardType: TextInputType.name,
                    helperText: 'Enter your first name',
                    capitalize: true,
                  ),
                  _buildInputField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    validator: _validateLastName,
                    keyboardType: TextInputType.name,
                    helperText: 'Enter your last name',
                    capitalize: true,
                  ),
                  _buildInputField(
                    label: 'PAN Number',
                    controller: _panController,
                    validator: _validatePAN,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                      UpperCaseTextFormatter(),
                    ],
                    helperText: 'Enter your 10-digit PAN number',
                    capitalize: true,
                  ),
                  _buildInputField(
                    label: 'Email Address',
                    controller: _emailController,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    helperText: 'Enter your email address',
                  ),
                  _buildInputField(
                    label: 'Mobile Number',
                    controller: _mobileController,
                    validator: _validateMobile,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    helperText: 'Enter your 10-digit mobile number',
                  ),
                  _buildInputField(
                    label: 'PIN Code',
                    controller: _pincodeController,
                    validator: _validatePincode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    helperText: 'Enter your 6-digit PIN code',
                  ),
                  _buildInputField(
                    label: 'Loan Amount',
                    controller: _loanAmountController,
                    validator: _validateLoanAmount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    helperText: 'Enter the loan amount',
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Application',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Footer Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your information is secure and will only be used for loan processing',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}