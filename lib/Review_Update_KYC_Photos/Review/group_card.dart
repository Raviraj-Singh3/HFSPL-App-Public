
import 'package:flutter/material.dart';
import 'package:HFSPL/Review_Update_KYC_Photos/Review/review_kyc.dart';
import 'package:HFSPL/network/responses/ReviewKyc/review_group.dart';

class GroupCard extends StatefulWidget {
  
  final ReviewGroupModel group;

  const GroupCard({super.key, required this.group});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          scale = 0.95; // Shrink slightly on tap
        });
      },
      onTapUp: (_) {
        setState(() {
          scale = 1.0; // Return to normal size
        });
        // Perform the action here, e.g., navigate to another screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewKYC(groupdId: widget.group.groupId)));
        },
        onTapCancel: () {
          setState(() {
            scale = 1.0; // Reset size if the tap is canceled
          });
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title:  Text(widget.group.groupName),
            subtitle:  Text(widget.group.centerName),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}