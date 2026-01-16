import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/Non%20MFI/upload_documents.dart';
import 'package:HFSPL/apply_loan_views/questions_page.dart';
import 'package:HFSPL/network/responses/kyc/kyc_category_response.dart';
import 'package:HFSPL/network/responses/kyc/kyc_sub_category_response.dart';
import 'package:HFSPL/state/kyc_state.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/dde_request_models.dart';
import 'package:HFSPL/location/locationutil.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DDEPerformSession extends StatefulWidget {
  final int ddeScheduleId;
  final String memberName;
  final String scheduledDate;

  const DDEPerformSession({
    Key? key,
    required this.ddeScheduleId,
    required this.memberName,
    required this.scheduledDate,
  }) : super(key: key);

  @override
  State<DDEPerformSession> createState() => _DDEPerformSessionState();
}

class _DDEPerformSessionState extends State<DDEPerformSession> {
  Map<String, dynamic>? memberDetails;
  bool isLoading = true;
  bool isSubmitting = false;
  final DioClient _client = DioClient();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _reference1NameController = TextEditingController();
  final TextEditingController _reference1MobileController = TextEditingController();
  final TextEditingController _reference2NameController = TextEditingController();
  final TextEditingController _reference2MobileController = TextEditingController();
  final TextEditingController _nameInBankController = TextEditingController();
  
  // State variables
  double? currentLatitude;
  double? currentLongitude;
  String? locationAddress;
  String? selectedLoanPurpose;
  File? _passbookImage;
  File? _bankStatementImage;
  String? _bankStatementFileName;
  bool _isVerifyingIfsc = false;
  bool _isVerifyingAccount = false;
  String _ifscErrorText = "" ;
  
  // Loan purpose options
  final List<String> loanPurposes = [
    'Business',
    'Personal',
    'Medical Emergency',
    'Education',
    'Home Improvement',
    'Vehicle Purchase',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    loadMemberDetails();
    getCurrentLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _loanAmountController.dispose();
    _reference1NameController.dispose();
    _reference1MobileController.dispose();
    _reference2NameController.dispose();
    _reference2MobileController.dispose();
    _nameInBankController.dispose();
    super.dispose();
  }

  Future<void> _verifyIfsc() async {
    final ifsc = _ifscController.text.trim().toUpperCase();
    if (ifsc.length < 4) {
      showMessage(context, 'Please enter a valid IFSC code');
      return;
    }

    setState(() => _isVerifyingIfsc = true);
    try {
      final details = await _client.getBankDetailsByIfsc(ifsc);
      if (!mounted) return;
      
      setState(() {
        final bankName = details['BankName']?.toString();
        final branchName = details['BranchName']?.toString();
        if (bankName != null && branchName != null) {
          _bankNameController.text = bankName;
          _bankBranchController.text = branchName;
          _ifscErrorText = '';
        }
        else {
          _ifscErrorText = 'Bank details not found for this IFSC code. Please verify and try again.';
          _bankNameController.text = '';
          _bankBranchController.text = '';
        }
      });
      
      // showMessage(context, 'Bank details verified successfully');
    } catch (e) {
      showMessage(context, 'Bank details not found for this IFSC code. Please verify and try again.');
    } finally {
      if (mounted) setState(() => _isVerifyingIfsc = false);
    }
  }

  Future<void> _verifyAccount() async {
    final ifsc = _ifscController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    
    if (ifsc.length < 4) {
      showMessage(context, 'Please verify IFSC first');
      return;
    }
    
    if (accountNumber.length < 6) {
      showMessage(context, 'Please enter a valid account number');
      return;
    }

    setState(() => _isVerifyingAccount = true);
    try {
      final name = await _client.getAccountNameByIfscAndAccount(ifsc, accountNumber);
      if (!mounted) return;
      
      if (name != null && name.isNotEmpty) {
        setState(() {
          _nameInBankController.text = name;
        });
        showMessage(context, 'Account verified successfully');
      } else {
        showMessage(context, 'Account holder name not found. Please enter manually.');
      }
    } catch (e) {
      showMessage(context, 'Account verification failed. Please check details and try again.');
    } finally {
      if (mounted) setState(() => _isVerifyingAccount = false);
    }
  }

  Future<void> loadMemberDetails() async {
    setState(() => isLoading = true);
    try {
      final details = await _client.getDDEDetailsById(widget.ddeScheduleId);
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
      // final address = await _client.getAddess(position);
      // setState(() {
      //   locationAddress = address['display_name'];
      // });
    } catch (e) {
      showMessage(context, 'Failed to get location: $e');
    }
  }

  Future<void> _pickImage(ImageSource source, bool isPassbook) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isPassbook) {
            _passbookImage = File(pickedFile.path);
          } else {
            _bankStatementImage = File(pickedFile.path);
            _bankStatementFileName = pickedFile.name;
          }
        });
      }
    } catch (e) {
      showMessage(context, 'Failed to pick image: $e');
    }
  }

  void _showImagePicker(bool isPassbook) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isPassbook);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isPassbook);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_notesController.text.trim().isEmpty) {
      showMessage(context, 'Please add training notes');
      return false;
    }
    
    if (_bankNameController.text.trim().isEmpty) {
      showMessage(context, 'Please enter bank name');
      return false;
    }
    
    if (_bankBranchController.text.trim().isEmpty) {
      showMessage(context, 'Please enter branch name');
      return false;
    }
    
    if (_ifscController.text.trim().isEmpty) {
      showMessage(context, 'Please enter IFSC code');
      return false;
    }
    
    if (_accountNumberController.text.trim().isEmpty) {
      showMessage(context, 'Please enter account number');
      return false;
    }
    
    if (selectedLoanPurpose == null) {
      showMessage(context, 'Please select loan purpose');
      return false;
    }
    
    if (_loanAmountController.text.trim().isEmpty) {
      showMessage(context, 'Please enter loan amount');
      return false;
    }
    
    if (_passbookImage == null) {
      showMessage(context, 'Please upload bank passbook');
      return false;
    }
    
    if (_bankStatementImage == null) {
      showMessage(context, 'Please upload bank statement');
      return false;
    }
    
    if (_reference1NameController.text.trim().isEmpty) {
      showMessage(context, 'Please enter first reference name');
      return false;
    }
    
    if (_reference1MobileController.text.trim().isEmpty) {
      showMessage(context, 'Please enter first reference mobile');
      return false;
    }
    
    if (_reference2NameController.text.trim().isEmpty) {
      showMessage(context, 'Please enter second reference name');
      return false;
    }
    
    if (_reference2MobileController.text.trim().isEmpty) {
      showMessage(context, 'Please enter second reference mobile');
      return false;
    }
    
    return true;
  }

  Future<void> completeDDE() async {
    if (!_validateForm()) return;

    if (currentLatitude == null || currentLongitude == null) {
      showMessage(context, 'Location not available. Please try again.');
      return;
    }

    setState(() => isSubmitting = true);
    context.loaderOverlay.show();

    try {
      final request = PostDDERequest(
        ddeScheduleId: widget.ddeScheduleId,
        ddeDateDone: DateTime.now().toIso8601String(),
        latitude: currentLatitude,
        longitude: currentLongitude,
        clientId: memberDetails!['ClientId'],
        clientName: memberDetails!['Name'],
        notes: _notesController.text.trim(),
        bankName: _bankNameController.text.trim(),
        bankBranchName: _bankBranchController.text.trim(),
        bankIfscCode: _ifscController.text.trim(),
        bankAccNo: _accountNumberController.text.trim(),
        loanPurpose: selectedLoanPurpose,
        loanAmount: double.tryParse(_loanAmountController.text.trim()),
        // bankStatementFile: _bankStatementFileName,
        nameInBank: _nameInBankController.text.trim(),
        reference1Name: _reference1NameController.text.trim(),
        reference1Mobile: _reference1MobileController.text.trim(),
        reference2Name: _reference2NameController.text.trim(),
        reference2Mobile: _reference2MobileController.text.trim(),
      );

      // Call postDDE with file uploads
      await _client.postDDE(
        request,
        passbookFile: _passbookImage,
        // bankStatementFile: _bankStatementImage,
      );
      
      context.loaderOverlay.hide();
      setState(() => isSubmitting = false);
      
      showMessage(context, 'DDE completed successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      context.loaderOverlay.hide();
      setState(() => isSubmitting = false);
      showMessage(context, 'Failed to complete DDE: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perform DDE Session')),
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
                      _buildInfoCard(
                        'Member Information',
                        Icons.person,
                        Colors.blue,
                        [
                          _buildInfoRow('Name', memberDetails!['Name'] ?? 'N/A'),
                          _buildInfoRow('Phone', memberDetails!['Phone']?.toString() ?? 'N/A'),
                          _buildInfoRow('Address', memberDetails!['Address'] ?? 'N/A'),
                          _buildInfoRow('Eligible Amount', 
                            memberDetails!['EligibleAmount'] != null 
                              ? '₹${memberDetails!['EligibleAmount'].toStringAsFixed(0)}'
                              : 'N/A'
                          ),
                          _buildInfoRow('Scheduled Date', 
                            DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.scheduledDate))
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bank Details Card
                      _buildInfoCard(
                        'Bank Details',
                        Icons.account_balance,
                        Colors.green,
                        [
                          _buildTextFieldWithVerify('IFSC Code', _ifscController, _verifyIfsc, _isVerifyingIfsc),
                          _buildTextFieldWithVerify('Account Number', _accountNumberController, _verifyAccount, _isVerifyingAccount, TextInputType.number),
                          _buildTextField('Bank Name', _bankNameController),
                          _buildTextField('Branch Name', _bankBranchController),
                          _buildTextField('Name in Bank', _nameInBankController),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Loan Details Card
                      _buildInfoCard(
                        'Loan Details',
                        Icons.monetization_on,
                        Colors.orange,
                        [
                          _buildDropdown('Loan Purpose', selectedLoanPurpose, loanPurposes, (value) {
                            setState(() => selectedLoanPurpose = value);
                          }),
                          _buildTextField('Loan Amount', _loanAmountController, TextInputType.number),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      // Document Upload Card
                      _buildInfoCard(
                        'Document Upload',
                        Icons.upload_file,
                        Colors.purple,
                        [
                          _buildImageUpload('Bank Passbook', _passbookImage, () => _showImagePicker(true)),
                          // _buildImageUpload('Last 6 Months Bank Statement', _bankStatementImage, () => _showImagePicker(false)),
                      AppButton(onPressed: openDocPage, text: 'More Documents'),

                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // References Card
                      _buildInfoCard(
                        'References (Minimum 2 Required)',
                        Icons.people,
                        Colors.indigo,
                        [
                          const Text('Reference 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTextField('Name', _reference1NameController),
                          _buildTextField('Mobile Number', _reference1MobileController, TextInputType.phone),
                          const SizedBox(height: 16),
                          const Text('Reference 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildTextField('Name', _reference2NameController),
                          _buildTextField('Mobile Number', _reference2MobileController, TextInputType.phone),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Training Notes Card
                      _buildInfoCard(
                        'Observations Notes',
                        Icons.note,
                        Colors.teal,
                        [
                          TextField(
                            controller: _notesController,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'Enter notes and observations...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Complete Button
                      AppButton(
                        text: isSubmitting ? 'Completing...' : 'Complete DDE Session',
                        onPressed: isSubmitting ? (dynamic _) => null : (dynamic _) => completeDDE(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
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

  Widget _buildTextField(String label, TextEditingController controller, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithVerify(String label, TextEditingController controller, VoidCallback onVerify, bool isVerifying, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (value) {
                // Trigger rebuild when text changes to update button state
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorText: label == 'IFSC Code' && _ifscErrorText.isNotEmpty ? _ifscErrorText : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isButtonEnabled(label, isVerifying) ? onVerify : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: isVerifying 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
          ),
        ],
      ),
    );
  }

  bool _isButtonEnabled(String label, bool isVerifying) {
    if (isVerifying) return false;
    
    if (label == 'IFSC Code') {
      return _ifscController.text.trim().length > 4;
    } else if (label == 'Account Number') {
      return _accountNumberController.text.trim().length > 6;
    }
    
    return false;
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImageUpload(String label, File? image, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 40, color: Colors.grey),
                        Text('Tap to upload', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
  void openDocPage(dynamic _) async {
    KycState().setIndividualMode();
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => QuestionnsPage(
                                  selectedCat: KycCategory(
                                    id: 1,
                                    name: "",
                                    snapshotId: 1,
                                  ),
                                  selectedSubCat: KycSubCategory(
                                    id: 7,
                                    name: "Document Upload",
                                  ),
                                  // selectedMember: widget.selectedMember,
                                  snapshotId: memberDetails!['SnapshotId'],
                                  skipValidation: true,
                                ),
    ) );
    // Handle any result if needed
  }
}