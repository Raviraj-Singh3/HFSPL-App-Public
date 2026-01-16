import 'package:HFSPL/Audit/dummy.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/apply_loan_views/report.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'select_category.dart';
import '../center_pages/village_dropdown.dart';
import '../custom_views/app_button.dart';
import '../custom_views/app_button_secondary.dart';
import '../custom_views/app_input_alert_dialog.dart';
import '../network/networkcalls.dart';
import '../network/responses/center_model/group_list.dart';
import '../network/responses/kyc/renewal_mtl_model.dart';
import '../network/responses/kyc/snapshot_model/snapshot_model.dart';
import '../utils/date_utils.dart';
import '../utils/globals.dart';
import '../utils/messages_util.dart';
import '../utils/show_popup.dart';
import '../state/kyc_state.dart';

class ListSnapshot extends StatefulWidget {
  final GroupModel? selectedGroup;
  const ListSnapshot({Key? key, this.selectedGroup})
      : super(key: key);

  @override
  ListSnapshotState createState() => ListSnapshotState();
}

class ListSnapshotState extends State<ListSnapshot> {
  List<SnapshotModel> data = [];
  bool isLoading = true;
  final DioClient _client = DioClient();
  String selectedVillageId = '';
  final TextEditingController _renewalController = TextEditingController();
  
  // Cache the KycState instance
  final KycState _kycState = KycState();

  @override
  void initState() {
    loadsnapshotlist();
    // loadVillages();
    super.initState();
  }

  @override
  void dispose() {
    _renewalController.dispose();
    super.dispose();
  }

  void loadsnapshotlist() async {
    try {
      var d = _kycState.isIndividual
          ? await _client.loadIndivisualSnapshot()
          : await _client.loadGroupSnapshot(widget.selectedGroup!.groupId!);
      setState(() {
        data = d;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _onCreateNewSnapshot(value) {
    if (_kycState.isIndividual && selectedVillageId == '') {
      showSnackBar(context, 'Please select a village');
      return;
    }
    // present popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppInputAlertDialog(
          title: 'Create new household',
          description: '',
          hintText: '',
          labelText: 'Household name',
          keyboardType: TextInputType.name,
          confirmCallback: (inputValue) {
            // print('Confirmed with input: $inputValue');

            if (inputValue.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text('Please enter snapshot name'),
                ),
              );
            } else {
              postSnapshot(inputValue);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          cancelCallback: () {
            // Handle your cancel action
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
  }

  void postSnapshot(String snapshotName) async {
    try {
      var nData = _kycState.isIndividual
          ? await _client.createIndividualSnapshot(
              Global_uid, selectedVillageId, snapshotName)
          : await _client.createGroupSnapshot(
              widget.selectedGroup!.groupId!, snapshotName);
      setState(() {
        data.add(nData);
      });
    } catch (e) {
      loadsnapshotlist();
      showSnackBar(context, e.toString());
    }
  }

  onSnapshotContinueClick(value) async {
    var model = value as SnapshotModel;
    // print("model ${model}");

    // print(object);
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectCategory(
                  snapshotModel: model,
                )));
    if (result == true) {
      // print("result... $result");
      //refresh
      loadsnapshotlist();
    }
  }

  onCheckReportClick(value) async {

    var model = value as SnapshotModel;
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Report(
                  snapshotModel: model,
                )));
    if (result == true) {
      // print("result... $result");
      //refresh
      loadsnapshotlist();
    }

  }

  onDownloadReportClick(value) async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Household")),
      body: Center(
        child: Container(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Please Select A Household To Continue',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: data.isEmpty
                            ? const Text('No any Household created yet.')
                            : ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 0,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey)),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(
                                                      data[index].name!,
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 13.0,
                                                            color: Colors.black,
                                                            wordSpacing: 2),
                                                        children: [
                                                          const TextSpan(
                                                              text:
                                                                  'Created on '),
                                                          TextSpan(
                                                              text: data[index]
                                                                  .cDate
                                                                  ?.convertToDateThenString()),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      data[index].getStatus(),
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: data[index]
                                                            .getStatusColor(),
                                                      ),
                                                    ),
                                                  ])),
                                              if (data[index].status == 0)
                                                AppButtonSecondary(
                                                  onPressed:
                                                      onSnapshotContinueClick,
                                                  text: 'Continue',
                                                  valueToPassBack: data[index],
                                                ),
                                              if (data[index].status == 1 && data[index].loanType != 2)
                                                AppButtonSecondary(
                                                  enabled: true,
                                                  onPressed: onCheckReportClick,
                                                  text: 'Check Report',
                                                  valueToPassBack: data[index],
                                                ),
                                              if (data[index].status == 2)
                                                AppButtonSecondary(
                                                  enabled: true,
                                                  onPressed: onCheckReportClick,
                                                  text: 'Download Report',
                                                  valueToPassBack: data[index],
                                                ),
                                              if (data[index].status == 3)
                                                AppButtonSecondary(
                                                  enabled: false,
                                                  onPressed: onCheckReportClick,
                                                  text: 'Verify Pending',
                                                  valueToPassBack: data[index],
                                                )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (_kycState.isIndividual)
                        VillageDropDown(
                          onChanged: (value) {
                            selectedVillageId = value;
                          },
                        ),
                      PrimaryButton(
                          onPressed: (){_onCreateNewSnapshot(context);},
                          text: 'Create Household'),
                          const SizedBox(height: 15,),
                      if(!_kycState.isIndividual)
                      PrimaryButton(
                          onPressed: (){_onRenewalClick(context);},
                          text: 'Add Renewal Client'),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

 void _onRenewalClick(BuildContext context){
  showPopup(
    context: context,
    heading: "Renewal/MTL",
    content: [
      TextField(
        controller: _renewalController,
        decoration: const InputDecoration(labelText: "Enter Existing Aadhar No."),
        keyboardType: TextInputType.number,
      ),
      // Add more widgets if needed
    ],
    positiveButtonText: "Submit",
    negativeButtonText: "Cancel",
    onPositive: () => _onSubmit(),
  );
 }

  _onSubmit() async {
   try {
     if (_renewalController.text.trim().isEmpty) {
       showSnackBar(context, 'Please enter Aadhar number');
       return;
     }
     
    context.loaderOverlay.show();
     
     // Call the API
     var response = await _client.checkRenewalMtl(
       _renewalController.text.trim(),
       widget.selectedGroup?.groupId ?? 0,
     );

     
     // Check if widget is still mounted before using context
     if (!mounted) return;
      context.loaderOverlay.hide();
     
     if (response.details != null && response.options != null) {
       // Show options dialog
       _showRenewalOptionsDialog(response);
     }
     
   } catch (e) {
    // Check if widget is still mounted before using context
    if (!mounted) return;
     context.loaderOverlay.hide();
    
    showPopup(
    context: context,
    heading: "Alert",
    content: [
      Text('$e'),
    ],
    positiveButtonText: "Ok",
    // negativeButtonText: "Cancel",
    onPositive: (){},
  );
    //  print('$e');
   }
 }

 void _showRenewalOptionsDialog(RenewalMtlResponse response) {
   showDialog(
     context: context,
     builder: (BuildContext dialogContext) {
       return AlertDialog(
         title: Text('Client Found: ${response.details?.name ?? ''}'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Loan No: ${response.details?.loanNo ?? ''}'),
             const SizedBox(height: 16),
             const Text('Select option:'),
             const SizedBox(height: 8),
             ...response.options!.map((option) => 
               ListTile(
                 title: Text(option.name ?? ''),
                 onTap: () {
                   Navigator.of(dialogContext).pop();
                   _handleRenewalOption(option, response.details!);
                 },
               )
             ).toList(),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(dialogContext).pop(),
             child: const Text('Cancel'),
           ),
         ],
       );
     },
   );
 }

 void _handleRenewalOption(RenewalMtlOption option, RenewalMtlDetails details) async {


   try {

     context.loaderOverlay.show();

     var response = await _client.submitRenewalMTL(option.type!, details.snapId!, details.nUid!, widget.selectedGroup!.groupId!, details.name!);
    //  print("response : $response");

     // Check if widget is still mounted before using context
     if (!mounted) return;
      context.loaderOverlay.hide();
     
     loadsnapshotlist();

   } catch (e) {
    // Check if widget is still mounted before using context
    if (!mounted) return;
    context.loaderOverlay.hide();
    
    showPopup(
      context: context,
      heading: "Alert",
      content: [
        Text('$e'),
      ],
      positiveButtonText: "Ok",
      // negativeButtonText: "Cancel",
      onPositive: (){},
    );
    //  print("error: $e");
   }
 }
}
