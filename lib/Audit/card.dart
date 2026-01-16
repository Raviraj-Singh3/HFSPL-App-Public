
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Audit/audit_process.dart';
import 'package:HFSPL/Audit/question_page.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/custom_views/app_button_secondary.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_snapshots_model.dart';
import 'package:HFSPL/utils/globals.dart';

class CardAudit extends StatefulWidget {
  
  final AuditSnapshotModel auditSnapshot;
  final VoidCallback onEnd;
  const CardAudit({super.key, required this.auditSnapshot, required this.onEnd});

  @override
  State<CardAudit> createState() => _CardAuditState();
}

class _CardAuditState extends State<CardAudit> {
  final DioClient _client = DioClient();

  @override
  Widget build(BuildContext context) {

    _openCategoryList(dynamic value){
      Navigator.push(context,
       MaterialPageRoute(builder: (context)=> AuditProcess(snapshot: widget.auditSnapshot))
       );
    }
    
    return Card(
  child: ListTile(
    leading: widget.auditSnapshot.isCompleted == true
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.error, color: Colors.red),
    title: Text(widget.auditSnapshot.snapshotName ?? "N/A"),
    subtitle: Text(widget.auditSnapshot.auditStartDate ?? "N/A"),
    trailing: Row(
      mainAxisSize: MainAxisSize.min, // Adjusts to the content size
      children: [
        AppButtonSecondary(
          onPressed: _openCategoryList,
          enabled: !widget.auditSnapshot.isCompleted!,
          text: 'Select',
          valueToPassBack: "2",
        ),
        const SizedBox(width: 5),
        AppButtonSecondary(
          onPressed: onEnd,
          enabled: !widget.auditSnapshot.isCompleted!,
          text: 'End',
          valueToPassBack: "1",
        ),
      ],
    ),
  ),
);

  }

  

  

  onEnd(dynamic value)async {
   context.loaderOverlay.show();

    try {

      var response = await _client.endAudit(widget.auditSnapshot.auditSnapshotId!, Global_uid);

      showMessage(context, "$response");

      //refresh list
      widget.onEnd();
      
    } catch (e) {
      showMessage(context, "$e");
    }
    context.loaderOverlay.hide();
  }
}