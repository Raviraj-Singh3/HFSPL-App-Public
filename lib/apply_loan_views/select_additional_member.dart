import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/custom_views/app_input_alert_dialog.dart';

import '../custom_views/app_button_secondary.dart';
import '../network/networkcalls.dart';
import '../network/responses/kyc/kyc_additional_members.dart';
import '../network/responses/kyc/kyc_category_response.dart';
import 'select_sub_category.dart';
import '../state/kyc_state.dart';

class SelectAdditionalMember extends StatefulWidget {
  final KycCategory selectedCat;
  final int snapshotId;
  const SelectAdditionalMember(
      {Key? key, required this.selectedCat, required this.snapshotId})
      : super(key: key);

  @override
  SelectAdditionalMemberState createState() => SelectAdditionalMemberState();
}

class SelectAdditionalMemberState extends State<SelectAdditionalMember> {
  List<KycAdditionalMember> data = [];
  bool isLoading = false;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
     var d = KycState().isIndividual
          ? await _client.getAdditionalMembersIndividual(widget.snapshotId) 
          : await _client.getAdditionalMembers(widget.snapshotId);
      setState(() {
        data = d;
      });
      if (d.isEmpty) {
        _addNewMember(null);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  onMemberPress(dynamic value) {
    KycAdditionalMember selectedMember = value as KycAdditionalMember;
    // Navigator.pop(context, selectedMember);
    openSelectedSubCat(widget.selectedCat, selectedMember);
  }

  openSelectedSubCat(
      KycCategory selectedCat, KycAdditionalMember? additionalMember) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectSubCategory(
                selectedCat: selectedCat,
                selectedMember: additionalMember,
                snapshotid: widget.snapshotId,
              )),
    );
    // if (result != null) {
    //   // open questions
    //   KycSubCategory selectedSubCat = result as KycSubCategory;
    //   openQuestionsPage(selectedCat, selectedSubCat, additionalMember);
    // }
  }

  _addNewMember(value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppInputAlertDialog(
          title: 'Add additional member',
          description: '',
          hintText: '',
          labelText: 'Additional member name',
          keyboardType: TextInputType.name,
          confirmCallback: (inputValue) {
            print('Confirmed with input: $inputValue');
        
            if (inputValue.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text('Please enter additionl member name'),
                ),
              );
            } else {
              postAdditionalMember(inputValue);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          cancelCallback: () {
            print('Cancelled');
            // Handle your cancel action
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
  }

  postAdditionalMember(String memberName) async {

    print("addition post ${widget.selectedCat.snapshotId}");
    var d =  await _client.addAdditionalMember(
            widget.snapshotId, memberName);
    // if it was first member then nominate it by default
    if (data.isEmpty && d.isNotEmpty) {
      await _markNominee(d[0].id!);
    } else {
      fetchData();
    }
  }

  _markNominee(int additionalMemberId) async {
  
      await _client.updateNominee(
          widget.snapshotId, additionalMemberId);
    

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(title: Text("Additional Members")),
        body: SingleChildScrollView(
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
                        Text(
                          data.isEmpty && !isLoading
                              ? 'Additional member list is empty'
                              : 'Please select an member below',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 0,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                            bottom:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            data[index].name!,
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                          AppButtonSecondary(
                                            onPressed: onMemberPress,
                                            text: 'Fill',
                                            valueToPassBack: data[index],
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: data[index].isNominee,
                                                onChanged: data[index]
                                                            .isNominee ==
                                                        true
                                                    ? null
                                                    : (bool? value) {
                                                        if (value == true) {
                                                          // mark nominee
                                                          _markNominee(
                                                              data[index].id!);
                                                        }
                                                      },
                                              ),
                                              const Text('Mark Nominee'),
                                            ],
                                          ),
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
                          height: 100,
                        ),
                        PrimaryButton(
                            onPressed: (){_addNewMember(context);}, text: 'Add new member'),
                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }
}
