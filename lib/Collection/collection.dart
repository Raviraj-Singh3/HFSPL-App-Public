
import 'dart:convert';
import 'dart:io';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/OD_Monetaring/payment.dart';
import 'package:HFSPL/utils/open_google_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Collection/collect_online.dart';
import 'package:HFSPL/Compress-Image/compress.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/radio_with_text_heading.dart';
import 'package:HFSPL/Layouts/row_with_data.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_collection_data_model.dart';
import 'package:HFSPL/network/responses/Collection/demand_model.dart';
import 'package:HFSPL/utils/globals.dart';
import '../network/responses/OD/od_group_list.dart';

class Collection extends StatefulWidget {
  final int groupId;
  final String groupName;
  final DateTime collectionDate;
  final bool schedule;

  const Collection({super.key, required this.groupId, required this.groupName, required this.collectionDate, required this.schedule});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final DioClient _client = DioClient();
  int feId = 5;
  List<Member> demandMembersList = [];
  final List<TextEditingController> _controllers = [];
  Map<String, bool> isMemberPresent = {};
  var groupLocation;

  fetchDemand() async {
    try {
      var response = await _client.getDemand(int.tryParse(Global_uid)!,'${widget.collectionDate.year}-${widget.collectionDate.month}-${widget.collectionDate.day}',widget.groupId,widget.schedule);
      setState(() {
        demandMembersList = response.members!;
      });
      for (var member in demandMembersList) {
        isMemberPresent[member.memberId.toString()] = false;
      }

    }
    catch(e) {
      showMessage(context, "Error fetching data: $e");
    }
  }
  void getGroupLocation() async {
    var response = await _client.getGroupLocation(widget.groupId);
    groupLocation = response;
  }

  bool getIsMemberPresent(String memberId){
    if (!isMemberPresent.containsKey(memberId)) {
      return false;
    }
    return (isMemberPresent[memberId] ?? false);
  }

   var _image = null; // Store the captured image
  final ImagePicker _picker = ImagePicker();

  // Method to capture image from the camera
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {

      // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

      setState(() {
        _image = compressedFile; // 
      });
      
      context.loaderOverlay.show();

      // call the api
      

     try {

      Position position = await _getCurrentLocation();

      var data = {
        "PostedBy":Global_uid,
        "Id":widget.groupId,
        "ValueString":"123",
        "Latitude": position.latitude,
        "Longitude": position.longitude,
      };

        var response  = await _client.postGroupImage(_image,pickedFile.name,jsonEncode(data));

        context.loaderOverlay.hide();
        print("response"+response);
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Uplaod Success')),
       );
     } catch (e) {

      context.loaderOverlay.hide();

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(' $e')),
       );
       setState(() {
         _image = null;
       });
     }

    } else {
      showMessage(context, 'No image selected.');
    }
    }
  

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchGroups();
    fetchDemand();
    getGroupLocation();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (TextEditingController c in _controllers) {       c.dispose();     }
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

  // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, do something like showing a dialog
      // return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
  }

  // If permissions are granted, get the current position
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

  onSubmitClick() async {

    if (!mounted) return;

    if(_image == null){
      ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please Click Image First')),
          );
      return ;
    }

    context.loaderOverlay.show();

    Position position = await _getCurrentLocation();
    // var now = DateTime.now();
    List<PostCollectionDataModel> items = [];

    for (int i = 0; i < demandMembersList.length; i++){
      var m = demandMembersList[i];

      // Validate and parse input safely
        double collectedAmmount;
        try {
          collectedAmmount = double.parse(_controllers[i].text.trim());
        } catch (e) {
          collectedAmmount = 0.0; // Default value if parsing fails
        }

      var groupModel = PostCollectionDataModel(
        isPresent: getIsMemberPresent(m.memberId.toString()),
        amount: collectedAmmount,
        lat: position.latitude,
        lng: position.longitude,
        mId: m.memberId,
        postedBy: int.parse(Global_uid),
        transactionDate: widget.collectionDate,
    );
        items.add(groupModel);
    }

    try {

      

      var response = await _client.postCollection(jsonEncode(items));

       ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' Collection Completed Successfully!')),
          );
        
        context.loaderOverlay.hide();
        
          Navigator.pop(context, true);

      context.loaderOverlay.hide();

      //  if (response.statusCode == 200) {
      //     // Handle success
      //     if (!mounted) return;
          
      //     ScaffoldMessenger.of(context).showSnackBar(
      //        SnackBar(content: Text(' Collection Completed Successfully! $response')),
      //     );
          
      //     Navigator.pop(context, true);
          
      //   } else {
      //     // Handle API error

      //     if (!mounted) return;

      //     context.loaderOverlay.hide();

      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Failed!')),
      //     );
          
      //   }
    } catch (e) {
       context.loaderOverlay.hide();
       ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('$e')),
          );
    }
    
  }

  

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Collection",),),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Collection Date: ", style: TextStyle(fontSize: 16),),
                        Text(DateFormat('yyyy-MM-dd').format(widget.collectionDate), style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                          
                      ],
                    ),
                    Text(widget.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    FilledButton(
                      onPressed: () {
                        if(groupLocation == null || groupLocation == null){
                              showMessage(context, "No Location Available.");
                              return;
                            }
                            openGoogleMaps(
                            groupLocation["Latitude"].toString(),
                            groupLocation["Longitude"].toString(),
                            );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Directions',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.directions,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )


                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: demandMembersList.length,
                itemBuilder: (context, index) {
                  _controllers.add(TextEditingController());
                  Member member = demandMembersList[index];
                  var date =  DateFormat('dd-MM-yyyy').format(member.collectionDate!);
                  return Card(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if(index == 0)
                            Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: const Border(bottom: BorderSide(color: Colors.red)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    const Text("Click Group/Center Photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      onTap: _pickImageFromCamera,
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        margin: const EdgeInsets.symmetric(vertical: 10),
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
                                            Text("Click Image", style: const TextStyle(color: Colors.purple)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Text(demandMembersList[index].name!, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                          Text(demandMembersList[index].loanNumber! , style: TextStyle(fontSize: 16,)),
                          RowWithData(title: 'I.N.:', data: demandMembersList[index].installment.toString()),
                          RowWithData(title: 'Actual Date', data: date),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("EMI:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              Text(member.emi.toString(), style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                  
                            ],
                          ),
                          RowWithData(title: 'OD', data: member.overdue.toString(),),
                          RowWithData(title: 'Penalty', data: member.penalty.toString(),),
                          RowWithData(title: "Today's Demand:", data: member.demand.toString()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Collected Amount:",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              SizedBox(
                                width: 150,
                                height: 44,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _controllers[index],
                                  onTapOutside: (PointerDownEvent event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  },
                                            decoration: const InputDecoration(
                                    label: Text("Amount"),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                                  
                            ],
                          ),
                          RadioWithTextHeading(
                            heading: 'Attendance', 
                            radioTitle1: 'Present', 
                            radioTitle2: 'Absent', 
                            groupValue: isMemberPresent[demandMembersList[index].memberId.toString()], 
                            onChanged: (bool? newValue) {
                                  setState(() {
                                    // Update the value in isMemberPass
                                    isMemberPresent[demandMembersList[index].memberId.toString()] = newValue!;
                                  });
                                },),
                          FilledButton(onPressed: () {
                              openCollectOnline(demandMembersList[index]);
                    },child: const Text("COLLECT ONLINE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),

                    const SizedBox(height: 20,),
                        ],
                        
                      ),
                    ),
                  );
                },
                ),
            ),
            const SizedBox(
            height: 20,
          ),
          PrimaryButton(onPressed: (){
            onSubmitClick();
          }, text: 'SUBMIT COLLECTION')
          ],
        ),
      ),
    );
  }
  
   openCollectOnline(Member demandMember) {
    // print("member list ${demandMembersList.name}");
    // Navigator.push(
    //   context, MaterialPageRoute(
    //     builder: (context) => CollectOnline(member: demandMembersList),
    //     ));
      var member = OdMember(
         loanNo: demandMember.loanNumber!,
         loanAmt: 0.0,
         loanDate: "",
         intrAmt: 0.0,
         intrRate: 0.0,
         misId: demandMember.memberId!,
         memberName: demandMember.name!,
         spouse: demandMember.relativeName!,
         mobile: "",
         odStartDate: "",
         lastTransactionDate: "",
         totAmtPayable: 0.0,
         intrAmtPayable: 0.0,
         prAmtPayable: 0.0,
         totalOS: 0.0,
         interestOS: 0.0,
         principleOS: 0.0,
          duesDays: 0,
      );
        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentOd(member: member, demandAmount: '${demandMember.emi}'),));
   }
}