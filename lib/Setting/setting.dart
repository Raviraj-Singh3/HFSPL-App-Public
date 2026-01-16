import 'dart:io';
import 'dart:typed_data';

import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/utils/New%20Image%20Picker/new_image_picker.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:HFSPL/utils/show_popup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  File? imageFile;
  String labelText = 'Upload Image';
  final DioClient _client = DioClient();
  Uint8List? profileImageString;

  void _pickImage(ImageSource source) async {

    final pickedImage = await getImage(source);
    await  uploadProfileImage(pickedImage);
      getProfileImage();
  }
  void selectImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source"),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text("Camera"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.image),
            label: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void getProfileImage() async {
    try {
      final response = await _client.getProfileImage(Global_uid);
      // print("response: $response");
      setState(() {
        profileImageString = response;
        Global_profileImageBytes = response;
      });
    } catch (e) {
      // print("Error: $e");
      // showMessage(context, "Error: $e");
    }
  }

   uploadProfileImage (File pickedImage) async {
    context.loaderOverlay.show();
    try {
      FormData formData = FormData();
      formData.files.add(MapEntry(
        "file",
        await MultipartFile.fromFile(
          pickedImage.path,
          filename: pickedImage.path.split('/').last,
      ),
      ));
      final response = await _client.uploadProfileImage(Global_uid, formData);
      // print("response: $response");
    } catch (e) {
      // print("Error: $e");
      showMessage(context, "$e");
    }
    context.loaderOverlay.hide();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Global_profileImageBytes != null) {
      profileImageString = Global_profileImageBytes;
      } else {
      getProfileImage();
    }
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: selectImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50,
                      child: profileImageString != null
                          ? ClipOval(
                              child: Image.memory(
                                profileImageString!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // const Icon(Icons.upload, size: 40, color: Colors.purple),
                                // Text(labelText, style: const TextStyle(color: Colors.purple)),
                              ],
                            ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Tooltip(
                        message: 'Change Profile Picture',
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // PrimaryButton(onPressed: () {}, text: "Save")
          ],
        ),
      ),
    );
  }
}