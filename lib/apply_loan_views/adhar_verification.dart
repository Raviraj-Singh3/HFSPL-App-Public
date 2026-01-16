//add this b/w basic details and question page..
//add switch button to fill through aadhar and manual..
//or lock the fields of question page which is filled by aadhar..
//but cases is if any field is empty"" then that field should be editable..

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:HFSPL/Compress-Image/compress.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/apply_loan_views/OCR/aadhar_image_upload.dart';
import 'package:HFSPL/apply_loan_views/OCR/custom_input.dart';
import 'package:HFSPL/apply_loan_views/OCR/imageUploadTile.dart';
import 'package:HFSPL/apply_loan_views/ocr_screen.dart';
import 'package:HFSPL/apply_loan_views/questions_page.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/FaceMatch/face_match.dart';
import 'package:HFSPL/network/responses/OCR/ocr_response_model.dart';
import 'package:HFSPL/network/responses/OCR/rejection_critaria.dart';
import 'package:HFSPL/network/responses/aadhar/otpresponse_model.dart';
import 'package:HFSPL/network/responses/aadhar_model.dart';
import 'package:HFSPL/network/responses/kyc/kyc_additional_members.dart';
import 'package:HFSPL/network/responses/kyc/kyc_category_response.dart';
import 'package:HFSPL/network/responses/kyc/kyc_question_response.dart';
import 'package:HFSPL/network/responses/kyc/kyc_sub_category_response.dart';
import 'package:HFSPL/network/responses/kyc/post_kyc_model/question.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:image_to_pdf_converter/image_to_pdf_converter.dart';
import 'package:share_plus/share_plus.dart';

enum VerificationMethod {
  manual,
  aadharOtp,
  ocrScanning
}

class AadhaarVerificationPage extends StatefulWidget {
  final KycCategory selectedCat;
  final KycSubCategory selectedSubCat;
  final KycAdditionalMember? selectedMember;
  final int snapshotId;
  const AadhaarVerificationPage(
      {Key? key,
      required this.selectedCat,
      this.selectedMember,
      required this.selectedSubCat, required this.snapshotId})
      : super(key: key);

  @override
  State<AadhaarVerificationPage> createState() =>
      _AadhaarVerificationPageState();
}

class _AadhaarVerificationPageState extends State<AadhaarVerificationPage> {
  VerificationMethod _selectedMethod = VerificationMethod.manual;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    _focusNode.addListener(() {
      setState(() {
        isTextFieldFocused = _focusNode.hasFocus;
      });
    });
  }

  final DioClient _client = DioClient();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _aadhar_controller = TextEditingController();
  final TextEditingController _otp_controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextFieldFocused = false;
  String caseId = '';
  OTPResponseModel? genAdharOtpResponse;
  bool genOtp = false;
  AadharModel? varifyAdharOtpResponse;
  var _imageFile;
  bool submitOtp = false;
  List<KycQuestion> data = [];
  List<SavedQuestion> saved = [];
  bool isLoading = true;
  bool isAdharVerified = false;
  File? _memberImage;
  FaceMatchModel faceMatchResponse = FaceMatchModel();
  File? _adhar_front_image;
  File? _adhar_back_image;
  File? _adharPdf;
  OCRResponseModel? ocrResponse;
  File? _adhar_front_for_faceMatch;
  File? _image;
  String? errorMessage;

  fetchData() async {
    try {
      // print("inseide  api ");
      var d = await _client.getKycQuestions(
          widget.selectedCat.id!,
          widget.selectedSubCat.id!,
          widget.snapshotId,
          widget.selectedMember?.id);

      setState(() {
        isLoading = false;
        data = d;
        saved = d
            .map((e) =>
                SavedQuestion(questionId: e.questionId, answer: e.savedAnswer))
            .toList();
      });

      // print("after api ");

      // bool allFieldsFilled = saved.every((field) => field.answer != null);
      bool allFieldsFilled = saved
      // .where((field) => field.questionId != 152)//excluding voter name
      .every((field) => field.answer != null);

      // print("all fields filled $allFieldsFilled");

      if (allFieldsFilled) {
        // Navigate to the next page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionnsPage(
              selectedCat: widget.selectedCat,
              selectedSubCat: widget.selectedSubCat,
              selectedMember: widget.selectedMember,
              snapshotId: widget.snapshotId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error fetching questions $e")));
      setState(() {
        isLoading = false;
      });
    }
  }

  openQuestionsPage() async {
    // print("next Clicked ${varifyAdharOtpResponse?.result?.dataFromAadhaar?.name}");

    if (!isAdharVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verify Aadhar to Continue")));
      return;
    }

    //checking if member is additional member then sending adhar image
    //and removed face matching for additional member
    if (widget.selectedSubCat.id == 1 && isAdharVerified) {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionnsPage(
                  selectedCat: widget.selectedCat,
                  selectedSubCat: widget.selectedSubCat,
                  selectedMember: widget.selectedMember,
                  aadharResponse: varifyAdharOtpResponse,
                  memberImage: _imageFile,
                  aadharNumber: _aadhar_controller.text,
                  snapshotId: widget.snapshotId,
                  )));
      if (result != null) {
        // print("result... $result");
        // setState(() {
        // memberName = result;

        // });
        fetchData();
      }
    } else {
      if (faceMatchResponse.result == null ||
          faceMatchResponse.result?.match == 'no') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verify Member to Continue")));
        return;
      }

      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionnsPage(
                  selectedCat: widget.selectedCat,
                  selectedSubCat: widget.selectedSubCat,
                  selectedMember: widget.selectedMember,
                  aadharResponse: varifyAdharOtpResponse,
                  memberImage: _image,
                  aadharNumber: _aadhar_controller.text,
                  snapshotId: widget.snapshotId,
                  )));
      if (result != null) {
        // print("result... $result");
        // setState(() {
        // memberName = result;

        // });
        fetchData();
      }
    }
  }

  //have to remove face matching from additional member
  //if face matching/member imagen then store newly clicked image
  //or if it is additional member then store image from adhar
  //

  openQuestionsPageThroughOCR() async {
    if (ocrResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verify Aadhar to Continue")));
      return;
    }

    if (widget.selectedSubCat.id == 1) {
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionnsPage(
                    selectedCat: widget.selectedCat,
                    selectedSubCat: widget.selectedSubCat,
                    selectedMember: widget.selectedMember,
                    ocrResponse: ocrResponse,
                    memberImage: _memberImage,
                    // aadharNumber: _aadhar_controller.text
                    snapshotId: widget.snapshotId,
                  )));
    } else {
      if (faceMatchResponse.result == null ||
          faceMatchResponse.result?.match == 'no') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verify Member to Continue")));
        return;
      }
      var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionnsPage(
                    selectedCat: widget.selectedCat,
                    selectedSubCat: widget.selectedSubCat,
                    selectedMember: widget.selectedMember,
                    ocrResponse: ocrResponse,
                    memberImage: _memberImage,
                    snapshotId: widget.snapshotId,
                    // aadharNumber: _aadhar_controller.text
                  )));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _aadhar_controller.dispose();
    _otp_controller.dispose();
    _focusNode.dispose();
  }

  bool switchBtn = false;

  @override
  Widget build(BuildContext context) {
    // var dataList = varifyAdharOtpResponse.entries!.toList();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Aadhaar Details"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                          "Select Verification Method",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RadioListTile<VerificationMethod>(
                          title: const Text('Manual Entry'),
                          value: VerificationMethod.manual,
                          groupValue: _selectedMethod,
                          onChanged: (VerificationMethod? value) {
                            setState(() {
                              _selectedMethod = value!;
                            });
                          },
                        ),
                        // RadioListTile<VerificationMethod>(
                        //   title: const Text('Aadhar OTP'),
                        //   value: VerificationMethod.aadharOtp,
                        //   groupValue: _selectedMethod,
                        //   onChanged: (VerificationMethod? value) {
                        //     setState(() {
                        //       _selectedMethod = value!;
                        //     });
                        //   },
                        // ),
                        RadioListTile<VerificationMethod>(
                          title: const Text('OCR Scanning'),
                          value: VerificationMethod.ocrScanning,
                          groupValue: _selectedMethod,
                          onChanged: (VerificationMethod? value) {
                            setState(() {
                              _selectedMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedMethod == VerificationMethod.manual)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Proceed with manual entry"),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionnsPage(
                                  selectedCat: widget.selectedCat,
                                  selectedSubCat: widget.selectedSubCat,
                                  selectedMember: widget.selectedMember,
                                  snapshotId: widget.snapshotId,
                                  skipValidation: true,
                                ),
                              ),
                            );
                          },
                          text: "NEXT",
                        ),
                      ],
                    ),
                  ),
                if (_selectedMethod == VerificationMethod.ocrScanning)
                  ocrResponse == null ? pickImages() : ocrResult(),
                if (_selectedMethod == VerificationMethod.aadharOtp)
                  switchBtnOff(),
              ],
            ),
          ),
        ));
  }

  Column switchBtnOff() {
    return Column(
      children: [
        if (!isAdharVerified)
          Column(
            children: [
             const SizedBox(
                height: 20,
              ),
              if (!genOtp)
                CustomInputColumn(
                  labelText: "Enter Aadhaar Number",
                  controller: _aadhar_controller,
                  onPressed: genAdharOtp,
                  buttonText: "VERIFY",
                )
              else
                CustomInputColumn(
                  labelText: "Enter OTP",
                  controller: _otp_controller,
                  onPressed: submitAdharOtp,
                  buttonText: "SUBMIT",
                )
            ],
          ),
        if (isAdharVerified && widget.selectedSubCat.id != 1)
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                //   SizedBox(height: 20,),
                //  Text("Aadhar Verified"),
                 const SizedBox(
                  height: 20,
                ),

                faceMatchResponse.result == null
                    ? Column(
                        children: [
                          const SizedBox(width: 10),
                          // Back Image
                          Column(
                            children: [
                              GestureDetector(
                                onTap:() {
                                    _pickImageFromCamera((image) {
                                      _image = image;
                                    });
                                  }, // Optional: Add custom logic
                                child: Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.purple, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _image != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.upload,
                                                size: 40,
                                                color: Colors.purple),
                                            Text("Click Member",
                                                style: TextStyle(
                                                    color: Colors.purple)),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),

                          if (_image != null)
                            Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      _faceMatchClick(_image!, _imageFile!);
                                    },
                                    child: const Text('TRY FACE MATCH')),
                              ],
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                              'Match: ${faceMatchResponse.result?.match == "yes" ? 'Yes' : 'No'}'),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                              'Match Score ${faceMatchResponse.result?.matchScore?.toStringAsFixed(2)}'),
                          const SizedBox(
                            height: 5,
                          ),
                          if (faceMatchResponse.result?.match == 'no')
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _memberImage = null;
                                    faceMatchResponse = FaceMatchModel();
                                  });
                                },
                                child: const Text('TRY Again')),
                          const SizedBox(
                            height: 20,
                          ),
                          PrimaryButton(
                            onPressed: openQuestionsPage,
                            text: "NEXT",
                          ),
                        ],
                      ),
              ])),
        if (widget.selectedSubCat.id == 1 && isAdharVerified)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Aadhar Verified! Click Next."),
                const SizedBox(
                  height: 20,
                ),
                PrimaryButton(
                  onPressed: openQuestionsPage,
                  text: "NEXT",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Column ocrResult() {
    return Column(
      children: [
        OCRScreen(
          documents: ocrResponse?.result?.documents,
          // fields: null
        ),
        
        const SizedBox(
          height: 20,
        ),
        if (widget.selectedSubCat.id != 1)
          Column(
            children: [
              faceMatchResponse.result == null
                  ? Column(
                      children: [
                        Row(
                          children: [
                            // Front Image
                            Expanded(
                              child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.purple, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _adhar_front_for_faceMatch!,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 10),
                            // Back Image
                            Expanded(
                              child: GestureDetector(
                                onTap:() {
                                  _pickImageFromCamera((image) {
                                    _memberImage = image;
                                  });
                                }, // Optional: Add custom logic
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.purple, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _memberImage != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            _memberImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.upload,
                                                size: 40, color: Colors.purple),
                                            Text("Click Member",
                                                style: TextStyle(
                                                    color: Colors.purple)),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_memberImage != null)
                          Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _faceMatchClick(_memberImage!,
                                        _adhar_front_for_faceMatch!);
                                  },
                                  child: const Text('TRY FACE MATCH')),
                            ],
                          ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                            'Match: ${faceMatchResponse.result?.match == "yes" ? 'Yes' : 'No'}'),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            'Match Score ${faceMatchResponse.result?.matchScore?.toStringAsFixed(2)}'),
                        const SizedBox(
                          height: 5,
                        ),
                        if (faceMatchResponse.result?.match == 'no')
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _memberImage = null;
                                  faceMatchResponse = FaceMatchModel();
                                });
                              },
                              child: const Text('TRY Again')),
                      ],
                    ),
              const SizedBox(
                height: 20,
              ),
              PrimaryButton(
                onPressed: openQuestionsPageThroughOCR,
                text: "Continue",
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        if (widget.selectedSubCat.id == 1)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Aadhar Verified! Click Next."),
                const SizedBox(
                  height: 20,
                ),
                PrimaryButton(
                  onPressed: openQuestionsPageThroughOCR,
                  text: "NEXT",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Column pickImages() {
    return Column(children: [
      const Text(
        "Pick Images",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
      const SizedBox(height: 20),
      // Image Display Section
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Colors.purple.shade50,
        ),
        child: AadhaarImageUploadRow(
          pickFrontImage: () => _pickImageFromCameraForPdf(_updateFrontImage),
          pickBackImage: () => _pickImageFromCameraForPdf(_updateBackImage),
          adharFrontImage: _adhar_front_image,
          adharBackImage: _adhar_back_image,
        ),
      ),
      const SizedBox(height: 20),
      // OCR
      if (_adhar_front_image != null && _adhar_back_image != null)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          onPressed: getOcr,
          child: const Text("Submit"),
        ),

        const SizedBox(
        height: 20,
      ),
        if(errorMessage != null)
          Column(
            children: [
              Text("Error Message: $errorMessage",style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic),),
              SizedBox(height: 10,),
              Text("Try Again with clear Request"),
            ],
          ),

      const SizedBox(
        height: 20,
      ),
    ]);
  }

  // For sharing

  _convertPdf() async {
    try {
      // Generate PDF as a File object
      File response = await ImageToPdf.imageList(
        listOfFiles: [_adhar_front_image, _adhar_back_image],
      );

      // setState(() {
      //   _adharPdf = response;
      // });

      return response;
    } catch (e) {
      print("Error converting PDF $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error converting PDF $e")));
    }
  }

  getOcr() async {

    errorMessage = null;

    if (_adhar_front_image == null || _adhar_back_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("2 Images required")));
      return;
    }

    context.loaderOverlay.show();

    try {
      File pdf = await _convertPdf();

      var response = await _client.getOCR(pdf);

      if(response.statusCode == 102){

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cut Card uploaded ! Click Clear Images.")));
        setState(() {
          errorMessage = response.statusMessage;
        });

      }

      else if (response.statusCode == 101) {
        setState(() {
          ocrResponse = response;
          if (ocrResponse?.result?.documents?[0].subType == "FRONT_BOTTOM") {
            _adhar_front_for_faceMatch = _adhar_front_image;
          } else {
            _adhar_front_for_faceMatch = _adhar_back_image;
          }
        });
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Document Detected")));
      }
    } catch (e) {
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
    context.loaderOverlay.hide();
  }

  fetchGenAdharapi(String aadharNo) async {
    Random random = Random();
    var genCaseId = 1000 + random.nextInt(9000);
    caseId = genCaseId.toString();
    try {
      context.loaderOverlay.show();
      var response = await _client.genAdharOTP(aadharNo, caseId);
      context.loaderOverlay.hide();

      if (response.statusCode != 101) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No Results Regarding this Aadhaar")));
      } else {
        setState(() {
          genAdharOtpResponse = response;
          genOtp = true;
          // print("otp response ${genAdharOtpResponse?.result?.message}");
        });
      }
    } catch (e) {
      context.loaderOverlay.hide();
      // print("error generating otp $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("error generating otp")));
    }
  }

  genAdharOtp() async {
    String aadharText = _aadhar_controller.text.trim();

    if (aadharText.isEmpty || aadharText.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter 12 Digit Aadhar Number")));
      return;
    }

    fetchGenAdharapi(aadharText);
  }

  submitAdharOtp() async {
    String otpText = _otp_controller.text.trim();

    if (otpText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter OTP")));
      return;
    }

    context.loaderOverlay.show();

    try {
      if (genAdharOtpResponse?.requestId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Request ID is Null")));
        return;
      }

      var data = {
        "Otp": otpText,
        "RequestId": genAdharOtpResponse!.requestId,
        "ShareCode": "1234",
        "AadhaarNo": _aadhar_controller.text.trim(),
        "CaseId": caseId
      };

      var response = await _client.submitAdharOtp(data);

      if (response.statusCode != 101) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("INVALID OTP")),
        );
      } else {
        varifyAdharOtpResponse = response;
        final file = await base64ToFile(
            varifyAdharOtpResponse!.result!.dataFromAadhaar!.image!);

        setState(() {
          submitOtp = true;
          _imageFile = file;
          isAdharVerified = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("SUCCESS")));
        });
      }

      // print("otp response ...${varifyAdharOtpResponse?.result!.dataFromAadhaar!.name}");
    } catch (e) {
      // print("$e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Aadhar response error $e")));
    }
    context.loaderOverlay.hide();
  }

  Future<File> base64ToFile(String base64String) async {
    // Decode the Base64 string
    final bytes = base64Decode(base64String);

    // Get the temporary directory of the device
    final directory = await getTemporaryDirectory();

    // Create a new file in the temporary directory
    File file = File('${directory.path}/temp_image.jpg');

    // Write the bytes to the file
    await file.writeAsBytes(bytes);

    return file;
  }

Future<void> _pickImageFromCameraForPdf(Function(File?) setImage) async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    setState(() {
      setImage(compressedFile); // Use compressed file if available, else use original
    });

    // print("Selected Image: ${compressedFile}");
  } else {
    // print('No image selected.');
  }
}

void _updateFrontImage(File? image) {
  _adhar_front_image = image;
}

void _updateBackImage(File? image) {
  _adhar_back_image = image;
}

Future<void> _pickImageFromCamera(Function(File?) setImage) async {
  // Step 1: Pick an image using the camera
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await _compressImage(originalFile);

    // Step 4: Update the state with the compressed image
    setState(() {
      setImage(compressedFile ?? originalFile);
    });

    // print("Selected Image: ${compressedFile ?? originalFile}");
  } else {
    // print('No image selected.');
  }
}


  Future<File?> _compressImage(File imageFile) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress the image
      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        imageFile.path, // Input file path
        targetPath, // Output file path
        quality: 50, // Compression quality (adjust as needed)
        minWidth: 800, // Minimum width (optional)
        minHeight: 800, // Minimum height (optional)
      );

      // Convert XFile to File
      File? compressedFile =
          compressedXFile != null ? File(compressedXFile.path) : null;

      return compressedFile;
    } catch (e) {
      // print("Error during compression: $e");
      return null;
    }
  }

  _faceMatchClick(File memberImage, File adharImage) async {
    // if(memberImage==null ){
    //    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CLick Member Image")));
    //    return ;
    // }
    // print("member image ${memberImage}");

    context.loaderOverlay.show();

    try {
      var response = await _client.tryFacematch(memberImage, adharImage);
      // context.loaderOverlay.hide();

      // print("response face match $response");

      setState(() {
        faceMatchResponse = response;
      });

      if (faceMatchResponse.statusCode != 101) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Face Not Detected")));
        setState(() {
          _memberImage = null;
        });
        // return ;
      }
    } catch (e) {
      context.loaderOverlay.hide();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
      // print("face match error $e");
    }
    context.loaderOverlay.hide();
  }
}
