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

class HousingLoanPage extends StatefulWidget {
  const HousingLoanPage({super.key});

  @override
  State<HousingLoanPage> createState() => _HousingLoanPageState();
}

class _HousingLoanPageState extends State<HousingLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _housingLoanAmountController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  String _selectedPropertyType = 'House';
  bool _isSubmitting = false;
  final DioClient _client = DioClient();

  final List<String> _propertyTypes = [
    'House',
    'Apartment',
    'Villa',
    'Plot',
    'Commercial Property',
    'Under Construction',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _panController.dispose();
    _mobileController.dispose();
    _pincodeController.dispose();
    _emailController.dispose();
    _monthlyIncomeController.dispose();
    _housingLoanAmountController.dispose();
    _dobController.dispose();
    super.dispose();
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

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    return null;
  }

  String? _validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your monthly income';
    }
    final amount = int.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid monthly income';
    }
    return null;
  }

  String? _validateHousingLoanAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter housing loan amount';
    }
    final amount = int.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid housing loan amount';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        HousingLoanResponse response = await _client.applyHousingLoan(
          mobileNumber: _mobileController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          pan: _panController.text,
          dob: _dobController.text,
          email: _emailController.text,
          pincode: _pincodeController.text,
          monthlyIncome: int.parse(_monthlyIncomeController.text),
          housingLoanAmount: int.parse(_housingLoanAmountController.text),
          propertyType: _selectedPropertyType,
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
            "LoanType": "Housing",
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

  void _sendOfferEmail(HousingLoanOffer offer) async {
    var data = {
      "CustomerEmail": _emailController.text,
      "CustomerName": '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      "Offers": [
        {
          "LenderName": offer.lenderName,
          "OfferLink": offer.offerLink,
        }
      ]
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _client.sendOfferEmail(data);
      Navigator.of(context).pop(); // Remove loading
      showMessage(context, "Offer link sent to your email successfully");
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading
      showMessage(context, "Failed to send offer link: $e");
    }
  }

  void _showOffersDialog(HousingLoanResponse response) {
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
                              if (offer.offerLink != null)
                                TextButton.icon(
                                  icon: const Icon(Icons.email_outlined),
                                  label: const Text('Send Offer to Email'),
                                  onPressed: () => _sendOfferEmail(offer),
                                ),
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
    VoidCallback? onTap,
    bool readOnly = false,
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
        readOnly: readOnly,
        onTap: onTap,
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Housing Loan Application'),
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
                          Icons.house,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Apply for Housing Loan',
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

                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                    label: 'Date of Birth',
                    controller: _dobController,
                    validator: _validateDOB,
                    readOnly: true,
                    onTap: _selectDate,
                    helperText: 'Tap to select your date of birth',
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

                  const SizedBox(height: 24),

                  // Financial Information Section
                  Text(
                    'Financial Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Monthly Income',
                    controller: _monthlyIncomeController,
                    validator: _validateMonthlyIncome,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    helperText: 'Enter your monthly income in rupees',
                  ),
                  _buildInputField(
                    label: 'Housing Loan Amount',
                    controller: _housingLoanAmountController,
                    validator: _validateHousingLoanAmount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    helperText: 'Enter the housing loan amount you need',
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Property Type',
                    value: _selectedPropertyType,
                    items: _propertyTypes,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPropertyType = newValue!;
                      });
                    },
                    helperText: 'Select the type of property',
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