
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/radio_with_text_heading.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/custom_views/location.dart';
import 'package:HFSPL/grt_pages/grt_house_images.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_pregrt_model.dart';
import 'package:HFSPL/network/responses/grt/grt_by_id_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:HFSPL/network/responses/BanckAccModel/bank_acc_model.dart';
import 'package:path/path.dart' as path;

class GRTPage extends StatefulWidget {
  final GRTById cgtGroup;
  const GRTPage({super.key, required this.cgtGroup});

  @override
  State<GRTPage> createState() => _GRTPageState();
}

class _GRTPageState extends State<GRTPage> {
  final DioClient _client = DioClient();
  List<GRTById> grtByIdResponseList = [];
  List<int> id = [];
  Map<String, bool> isMemberDropped = {};
  Map<String, bool> isMemberPresent = {};
  Map<String, bool> isMemberPass = {};
  Map<String, bool> isBankCheck = {};
  Map<String, bool> isDocOpdAvailed = {};
  final List<TextEditingController> _controllers = [];
  Map <String, bool>_isImageUplaodSuccess = {};

  bool isHouseClicked = false;

   Map<String,String> _imageFromAPi = {};

   Map<String,bool> _houseImageNotUploaded = {};

   BankAccModel bankAccResponse = BankAccModel();

   Map<String,String> _banklAccountName = {};

   List loanPurposes = [];
   String? selectedLoanPurpose;

  // getLoanPusepose() async {
  //   try {
  //     var response = await _client.loanPurposes();
  //     setState(() {
  //       loanPurposes = response;
  //     });
  //   } catch (e) {
  //     showMessage(context, "Error getting loan purposes: $e");
  //   }
  // }

  fetch() async {
    try {
      var response = await _client.getGRTById(id);
      // print("response ${response[0].nameInBank}");
      setState(() {
        grtByIdResponseList = response; //
        
       // Initialize isMemberPresent with default values (false for "Absent")
      for (var member in grtByIdResponseList) {
        isMemberPresent[member.memberCgtId.toString()] = false;
        isBankCheck[member.memberCgtId.toString()] = false;
        isMemberPass[member.memberCgtId.toString()] = false; // Default to "Absent"

        _imageFromAPi[member.memberCgtId.toString()] = "${_client.baseurl}/api/Images/GetGrtPhoto?tag=${member.memberCgtId.toString()}_member";
      }
      });
    } catch (e) {
      showMessage(context, "Error fetching data: $e");
    }
  }

  bool getIsMemberPresent(String memberCgtId){
    if (!isMemberPresent.containsKey(memberCgtId)) {
      return false;
    }
    return (isMemberPresent[memberCgtId] ?? false);
  }

  bool getisMemberPass(String memberCgtId){
    if (!isMemberPass.containsKey(memberCgtId)) {
      return false;
    }
    return (isMemberPass[memberCgtId] ?? false);
  }

  bool getIsBankCheck(String memberCgtId){
    if (!isBankCheck.containsKey(memberCgtId)) {
      return false;
    }
    return (isBankCheck[memberCgtId] ?? false);
  }

  bool getIsMemberDropped(String cgtId){
    if (!isMemberDropped.containsKey(cgtId)) {
      return false;
    }
    return isMemberDropped[cgtId] ?? false;
  }

  bool getIsDocOpdAvailed(String cgtId){
    if (!isDocOpdAvailed.containsKey(cgtId)) {
      return true;
    }
    return isDocOpdAvailed[cgtId] ?? false;
  }

  Map<String,File?> _image = {}; // Store the captured image
  Map<String,String?> _imageName = {};//namwe
  final ImagePicker _picker = ImagePicker(); // Instantiate the image picker

  // Method to capture image from the camera
  Future<void> _pickImageFromCamera(String memberCGTId) async {
    
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {

      // Step 3: Compress the image
       XFile? compressedFile = await _compressImage(pickedFile);

      setState(() {
        _image[memberCGTId] = File(compressedFile!.path); // Convert XFile to File and store it
        _imageName[memberCGTId] = pickedFile.name;
      });

    } else {
      print('No image selected.');
    }
  }

  _saveImage(memberCGTId) async {

     context.loaderOverlay.show();

     try {

       Position position = await getCurrentLocation();
       
        var response  = await _client.postGRTImages(memberCGTId,"member",position.latitude.toString(),position.longitude.toString(),_image[memberCGTId]!,_imageName[memberCGTId]!);
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Uplaod Success')),
       );
       setState(() {
         _isImageUplaodSuccess[memberCGTId] = true;
       });
     } catch (e) {
        print(e);
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${e}')),
        );
          // _image[memberCGTId] = null;

     }
     context.loaderOverlay.hide();
  }


  Future<XFile?> _compressImage(XFile imageFile) async {
  try {
    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Compress the image
    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,     // Input file path
      targetPath,         // Output file path
      quality: 50,        // Compression quality (adjust as needed)
      minWidth: 800,      // Minimum width (optional)
      minHeight: 800,     // Minimum height (optional)
    );

    // Convert XFile to File
    // XFile? compressedFile = compressedXFile != null ? File(compressedXFile.path) : null;

    return compressedXFile;
  } catch (e) {
    print("Error during compression: $e");
    return null;
  }
}


  onSubmitClick()async {

    context.loaderOverlay.show();
    
    List<RequestPostPreGRT> items = [];

    List<PreGRTMember> listMembers = [];

    for (int i = 0; i < grtByIdResponseList.length; i++) {
    var m = grtByIdResponseList[i];
    String? sanctionAmount = _controllers[i].text;

    listMembers.add(PreGRTMember(
        memberCGTId: m.memberCgtId.toString(),
        isDropped: getIsMemberDropped(m.memberCgtId.toString()),
        isPresent: getIsMemberPresent(m.memberCgtId.toString()),
        isPassed: getisMemberPass(m.memberCgtId.toString()),
        bankAcCheck: getIsBankCheck(m.memberCgtId.toString()),
        isDocOpdAvailed: getIsDocOpdAvailed(m.memberCgtId.toString()),
        sanctionAmount: sanctionAmount == ""? "0" : sanctionAmount,
      )
      );
    }

    
  try {
      
      Position position = await getCurrentLocation();

      var groupModel = RequestPostPreGRT(
      cGTId: [widget.cgtGroup.groupCgtId.toString()],
      userId: Global_uid,
      gRTMembers: listMembers,
      lat: position.latitude,
      lng: position.longitude,
    );

    items.add(groupModel);
    // Convert your list of items to JSON
  // String jsonString = jsonEncode(items.map((item) => item.toJson()).toList());

  Map<String, dynamic> requestPayload = groupModel.toJson(); // Assuming you have a toJson() method in your model class

     FormData formData = FormData();
     // Add extra data to FormData
      formData.fields.add(MapEntry('data', jsonEncode(requestPayload)));

        var response = await _client.postGRT(formData);
       

          if (response.statusCode == 200) {
          // Handle success
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' GRT Completed Successfully!')),
          );
          // context.loaderOverlay.hide();
          // Navigator.pop(context);
          
        } else {
          // Handle API error
          if (!mounted) return;
          // context.loaderOverlay.hide();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed!')),
          );
          
        }
        context.loaderOverlay.hide();
     }
     catch (e){
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${e}')),
        );
     }
     context.loaderOverlay.hide();
  } 

  @override
  void initState() {
    // TODO: implement initState
    id.add(widget.cgtGroup.groupCgtId!);
    // print("grt page ${widget.cgtGroup.groupCgtId}");
    super.initState();
    fetch();
    // getLoanPusepose();
  //    Future.delayed(Durations.extralong4, () {
  //   for (var response in grtByIdResponseList) {
  //     getBanckAccDetails(response.bankAcNo??"", response.bankIFSC??"",  response.memberCgtId.toString());
  //   }
  // });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    for (TextEditingController c in _controllers) {       c.dispose();     }
    super.dispose();
  }

  void openHouseImages() async {

    // add validation to check all images is selected
      if((_houseImageNotUploaded.length  - _isImageUplaodSuccess.length) != 0){

           ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Upload All Member Images')),
       );
        return ;
      }

      else {
        var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GrtHouseImages(membersList: grtByIdResponseList)));
        if (result == true) {
          // submit GRT json
          await onSubmitClick();
          
            Navigator.pop(context, true);
    }
      }
    

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GRT"),),
      body: Column(
          children: [
            Expanded(
              child: grtByIdResponseList.isEmpty
                ? const Center(
                          child: CircularProgressIndicator(
                          ),
                        )
                : ListView.separated(
                  itemCount: grtByIdResponseList.length,
                  padding: EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                     String memberCGTId = grtByIdResponseList[index].memberCgtId.toString();
                    _controllers.add(TextEditingController());
                    return Card(
                      // color: Colors.green,
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        // margin: EdgeInsets.only(bottom: 50),
                        child: Column(
                          children: [
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // spacing: 10.0,
                              // runSpacing: 5.0,
                              children: [
                                Text(grtByIdResponseList[index].memberName!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
                                SizedBox(height: 20,),
                                _image[memberCGTId] == null
                                ? Image.network(
                                  _imageFromAPi[memberCGTId]!, // Display the selected image
                                  width: 100,
                                  height: 100,
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                      },
                                  errorBuilder:
                                        (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          _houseImageNotUploaded[memberCGTId] = true;
                                      return  ElevatedButton(
                                        onPressed: (){
                                          _pickImageFromCamera(memberCGTId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjust padding if needed
                                        ),
                                        child: Icon(Icons.camera_alt), // Label below the icon
                                      );
                                    }
                                
                                ) 
                                  : Column(
                                    children: [
                                      Image.file(
                                          _image[memberCGTId]!, // Display the selected image
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        
                                        if(_isImageUplaodSuccess[memberCGTId] != true)
                                        Column(
                                          children: [
                                            const SizedBox(height: 20,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                              SizedBox(height: 50, child: FilledButton(onPressed: (){
                                                _saveImage(memberCGTId);
                                              }, child: const Text("Upload"))),
                                              SizedBox(width: 20,),
                                              SizedBox(height: 50,child: ElevatedButton(onPressed: (){
                                                 _image[memberCGTId] = null;
                                                 setState(() {
                                                   
                                                 });
                                              }, child: const Text("Cancel")))
                                            ],),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),

                              RowWithData(
                                title: 'Group Name :',
                                data: grtByIdResponseList[index].groupName,
                                ),
                            
                            RowWithData(
                                title: 'Spouse Name :',
                                data: grtByIdResponseList[index].spouseName,
                                ),
                            RowWithData(
                                title: 'Nominee Name :',
                                data: grtByIdResponseList[index].nomineeName,
                                ),
                            RowWithData(
                                title: 'Mobile :',
                                data: grtByIdResponseList[index].phoneNumber.toString(),
                                ),
                            RowWithData(
                                title: 'Eligible Amount :',
                                data: grtByIdResponseList[index].eligibleAmount.toString(),
                                ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     const Text(
                            //       "Loan Purpose:",
                            //       style: TextStyle(fontSize: 16),
                            //     ),
                            //     const Spacer(), // Pushes the dropdown to the right
                            //     Expanded(
                            //       child: Align(
                            //         alignment: Alignment.centerRight,
                            //         child: DropdownButton<String>(
                            //           value: grtByIdResponseList[index].loanPurpose,
                            //           isExpanded: true,
                            //           onChanged: (value) {
                            //             updateLoanPurpose(value!, grtByIdResponseList[index].memberId!);
                            //           },
                            //           items: loanPurposes
                            //               .map(
                            //                 (purpose) => DropdownMenuItem<String>(
                            //                   value: purpose,
                            //                   child: Text(
                            //                     purpose,
                            //                     overflow: TextOverflow.ellipsis, // Prevent overflow issues
                            //                   ),
                            //                 ),
                            //               )
                            //               .toList(),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const Text("Name in Bank :", style: TextStyle(fontSize: 16),),
                            Text(grtByIdResponseList[index].nameInBank ?? "N/A",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green.shade600
                              ),
                            ),
                            // Text('${grtByIdResponseList[index]}'+ '1'),
                            
                            RadioWithTextHeading(
                              heading: 'Bank Details', 
                              radioTitle1: 'Correct',
                               radioTitle2: 'Incorrect', 
                               groupValue: isBankCheck[grtByIdResponseList[index].memberCgtId.toString()], 
                               onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isBankCheck[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                                row1Title: 'Account Number :',
                                row1Data: grtByIdResponseList[index].bankAcNo,
                                row2Title: 'IFSC :',
                                row2Data: grtByIdResponseList[index].bankIFSC,
                               ),
                            
                            RadioWithTextHeading(
                              heading: "Attendance",
                              radioTitle1: 'Present',
                              radioTitle2: 'Absent',
                              groupValue: isMemberPresent[grtByIdResponseList[index].memberCgtId.toString()],
                              onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isMemberPresent[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                              ),
                            
                            RadioWithTextHeading(
                              heading: "Member GRT",
                              radioTitle1: 'Pass',
                              radioTitle2: 'Fail',
                              groupValue: isMemberPass[grtByIdResponseList[index].memberCgtId.toString()],
                              onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isMemberPass[grtByIdResponseList[index].memberCgtId.toString()] = newValue!;
                                  });
                                },
                              ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                              value: isMemberDropped[
                                                      grtByIdResponseList[index].memberCgtId.toString()] ??
                                                  false,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  isMemberDropped[grtByIdResponseList[index]
                                                      .memberCgtId.toString()] = value!;
                                                    // check = value!;
                                                });
                                              },
                                      ),
                                      const Text("Drop Member", style: TextStyle(fontSize: 16),),
                                    ],
                                  ),
                                  
                                  
                                  Row(
                                    children: [
                                      Checkbox(
                                              value: isDocOpdAvailed[
                                                      grtByIdResponseList[index].memberCgtId.toString()] ??
                                                  true,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  isDocOpdAvailed[grtByIdResponseList[index]
                                                      .memberCgtId.toString()] = value!;
                                                    // check = value!;
                                                });
                                              },
                                      ),
                                       const Text("Avail Doc OPD", style: TextStyle(fontSize: 16),),
                                    ],
                                  ),
                                 
                                ],
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: _controllers[index],
                                onChanged: (value) {
                                  try {
                                      // Parse input and eligible amount
                                      int inputValue = int.parse(value);
                                      int eligibleAmount = grtByIdResponseList[index].eligibleAmount?.toInt() ?? 0;

                                      // Check if the input is greater than eligible amount
                                      if (inputValue > eligibleAmount) {
                                        // Display an error and reset to the eligible amount or empty value
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Value cannot exceed $eligibleAmount")),
                                          );
                                        
                                        // Optionally reset to eligible amount or clear the input
                                        _controllers[index].text = eligibleAmount.toString();
                                        _controllers[index].selection = TextSelection.fromPosition(
                                          TextPosition(offset: _controllers[index].text.length),
                                        );
                                      }
                                    } catch (e) {
                                      // ScaffoldMessenger.of(context).showSnackBar(
                                      //       SnackBar(content: Text("Invalid input or eligible amount: $e")),
                                      //     );
                                    }
                                },
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: const InputDecoration(
                                  label: Text("Sanction Amount"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            // SizedBox(height: 50,),
                            
                          ],
                        ),
                      ),
                    );
                  },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 50,
                    )
                  ),
            ),
          //   const SizedBox(
          //   height: 20,
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(onPressed: openHouseImages, text: 'NEXT'),
          ),
          ],
      )
    );
  }
  updateLoanPurpose(String value, int memberId)async {
    context.loaderOverlay.show();
      try {
        var response = await _client.updateLoanPurpose(value, memberId);
        await fetch();
        showMessage(context, "$response");
      } catch (e) {
        showMessage(context, "$e");
      }
      context.loaderOverlay.hide();
  }
}



