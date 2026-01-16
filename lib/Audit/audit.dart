import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Audit/card.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_snapshots_model.dart';
import 'package:HFSPL/network/responses/AuditModel/get_all_branches.dart';
import 'package:HFSPL/utils/globals.dart';

class Audit extends StatefulWidget {
  const Audit({super.key});

  @override
  State<Audit> createState() => _AuditState();
}

class _AuditState extends State<Audit> {

  final DioClient _client = DioClient();
  bool isLoading = true;
  String? errorText;

  List<AuditSnapshotModel> auditSnapshotsList = [];
  List<BranchModel> branchList = [];
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetch();
    _getAllBranches();
  }

  _fetch() async {
    context.loaderOverlay.show();
    try {
     var response = await _client.getAuditSnapshots(Global_uid);
      setState(() {
        auditSnapshotsList = response;
         isLoading = false;
      });
    } catch (e) {
        setState(() {
        isLoading = false;
        });
      showMessage(context, "error: $e ");
    }
    context.loaderOverlay.hide();
  }

  _getAllBranches() async {
    try {
     var response = await _client.getAllBranches(Global_uid);
      setState(() {
        branchList = response;
      });
      
    } catch (e) {
      showMessage(context, "error: $e ");
    }
  }
  

  void _showBranchSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select a Branch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: branchList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(branchList[index].branchName!),
                      onTap: () {
                        _selectedBranch(branchList[index].bid!, branchList[index].branchName!);
                        // print('Selected: ${branchList[index].branchName}');
                        // Navigator.pop(context); // Close the modal
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectedBranch(int id, String branchName) {
    Navigator.pop(context);
    TextEditingController snapshotContoller  = TextEditingController();
    
    showDialog(context: context,
     builder: (context) {
       return AlertDialog(
         title: const Text('Enter Snapshot Name'),
         content: Text('Selected branch is: $branchName'),
         actions: [
            TextField(
              controller: snapshotContoller,
              decoration: const InputDecoration(
                hintText: 'Enter Snapshot Name',
                // errorText: errorText
              ),
            ),
           TextButton(
             onPressed: () {
             var data = {
                "BranchId": id,
                "AuditorId": Global_uid,
                "Comments": snapshotContoller.text.trim(),
              };
              _createSnapshot(data);
              //  Navigator.pop(context);
             },
             child: const Text('OK'),
           ),
         ],
       );
     }
     );
  }

  _createSnapshot(data) async {
    try {
      if(data['Comments'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text('Please enter snapshot name'),
                ),
        );
        return;
      }
      var response = await _client.createAuditSnapshot(data);
      // showMessage(context, "$response");
      Navigator.pop(context);
      _fetch();
    } catch (e) {
      showMessage(context, "error: $e ");
    }
  }


  @override
  Widget build(BuildContext context) {

    if(isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if(auditSnapshotsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit')),
        body: const Center(child: Text("No data found")),
        floatingActionButton: FloatingActionButton(
        onPressed: _showBranchSelector,
        child: Icon(Icons.add),
        ),
        
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80.0),
              itemCount: auditSnapshotsList.length,
              itemBuilder: (context, index) {
                return CardAudit(
                  auditSnapshot: auditSnapshotsList[index],
                  onEnd: (){
                    _fetch();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBranchSelector,
        child: Icon(Icons.add),
        ),
    );
  }
}