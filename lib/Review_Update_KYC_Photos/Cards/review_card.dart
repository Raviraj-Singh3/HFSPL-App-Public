import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_members.dart';
import 'package:HFSPL/utils/globals.dart';

class ReviewCard extends StatefulWidget {
  ReviewMembersModel member;
  final VoidCallback onRemove;

   ReviewCard({
    super.key, required this.member,
    required this.onRemove
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final DioClient _client = DioClient();

  // String? _image;
  var rawImageBytes;

  void showFullScreenImageDialog(BuildContext context, int clientId, int clientCgtId, int reason)async {
    print("clientId: $clientId, clientCgtId: $clientCgtId, reason: $reason");
    context.loaderOverlay.show();
    
    try {
      var response = await _client.getKycPhoto(clientId, clientCgtId, reason);
      setState(() {
        rawImageBytes = response;
      });
       showDialog(
      context: context,
      barrierDismissible: true, // Dismiss when tapping outside
      builder: (context) {
        return FullScreenImageDialog(imagePath: response);
      },
    );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
   context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.assignment, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Text(
                  "Review Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                Text(
                  "Member Name: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.member.clientName!,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Relative Name
            Row(
              children: [
                Flexible(
                  child: Text(
                    "Relative Name: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  widget.member.relativeName!,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // HM Date
            Row(
              children: [
                Text(
                  "Hm Date: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.member.hmDtm!,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // View Images Buttons
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showFullScreenImageDialog(context, widget.member.clientId!, widget.member.clientCgtId!, 2);
                    },
                    icon: const Icon(Icons.photo, size: 20),
                    label: const Text("View KYC Photo Front"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      showFullScreenImageDialog(context, widget.member.clientId!, widget.member.clientCgtId!, 1);
                    },
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text("View Member Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      showFullScreenImageDialog(context, widget.member.clientId!, widget.member.clientCgtId!, 5);
                    },
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text("View kyc Photo back side"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      showFullScreenImageDialog(context, widget.member.clientId!, widget.member.clientCgtId!, 6);
                    },
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text("View Voter ID Front Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      showFullScreenImageDialog(context, widget.member.clientId!, widget.member.clientCgtId!, 7);
                    },
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text("View Voter ID Photo back side"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Approve/Reject Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _onApproveClicked(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text("Approve"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showRejectionDialog(context, widget.member.clientId!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text("Reject"),
                ),

                
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onApproveClicked(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Approve KYC',
            style: TextStyle(
              color: Colors.green
            ),
          ),
          content: const Text('Are you sure you want to Approve this KYC?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _approve();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  _approve() async {
    if(widget.member.clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Client ID is null")));
      return;
    }
    context.loaderOverlay.show();

    try {
      
      var response = await _client.approveKyc(widget.member.clientId!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$response")));
      widget.onRemove();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
    context.loaderOverlay.hide();
  }

  

 void showRejectionDialog(BuildContext context, int clientId) {
  _reject(selectedReasons) async {

    context.loaderOverlay.show();
    try {
     var data = {
          "ClientId": clientId,
          "RejectBy": Global_uid,
          "Reasons": selectedReasons
        };
      var response = await _client.rejectKyc(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$response")));
      widget.onRemove();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
      context.loaderOverlay.hide();
  }
    List<int> selectedReasons = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Reason to Reject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('KYC photo is not clear/not available'),
                    value: selectedReasons.contains(2),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(2);
                        } else {
                          selectedReasons.remove(2);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Member photo is not clear/not available'),
                    value: selectedReasons.contains(1),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(1);
                        } else {
                          selectedReasons.remove(1);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Kyc photo back side is not clear/not available'),
                    value: selectedReasons.contains(5),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(5);
                        } else {
                          selectedReasons.remove(5);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Voter Card Front not clear/not available'),
                    value: selectedReasons.contains(6),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(6);
                        } else {
                          selectedReasons.remove(6);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Voter Card Back not clear/not available'),
                    value: selectedReasons.contains(7),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(7);
                        } else {
                          selectedReasons.remove(7);
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedReasons.isNotEmpty) {
                      _reject(selectedReasons);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one reason.')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class FullScreenImageDialog extends StatelessWidget {
  final Uint8List? imagePath;

  const FullScreenImageDialog({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: imagePath != null
                  ? Image.memory(
                      imagePath!,
                      fit: BoxFit.contain,
                    )
                  : const Center(
                      child: Text(
                        "No Image Found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
