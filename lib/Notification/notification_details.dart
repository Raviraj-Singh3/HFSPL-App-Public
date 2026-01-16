import 'dart:convert';

import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/LeaveResponse/leave_details_model.dart';
import 'package:HFSPL/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter/foundation.dart';

class NotificationDetails extends StatefulWidget {
  final String? guid;
  final int notiId;

  const NotificationDetails({super.key, required this.guid, required this.notiId});

  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {
  final DioClient _client = DioClient();
  LeaveDetailsModel? leaveDetails;
  List<int> approveLeaveIds = [];
  List<int> rejectedLeaveIds = [];
  bool isLoading = true;
  TextEditingController commentController = TextEditingController();

  void _getLeaveDetails() async {
    try {
      var response = await _client.getLeaveDetails(widget.guid!);
      setState(() {
        leaveDetails = response;
        isLoading = false;

        // Collect all leave IDs for bulk approval/rejection
        if (leaveDetails?.data != null) {
          approveLeaveIds = leaveDetails!.data!.map((leave) => leave.id!).toList();
        }
      });
    } catch (e) {
      showMessage(context, "Error getting leave details");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submit() async {
    
    context.loaderOverlay.show();

    try {
      
      var request = {
        "aprooveLeaveIds": approveLeaveIds,
        "rejectedLeaveIds": rejectedLeaveIds,
        "aproovedBy": Global_uid, // Replace with the actual user ID
        "comment": commentController.text.isNotEmpty ? commentController.text.trim() : "",
      };

      await _client.postApproveLeave(jsonEncode(request));

      showMessage(context, "success..");

      await _client.readNotificaton(widget.notiId);

      Navigator.pop(context, true);

    } catch (e) {

      showMessage(context, "Failed to submit. Try again.");
      
    }

    context.loaderOverlay.hide();
  }

  @override
  void initState() {
    super.initState();
    _getLeaveDetails();
  }
    @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaveDetails == null || leaveDetails!.data == null || leaveDetails!.data!.isEmpty
              ? const Center(child: Text("No details available"))
              : _buildDetailsView(),
    );
  }

  Widget _buildDetailsView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: leaveDetails!.data!.map((leave) => _buildLeaveCard(leave)).toList()
        ..add(_buildImageSection())
        ..add(_commentBox())
        ..add(_buildActionButtons()),
    );
  }

  Widget _buildLeaveCard(LeaveDetail leave) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: CheckboxListTile(
        value: approveLeaveIds.contains(leave.id),
        onChanged: (isChecked) {
          setState(() {
            if (isChecked!) {
              approveLeaveIds.add(leave.id!);
              rejectedLeaveIds.remove(leave.id);
            } else {
              approveLeaveIds.remove(leave.id);
              rejectedLeaveIds.add(leave.id!);
            }
          });
        },
        title: Text("${leave.name} (${leave.leaveName})"),
        subtitle: Text("Date: ${leave.leaveDate!.split("T")[0]}\nReason: ${leave.description}"),
        secondary: const Icon(Icons.event, color: Colors.blue),
      ),
    );
  }

  Widget _buildImageSection() {
  if (leaveDetails!.images == null || leaveDetails!.images!.isEmpty)
    return const SizedBox();

  const baseUrl = kIsWeb
    ? "https://web-production-09ea.up.railway.app/http://mishumanafinancial.com:70/UploadFileHr"
    : "http://mishumanafinancial.com:70/UploadFileHr";

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Text(
        "Attachment:",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: leaveDetails!.images!.length,
          itemBuilder: (context, index) {
            final rawPath = leaveDetails!.images![index];
            final parts = rawPath.split(RegExp(r'[\\/]'));
            final folder = parts.length >= 2 ? parts[parts.length - 2] : "";
            final fileName = parts.isNotEmpty ? parts.last : rawPath;
            final imageUrl = "$baseUrl/$folder/$fileName";
            // print("image url $imageUrl");

            return GestureDetector(
              onTap: () {
                _showFullImageDialog(imageUrl);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

void _showFullImageDialog(String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100, color: Colors.white),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _commentBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextField(
              controller: commentController,
              // maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Comment. . .',
                // hintText: 'Enter Comment about your leave...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text("Submit"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ),
    );
  }
}
