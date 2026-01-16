import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Functions/image_picker.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ReviewKyc/rejected_members_model.dart';

class UpdateCard extends StatefulWidget {
  final VoidCallback onRemove;

 final RejectedMembersModel member;

  const UpdateCard({super.key, required this.member, required this.onRemove});

  @override
  State<UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<UpdateCard> {
  final DioClient _client = DioClient();

  @override
  Widget build(BuildContext context) {
    
    List <RejectReason> rejectReasons = widget.member.rejectReasons??[];

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  "Member Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
              height: 20,
            ),

            // Member Name
             Row(
              children: [
               const Text(
                  "Member Name: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                Text(
                  widget.member.clientName!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Relative Name
            Row(
              children: [
               const Text(
                  "Relative Name: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                Text(
                   widget.member.relativeName!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            if(rejectReasons.any(( reason) => reason.rejectStatus == 2))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _updateMemberKyc(2);
                },
                icon: const Icon(Icons.photo_camera, size: 20,),
                label: const Text(
                  "Update KYC Photo Front",
                  style: TextStyle(fontSize: 16,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            
            if(rejectReasons.any(( reason) => reason.rejectStatus == 1))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _updateMemberKyc(1);
                },
                icon: const Icon(Icons.photo, size: 20,),
                label: const Text(
                  "Update Member Photo",
                  style: TextStyle(fontSize: 16,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            
            if(rejectReasons.any(( reason) => reason.rejectStatus == 5))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _updateMemberKyc(5);
                },
                icon: const Icon(Icons.photo, size: 20,),
                label: const Text(
                  "Update Kyc photo Back",
                  style: TextStyle(fontSize: 16,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if(rejectReasons.any(( reason) => reason.rejectStatus == 6))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _updateMemberKyc(6);
                },
                icon: const Icon(Icons.photo, size: 20,),
                label: const Text(
                  "Update Voter Id Front",
                  style: TextStyle(fontSize: 16,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if(rejectReasons.any(( reason) => reason.rejectStatus == 7))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _updateMemberKyc(7);
                },
                icon: const Icon(Icons.photo, size: 20,),
                label: const Text(
                  "Update Voter Id Back",
                  style: TextStyle(fontSize: 16,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  _updateMemberKyc(int reason) async{

  File? image = await pickImageFromCamera();

    // Create a temporary copy of the file
  final tempDir = await getTemporaryDirectory();
  final tempFile = await image.copy('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');

  var data = {
    "clientCgtId": widget.member.clientCgtId,
    "clientId": widget.member.clientId,
    "reason": reason
  };

    try {

      var response = await _client.updateRejectedPhoto(data, tempFile, tempFile.path.split('/').last);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$response")));

    widget.onRemove();
    
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
    finally {
    // Clean up the temporary file
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  }
  }
}
