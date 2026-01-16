import 'package:HFSPL/Additional/Center%20Visit/center_monitoring.dart';
import 'package:HFSPL/Additional/Collection%20Posting/collection_posting.dart';
import 'package:HFSPL/Additional/Collection-Calling/collection_calling.dart';
import 'package:HFSPL/Additional/Mobile%20Verification/mobile_verification.dart';
import 'package:HFSPL/Additional/Overdue%20Members/overdue-members.dart';
import 'package:HFSPL/Additional/Today_overdue.dart/today_overdue.dart';
import 'package:HFSPL/Additional/Update-Disb-number/update_disb_number.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/user_roles_response.dart';
import 'package:HFSPL/utils/globals.dart';

class AddtionalDashboard extends StatefulWidget {
  const AddtionalDashboard({super.key});

  @override
  State<AddtionalDashboard> createState() => _AddtionalDashboardState();
}

class _AddtionalDashboardState extends State<AddtionalDashboard> {
  final DioClient _client = DioClient();
  UserRoleFlags? roles;

  @override
  void initState() {
    super.initState();
    getUserRoles();
  }

  void getUserRoles() async {
    try {
      var response = await _client.getUserRoles(Global_uid);
      setState(() {
        roles = response;
      });
    } catch (e) {
      await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('$e'),
        actions: [
          TextButton(
            onPressed: () {
              // Optionally close the app or open settings
              Navigator.of(context).pop();
              
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
    Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: roles == null
            ? const CircularProgressIndicator()
            : buildButtons(roles!),
      ),
    );
  }

Widget buildButtons(UserRoleFlags role) {
  bool hasPrimaryRole(UserRoleFlags role) =>
    role.isFe || role.isOtherFieldMember || role.isOdOfficer || role.isTelecaller;
  List<Widget> buttons = [];
  Set<String> addedLabels = {};

  void addButton(String label, Widget Function() pageBuilder) {
    if (!addedLabels.contains(label)) {
      buttons.add(button(label, pageBuilder));
      addedLabels.add(label);
    }
  }

  if (role.isFe) {
    // addButton("Center Calling");
    addButton("Collection Calling", () => const CollectionCalling());
    addButton("Overdue Members", () => const OverdueMembers());
    // addButton("Overdue Calling");
    addButton("Update Disburse Mobile", () => const UpdateDisbNumber());
    // addButton("Overdue Visit");
  }

  if (role.isOtherFieldMember) {
    addButton("Collection Posting", () => const CollectionPosting());
    // addButton("Update Mobile Number");
    addButton("Update Disburse Mobile", () => const UpdateDisbNumber());
    // addButton("Center Visit");
    addButton("Today Overdue", () => const TodayOverdue());
    // addButton("Center Visit", () => const CenterVisit());
    addButton("Center Visit", () => const CenterVisit());

    if (role.isBM_BCM) {
      addButton("Mobile Verification", () => const MobileVerification());
      // addButton("Overdue Calling");
    }

    if (role.isTaskForce) {
      // addButton("Task Force Posting");
    }
  }

  if (role.isOdOfficer) {
    addButton("Collection Posting", () => const CollectionPosting());
  //   addButton("Overdue Calling");
    addButton("Update Disburse Mobile", () => const UpdateDisbNumber());
  }

  if (role.isTelecaller) {
    addButton("Update Disburse Mobile", () => const UpdateDisbNumber());
    addButton("Today Overdue", () => const TodayOverdue());
  }

  if (!hasPrimaryRole(role) && role.isOtherStaff) {
    addButton("Update Disburse Mobile", () => const UpdateDisbNumber());
    addButton("Collection Posting", () => const CollectionPosting());
    // addButton("Update Mobile Number");
    addButton("Today Overdue", () => const TodayOverdue());

    // addButton("Center Visit", () => const CenterVisit());
  }

  if (buttons.isEmpty) {
    return const Text("Future options coming soon...");
  }

  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    ),
  );
}

    Widget button(String label, Widget Function() pageBuilder) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PrimaryButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageBuilder()),
          );
        },
        text: label,
      ),
    );
  }
}
