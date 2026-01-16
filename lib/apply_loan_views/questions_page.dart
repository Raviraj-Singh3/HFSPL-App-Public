import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Functions/image_picker.dart';
import 'package:HFSPL/utils/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/responses/FaceMatch/face_match.dart';
import 'package:HFSPL/network/responses/OCR/ocr_response_model.dart';
import 'package:HFSPL/network/responses/aadhar_model.dart';
import 'package:HFSPL/network/responses/kyc/kyc_question_response.dart';

import '../custom_views/app_button.dart';
import '../custom_views/app_button_secondary.dart';
import '../custom_views/app_input_alert_dialog.dart';
import '../network/networkcalls.dart';
import '../network/responses/kyc/kyc_additional_members.dart';
import '../network/responses/kyc/kyc_category_response.dart';
import '../network/responses/kyc/kyc_sub_category_response.dart';
import '../network/responses/kyc/post_kyc_model/question.dart';
import 'filled_answer.dart';
import 'kyc_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/widgets.dart';


class QuestionnsPage extends StatefulWidget {
  final KycCategory selectedCat;
  final KycSubCategory selectedSubCat;
  final KycAdditionalMember? selectedMember;
  final AadharModel? aadharResponse;
  final File? memberImage;
  final String? aadharNumber;
  final OCRResponseModel? ocrResponse;
  final int snapshotId;
  final bool skipValidation;

  const QuestionnsPage(
      {Key? key,
      required this.selectedCat,
      this.selectedMember,
      required this.selectedSubCat,
      this.aadharResponse,
      this.memberImage,
      this.aadharNumber,
      this.ocrResponse,
      required this.snapshotId,
      this.skipValidation = false
      })
      : super(key: key);

  @override
  QuestionnsPageState createState() => QuestionnsPageState();
}

class QuestionnsPageState extends State<QuestionnsPage> {
  List<KycQuestion> data = [];
  List<SavedQuestion> saved = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  int blinkIndex = -1;
  bool isSubmitting = false;

   String caseId = '';
   bool genOtp = false;
   bool submitOtp = false;
   AadharModel? varifyAdharOtpResponse;
   OCRResponseModel? ocrResponse;

   final ImagePicker _picker = ImagePicker();
  // Dynamic field detection based on question names instead of hardcoded IDs
  List<String> aadharFieldNames = [
    'NAME AS PER AADHAR',
    'FAMILY MEMBER NAME', 
    'FULL ADDRESS',
    'ADDRESS',
    'DATE OF BIRTH',
    'DOB',
    'MEMBER PHOTO',
    'KYC NUMBER',
    'GENDER',
    'CITY',
    'FATHER NAME',
    'MOTHER NAME',
    'DISTRICT',
    'STATE',
    'PIN CODE',
    'KYC TYPE',
    'ADDITIONAL KYC TYPE'
  ];

  @override
  void initState() {
    super.initState();
    ocrResponse = widget.ocrResponse;
    varifyAdharOtpResponse = widget.aadharResponse;
    fetchData();
  }

  String? formatDate(String? inputDate) {
  // Check if the input date is null or empty
  if (inputDate == null || inputDate.trim().isEmpty) {
    return null;
  }

  try {
    // Define the input and output date formats
    DateFormat inputFormat = DateFormat("dd/MM/yyyy");
    DateFormat outputFormat = DateFormat("yyyy-MM-dd");

    // Parse the input date string to a DateTime object
    DateTime dateTime = inputFormat.parse(inputDate);

    // Format the DateTime object to the desired output string
    return outputFormat.format(dateTime);
  } catch (e) {
    // Return null if parsing fails
    return null;
  }
}

  void fetchData() async {
    try {
      var d = await _client.getKycQuestions(
          widget.selectedCat.id!,
          widget.selectedSubCat.id!,
          widget.snapshotId,
          widget.selectedMember?.id);

      setState(() {
        data = d;
        saved = d
            .map((e) =>
                SavedQuestion(questionId: e.questionId, answer: e.savedAnswer))
            .toList();
      }
      );

    if(ocrResponse != null){

        Document? document1;
        Document? document2;

        if(ocrResponse?.result?.documents?[0].subType == "FRONT_BOTTOM"){
          document1 = ocrResponse?.result?.documents?[0];
          document2 = ocrResponse?.result?.documents?[1];
        }else {
          document2 = ocrResponse?.result?.documents?[0];
          document1 = ocrResponse?.result?.documents?[1];
        }

        for(int i = 0; i < saved.length; i++){
          String questionName = data[i].questionName?.toUpperCase() ?? '';
          
          // Name fields
          if(questionName.contains('NAME AS PER AADHAR') || questionName.contains('FAMILY MEMBER NAME')){
            saved[i].answer = document1?.ocrData?.fields?["name"]?.value;// member name
          }
          // Address fields
          if(questionName.contains('FULL ADDRESS') || questionName.contains('ADDRESS')){
            saved[i].answer = document2?.ocrData?.fields?["address"]?.value;// full address
          }
          // Date of Birth fields
          if(questionName.contains('DATE OF BIRTH') || questionName.contains('DOB')){
            String? formattedDate = formatDate(document1?.ocrData?.fields?["dob"]?.value);
            saved[i].answer = formattedDate;// date of birth
          }
          // Member Photo
          if(questionName.contains('MEMBER PHOTO')){
              _mediaFileList[saved[i].questionId!] = widget.memberImage!;
              saved[i].answer = 'done';
          }
          // KYC Number fields  
          if(questionName.contains('KYC NUMBER')){
            saved[i].answer = document1?.ocrData?.fields?["aadhaar"]?.value;//kyc number
          }
          // Gender fields
          if(questionName.contains('GENDER')){
            saved[i].answer = document1?.ocrData?.fields?["gender"]?.value;
          }
          // Father Name fields
          if(questionName.contains('FATHER NAME')){
            if(document2?.additionalDetails?.careOfDetails?.relation == "FATHER"){
              saved[i].answer = document2?.additionalDetails?.careOfDetails?.name;
            }
          }
          // City/District fields
          if(questionName.contains('CITY') || questionName.contains('DISTRICT')){
            saved[i].answer = document2?.additionalDetails?.addressSplit?.district;
          }
          // State fields
          if(questionName.contains('STATE')){
            saved[i].answer = document2?.additionalDetails?.addressSplit?.state;
          }
          // PIN Code fields
          if(questionName.contains('PIN CODE')){
            saved[i].answer = document2?.additionalDetails?.addressSplit?.pin;
          }
          // KYC Type fields
          if(questionName.contains('KYC TYPE')){
            saved[i].answer = 'ADHAR';//kyc type
          }
        }
      }

    if (varifyAdharOtpResponse != null){

        var aadharData =  varifyAdharOtpResponse?.result!.dataFromAadhaar;
        var address =  varifyAdharOtpResponse?.result!.dataFromAadhaar!.address;

          for(int i = 0; i < saved.length; i++){
          String questionName = data[i].questionName?.toUpperCase() ?? '';

          // Name fields
          if(questionName.contains('NAME AS PER AADHAR') || questionName.contains('FAMILY MEMBER NAME')){
            saved[i].answer = aadharData!.name;// member name
          }
          // Address fields
          if(questionName.contains('FULL ADDRESS') || questionName.contains('ADDRESS')){
            saved[i].answer = address!.combinedAddress;// full address
          }
          // Date of Birth fields
          if(questionName.contains('DATE OF BIRTH') || questionName.contains('DOB')){
            saved[i].answer = aadharData!.dob;// date of birth
          }
          // Member Photo
          if(questionName.contains('MEMBER PHOTO')){
              _mediaFileList[saved[i].questionId!] = widget.memberImage!;
              saved[i].answer = 'done';
          }
          // KYC Number fields
          if(questionName.contains('KYC NUMBER')){
            saved[i].answer = widget.aadharNumber;//kyc number
          }
          // Gender fields
          if(questionName.contains('GENDER')){
            if(aadharData!.gender == 'M'){
              saved[i].answer = 'Male';
            }else {
              saved[i].answer = 'Female';
            }
          }
          // Father Name fields
          if(questionName.contains('FATHER NAME')){
            saved[i].answer = aadharData!.fatherName;
          }
          // City/District fields
          if(questionName.contains('CITY') || questionName.contains('DISTRICT')){
            saved[i].answer = address!.splitAddress!.district;
          }
          // State fields
          if(questionName.contains('STATE')){
            saved[i].answer = address!.splitAddress!.state;
          }
          // PIN Code fields
          if(questionName.contains('PIN CODE')){
            saved[i].answer = address!.splitAddress!.pincode;
          }
          // KYC Type fields
          if(questionName.contains('KYC TYPE')){
            saved[i].answer = 'ADHAR';//kyc type
          }

          // test--
          // if(saved[i].questionId == 3 || saved[i].questionId == 22){
          //   saved[i].answer = 'ADHAR';//kyc type
          //   formController.markFieldAsPreSubmitted(saved[i].answer.toString());
          // }
        } 
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _onFillClick(index) {
    KycQuestion question = data[index as int];
    String type = question.questionType!;

   // Dynamic check based on question name instead of hardcoded IDs
  if (!widget.skipValidation && _isAadharField(question.questionName)) {
    // If the field has data and it's an aadhar field, disable editing
    if (saved[index].answer != null && saved[index].answer != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disabled Field - Auto-filled from Aadhar'),
        ),
      );
      return;
    }
  }
    if (type == KycConstants.questionTypeText) {
      takeTextAndNumberInput(index, TextInputType.text, question);
    } else if (type == KycConstants.questionTypeNumber) {
      takeTextAndNumberInput(index, TextInputType.number, question);
    } else if (type == KycConstants.questionTypeDate) {
      _selectDate(context, index);
    } else if (type == KycConstants.questionTypePhoto) {
      _onImageButtonPressed(index);
    } else if (type == KycConstants.questionTypeSelect) {
      _showOptionDialog(context, index);
    }
    else if (type == KycConstants.questionTypePDF) {
      _onPdfButtonPressed(index);
    }
  }

  takeTextAndNumberInput(
      int index, TextInputType keyboardType, KycQuestion question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppInputAlertDialog(
          title: question.questionName!,
          description: '',
          hintText: '',
          defaultValue: saved[index].answer,
          labelText: question.questionName!,
          keyboardType: keyboardType,
          confirmCallback: (inputValue) {
            //print('Confirmed with input: $inputValue');

            if (inputValue.trim().isEmpty && question.required == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text('Please enter ${question.questionName!}'),
                ),
              );
            } else if (inputValue.trim().isNotEmpty) {
              setState(() {
                saved[index].answer = inputValue.trim();
              });
              Navigator.of(context).pop();
            }
          },
          cancelCallback: () {
            // Handle your cancel action
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: getDateTime(saved[index].answer),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (picked != null && picked != getDateTime(data[index].savedAnswer)) {
      setState(() {
        saved[index].answer = toDateTimeString(picked);
      });
    }
  }

  DateTime? getDateTime(String? date) {
    if (date == null) {
      return null;
    }
    return DateFormat('dd-MMM-yyyy').parse(date);
  }

  String? toDateTimeString(DateTime? date) {
    if (date == null) {
      return null;
    }
    DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
    return dateFormat.format(date);
  }

  Future<void> _showOptionDialog(BuildContext context, int mainIndex) async {
    var question = data[mainIndex];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select ${question.questionName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: question.options!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(question.options![index]),
                  onTap: () {
                    setState(() {
                      saved[mainIndex].answer =
                          question.options![index] as String;
                    });
                    Navigator.of(context).pop();
                  },
                  tileColor: saved[mainIndex].answer == question.options![index]
                      ? Colors.blue
                      : null,
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _onPdfButtonPressed(int index) async {
    {
      try {
         String? pdfPath = await pickPDF();
         if (pdfPath != null) {
           File pdfFile = File(pdfPath);
           setState(() {
             _mediaFileList[saved[index].questionId!] = pdfFile;
             saved[index].answer = 'done';
           });
         }
      } catch (e) {
        showMessage(context, 'pdf error $e');
      }
    }
  }

  final Map<int, File> _mediaFileList = {};

  Future<void> _onImageButtonPressed(int index) async {
    {
      try {
         File? image = await pickImageFromCamera();
        setState(() {
            _mediaFileList[saved[index].questionId!] = image;
            saved[index].answer = 'done';
        });
      } catch (e) {
        showMessage(context, 'image error $e');
      }
    }
  }

  _saveClick(value) async {
    for (var i = 0; i < data.length; i++) {
      var question = data[i];

      String normalizedQuestionName = question.questionName?.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase() ?? '';
      if (normalizedQuestionName == 'KYC NUMBER' || normalizedQuestionName == 'AADHAR NUMBER') {
        String answer = saved[i].answer.toString();
        // Check: must be exactly 12 digits and only digits
        if (!RegExp(r'^\d{12}$').hasMatch(answer)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text('${question.questionName!} is invalid'),
            ),
          );
          // print("question name ${question.questionName}");
          _startBlinking(question.questionId!);
          return;
        }
      }

      if (question.required == true && saved[i].answer == null || saved[i].answer == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text('${question.questionName!} is required'),
          ),
        );
        _startBlinking(question.questionId!);
        return;
      }
    }
    try {
      setState(() {
        isSubmitting = true;
      });

      var resp = await _client.postKyc(
          widget.selectedCat.id!,
          widget.selectedSubCat.id!,
          widget.snapshotId,
          widget.selectedMember?.id,
          saved,
          _mediaFileList);
      // success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(resp),
        ),
      );
      Navigator.pop(context, true);
      // if(widget.selectedSubCat.id == 4 || widget.selectedSubCat.id == 1){
      //   Navigator.pop(context, true);
      //   Navigator.pop(context, true);
      // }else {
      //   Navigator.pop(context, true);
      // }

      // Navigato
    } catch (e) {
      //e.toString()
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Helper method to check if a question is an Aadhar field based on its name
  bool _isAadharField(String? questionName) {
    if (questionName == null) return false;
    
    String normalizedQuestionName = questionName.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
    
    return aadharFieldNames.any((fieldName) => 
        normalizedQuestionName.contains(fieldName.toUpperCase()));
  }

  void _startBlinking(int questionId) async {
    int indexOf =
        saved.indexWhere((element) => element.questionId == questionId);
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        blinkIndex = blinkIndex == -1 ? indexOf : -1;
      });
    }
  }


@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
          appBar: AppBar(title: Text(widget.selectedSubCat.name!)),
          body: Container(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if(widget.memberImage != null)
                          Column(
                            children: [
                             const  SizedBox(height: 10,),
                              Image.file(
                                widget.memberImage!, // Display the selected image
                                width: 150,
                                height: 150,
                              ),
                             const SizedBox(height: 10,),
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: blinkIndex == index
                                            ? const Color(0xFF00796B)
                                            : null,
                                        border: const Border(
                                            bottom:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                data[index].questionName!,
                                                style: const TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold),
                                              )),
                                              saved[index].answer == null
                                                  ? AppButtonSecondary(
                                                      textColor:
                                                          data[index].required == true
                                                              ? Colors.red
                                                              : Colors.blue,
                                                      onPressed: _onFillClick,
                                                      text: 'Fill',
                                                      valueToPassBack: index,
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        _onFillClick(index);
                                                      },
                                                      child: FilledAnswer(
                                                          type: data[index]
                                                              .questionType!,
                                                          filledAnswer:
                                                              saved[index].answer),
                                                    )
                                            ],
                                          ),
                                          if(data[index].questionName == 'ADDITIONAL KYC NUMBER' && saved[index-1].answer == 'VOTER CARD')
                                          Column(
                                            children: [
                                              if(saved[index].answer != null && saved[index+1].answer == null)
                                              ElevatedButton(onPressed: (){
                                                verifyVoterCard(saved[index], saved[index+1]);
                                              }, child: const Text("Verify")),
                                            ],
                                          ),

                                       
                                        ],  
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        PrimaryButton(
                            isLoading: isSubmitting,
                            onPressed: (){_saveClick(context);},
                            text: 'Save',
                            // isLoading: isSubmitting
                            ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
          ));
  }
  verifyVoterCard(SavedQuestion savedQuestion, SavedQuestion voterCardIndex)async {
    context.loaderOverlay.show();
    try {
      var response = await _client.verifyVoterCard(savedQuestion.answer!);
      setState(() {
        if(response.result?.name == null){
          showMessage(context, "No data found");
          return;
        }
        voterCardIndex.answer = response.result?.name;
      });
    } catch (e) {
      showMessage(context, "$e");
    }
    context.loaderOverlay.hide();
  }
}
