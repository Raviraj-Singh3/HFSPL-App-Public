import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/appbar/appbar.dart';

import '../custom_views/app_button.dart';
import '../custom_views/app_button_secondary.dart';
import '../network/networkcalls.dart';
import '../network/responses/kyc/kyc_additional_members.dart';
import '../network/responses/kyc/kyc_category_response.dart';
import '../network/responses/kyc/snapshot_model/snapshot_model.dart';
import '../utils/messages_util.dart';
import 'select_additional_member.dart';
import 'select_sub_category.dart';
import '../state/kyc_state.dart';

class SelectCategory extends StatefulWidget {
  final SnapshotModel snapshotModel;
  const SelectCategory(
      {Key? key, required this.snapshotModel})
      : super(key: key);

  @override
  SelectCategoryState createState() => SelectCategoryState();
}

class SelectCategoryState extends State<SelectCategory> {
  List<KycCategory> data = [];
  bool isLoading = true;
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      var d = KycState().isIndividual
          ? await _client.getKycCategoryIndividual(widget.snapshotModel.id!)
          : await _client.getKycCategory(widget.snapshotModel.id!);
      setState(() {
        data = d;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateStatus() {}

  onCategoryPressed(dynamic value) async {
    KycCategory selectedCat = value as KycCategory;
    
    if (selectedCat.name!.contains('ADDITIONAL MEMBER DETAILS')) {
      // get additional members
      // var additional

      var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectAdditionalMember(
                  selectedCat: selectedCat,
                  snapshotId: widget.snapshotModel.id!,
                )),
      );
      if (result != null) {
        openSelectedSubCat(selectedCat, result);
      }
    } else {
      // continue with selected cat
      openSelectedSubCat(selectedCat, null);
    }
  }

  openSelectedSubCat(
      KycCategory selectedCat, KycAdditionalMember? additionalMember) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectSubCategory(
                selectedCat: selectedCat,
                selectedMember: additionalMember,
                snapshotid: widget.snapshotModel.id!,
              )),
    );
    // if (result != null) {
    //   // open questions
    //   KycSubCategory selectedSubCat = result as KycSubCategory;
    //   openQuestionsPage(selectedCat, selectedSubCat, additionalMember);
    // }
  }

  bool isSubmitting = false;
  _submitCompletion(value) async {
    try {
      setState(() {
        isSubmitting = true;
      });
      var msg = await _client.completeSnapshot(
          widget.snapshotModel.id!);
      showSnackBar(context, msg);
      Navigator.pop(context, true);
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Categories")),
        body: Container(
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
                        'Please select an option below',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      Expanded(
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
                                            child: 
                                          Text(
                                           data[index].name!,
                                          style: const TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ),
                                        AppButtonSecondary(
                                          onPressed: onCategoryPressed,
                                          text: 'Fill',
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
                        height: 100,
                      ),
                      PrimaryButton(
                          isLoading: isSubmitting,
                          onPressed: (){
                            _submitCompletion(context);
                          },
                          text: 'Submit application'),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
        ));
  }
}
