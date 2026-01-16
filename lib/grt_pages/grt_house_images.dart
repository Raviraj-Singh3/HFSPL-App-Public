import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Compress-Image/compress.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/custom_views/location.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/grt/grt_by_id_model.dart';

class GrtHouseImages extends StatefulWidget {
  final List<GRTById> membersList;
  const GrtHouseImages({ Key? key, required this.membersList }) : super(key: key);

  @override
  _GrtHouseImagesState createState() => _GrtHouseImagesState();
}


class _GrtHouseImagesState extends State<GrtHouseImages> {
  final DioClient _client = DioClient();
  Map<String,String> _imageFromAPi = {};
  int count = 0;

  Map<String,bool> _houseImageNotUploaded = {};

  Map<String,File?> _image = {}; // Store the captured image
  Map<String,String?> _imageName = {};
  final ImagePicker _picker = ImagePicker(); // Instantiate the image picker
  Map <String, bool>_isImageUplaodSuccess = {};

  // Method to capture image from the camera
  Future<void> _pickImageFromCamera(String memberCGTId) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {

       // Step 2: Convert XFile to File
    File originalFile = File(pickedFile.path);

    // Step 3: Compress the image
    File? compressedFile = await compressImage(originalFile);

      setState(() {
        _image[memberCGTId] = compressedFile; // Convert XFile to File and store it
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
       
        var response  = await _client.postGRTImages(memberCGTId,"house",position.latitude.toString(),position.longitude.toString(),_image[memberCGTId]!,_imageName[memberCGTId]!);

          print("response  $response");

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

  onSubmitClick(){
    // add validation to check all images is selected
      if((_houseImageNotUploaded.length  - _isImageUplaodSuccess.length) != 0){

           ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Upload All House Images')),
       );
        return ;
      }
    //
    print("submit");
    Navigator.pop(context,true);
  }
  
  @override
  void initState() {
    // TODO: implement initState
    for (var member in widget.membersList){
     _imageFromAPi[member.memberCgtId.toString()] = "${_client.baseurl}/api/Images/GetGrtPhoto?tag=${member.memberCgtId.toString()}_house";
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("House Images Of Members"),),
      body: Column(
        children: [
          // Text(widget.membersList[0].groupName!, style: TextStyle(fontSize: 18),),
          Expanded(child: widget.membersList.isEmpty
            ? const Center(
                          child: CircularProgressIndicator(
                          ),
                        )
            : ListView.builder(
              itemCount: widget.membersList.length,
              itemBuilder: (context, index) {
                String memberCGTId = widget.membersList[index].memberCgtId.toString();
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide( color: Colors.green.shade800)) ),
                  child: Column(
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment:   CrossAxisAlignment.start,
                            children: [
                              Text(widget.membersList[index].memberName!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
                              SizedBox(height: 5,),
                              Text('Spouse: ${widget.membersList[index].spouseName!}', style: TextStyle(fontSize: 16),),
                            ],
                          ),
                          _image[memberCGTId] == null
                          ? Image.network(
                            _imageFromAPi[memberCGTId]!,
                            width: 100,
                            height: 100,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                              if (loadingProgress == null){
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

                              return FilledButton(onPressed: (){
                                _pickImageFromCamera(memberCGTId);
                                
                              }, child: Icon(Icons.camera_alt));
                            },
                          )
                                : Column(
                                    children: [
                                      Image.file(
                                          _image[memberCGTId]!, // Display the selected image
                                          width: 100,
                                          height: 100,
                                        ),
                                        
                                        if(_isImageUplaodSuccess[memberCGTId] != true)
                                        Column(
                                          children: [
                                            const SizedBox(height: 20,),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                              SizedBox(height: 50, child: FilledButton(onPressed: (){
                                                _saveImage(memberCGTId);
                                              }, child: const Text("Upload"))),
                                              SizedBox(height: 20,),
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
                      
                    ],
                  ),
                );
              }
              ),
          ),
          const SizedBox(
            height: 20,
          ),
          PrimaryButton(onPressed: onSubmitClick, text: 'SUBMIT GRT'),
        ],
      )
    );
  }
}