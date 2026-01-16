import 'dart:convert';

import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/state/kyc_state.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/custom_views/app_button_secondary.dart';
import 'package:HFSPL/utils/messages_util.dart';

import '../custom_views/app_text_view.dart';
import '../network/networkcalls.dart';
import '../network/responses/center_model/center_model.dart';
import '../network/responses/center_model/group_list.dart';
import '../apply_loan_views/list_snapshot.dart';
import '../utils/globals.dart';

class GroupsPage extends StatefulWidget {
  final CenterModel selectedCenter;
  const GroupsPage({super.key, required this.selectedCenter});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool isGroupCreating = false;
  List<GroupModel> groupList = [];
  List<GroupModel> filterGroupList = [];
  final TextEditingController _textController = TextEditingController();
  final DioClient _client = DioClient();

  @override
  void initState() {
    if (widget.selectedCenter.groupList != null) {
      for (var grp in widget.selectedCenter.groupList!) {
        groupList.add(grp);
      }
    }
    filterGroupList = groupList;

    _textController.addListener(() {
    filterGroup(_textController.text);
  });

    // print("GroupList JSON: ${jsonEncode(widget.selectedCenter.groupList!.map((g) => g.toJson()).toList())}");

    super.initState();
    //fetch();
  }

   void filterGroup(String query) {
    setState(() {
      filterGroupList = groupList
          .where((group) => group.groupName!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Group")),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Center Name : ${widget.selectedCenter.centerName}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Groups: ${groupList.length}',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontStyle: FontStyle.italic),
                          ),
                        ]),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var group = filterGroupList[index];
                      return Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListTile(
                            title: Text(group.groupName!),
                            subtitle: Text(
                                group.isDisbursed! ? "Disbursed" : "Not Disbursed",
                                style: TextStyle(
                                    color: group.isDisbursed!
                                        ? Colors.green
                                        : const Color.fromARGB(226, 189, 170, 2))
                                ),
                            trailing: AppButtonSecondary(
                              onPressed: onGroupSelect,
                              text: 'Select',
                              valueToPassBack: group,
                              enabled: !group.isDisbursed! ? true : false,
                            )),
                      );
                    },
                    itemCount: filterGroupList.length,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AppTextBox(
                  controller: _textController,
                  keyboardType: TextInputType.text,
                  hintText: 'Enter group name',
                  labelText: 'Group name',
                ),
                const SizedBox(
                  height: 10,
                ),
                
                PrimaryButton(onPressed: (){_createGroup(context);}, text: "Create Group"),
                const SizedBox(
                  height: 10,
                )
              ]),
        ),
      ),
    );
  }

  _createGroup(value) async {
    //selectedVillageId
    //_textController
    if (_textController.text.trim().isEmpty) {
      // show alert for required text
      showError('Please enter group name');
    } else {
      setState(() {
        isGroupCreating = true;
      });

      try {
        // submit group
        var resp = await _client.createGroup(
            Global_uid,
            widget.selectedCenter.centerId!.toString(),
            _textController.text.trim());
        setState(() {
          groupList.add(resp);
          isGroupCreating = false;
        });
        onGroupSelect(resp);
      } catch (e) {
        showSnackBar(context, e.toString());
        setState(() {
          isGroupCreating = false;
        });
      }
    }
  }

  showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(msg),
      ),
    );
  }

  onGroupSelect(dynamic value) {
    KycState().setGroupMode();
    GroupModel selectedGroup = value as GroupModel;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListSnapshot(
                  selectedGroup: selectedGroup,
                )));
  }
}
