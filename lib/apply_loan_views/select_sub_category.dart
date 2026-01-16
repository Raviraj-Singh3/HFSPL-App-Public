import 'package:HFSPL/apply_loan_views/PaySprint/payspirnt.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/apply_loan_views/adhar_verification.dart';
import '../custom_views/app_button_secondary.dart';
import '../network/networkcalls.dart';
import '../network/responses/kyc/kyc_additional_members.dart';
import '../network/responses/kyc/kyc_category_response.dart';
import '../network/responses/kyc/kyc_sub_category_response.dart';
import 'questions_page.dart';


class SelectSubCategory extends StatefulWidget {
  final KycCategory selectedCat;
  final KycAdditionalMember? selectedMember;
  final int snapshotid;
  const SelectSubCategory(
      {Key? key, required this.selectedCat, this.selectedMember, required this.snapshotid})
      : super(key: key);

  @override
  SelectSubCategoryState createState() => SelectSubCategoryState();
}

class SelectSubCategoryState extends State<SelectSubCategory> {
  List<KycSubCategory> data = [];
  bool isLoading = true;
  final DioClient _client = DioClient();
  

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  

  void fetchData() async {
    try {
      var d = await _client.getKycSubCategories(widget.selectedCat.id!);
      setState(() {
        data = d.where((element) => element.name != 'DDE DETAILS').toList();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  onSubCategoryPressed(dynamic value) {
    KycSubCategory selectedSubCat = value as KycSubCategory;
    // print("pressed");
    // print("widet seleted ${widget.selectedCat.name}");
    // print(" seleted ${selectedSubCat.name}");
    // print("widet member ${widget.selectedMember?.name}");
    openQuestionsPage(
        widget.selectedCat, selectedSubCat, widget.selectedMember);
    // Navigator.pop(context, selectedSubCat);
  }

  void openQuestionsPage(KycCategory selectedCat, KycSubCategory selectedSubCat,
      KycAdditionalMember? additionalMember) async {
    // open questions page

    // print("subCat: ${selectedSubCat.id}");

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => 
            (selectedSubCat.id == 4 && selectedSubCat.name != 'Other DETAILS') || selectedSubCat.id == 1 ? 
            AadhaarVerificationPage(selectedCat: selectedCat, selectedSubCat: selectedSubCat, selectedMember: additionalMember,snapshotId: widget.snapshotid)
             : 
             QuestionnsPage(
                selectedCat: selectedCat,
                selectedSubCat: selectedSubCat,
                selectedMember: additionalMember,
                snapshotId: widget.snapshotid,
                skipValidation: true,
              )
              ),
      //testing-->
      // MaterialPageRoute(
      //     builder: (context) => QuestionnsPage(
      //            selectedCat: selectedCat,
      //            selectedSubCat: selectedSubCat,
      //            selectedMember: additionalMember,
      //            snapshotId: widget.snapshotid
      //          )
      // ),
      //<--testing
    );
    // if (result != null) {
    //   // setState(() {
    //   // memberName = result;
        
    //   // });
    //   fetchData();
    // }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Sub Categories")),
        body: Container(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      widget.selectedMember == null
                          ? const Text(
                              'Self',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            )
                          : Text(
                              'Selected member: ${widget.selectedMember!.name!}',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
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
                        height: 30,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                 data[index].name!,
                                                style: const TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                                 ),
                                                // if(data[index].id == 4)
                                                //  Obx(() => memberController.memberName.value?.isNotEmpty == true 
                                                //       ? Text(memberController.memberName.value!, style: TextStyle(fontSize: 16),) 
                                                //       : SizedBox())
                                            ],
                                          ),
                                        ),
                                        
                                        //  if(data[index].id == 4)
                                        // Obx(() => memberController.memberName.value != null ? Text("FILLED",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700, fontStyle: FontStyle.italic),)
                                        //   : 
                                          AppButtonSecondary(
                                          onPressed: onSubCategoryPressed,
                                          text: 'Fill',
                                          valueToPassBack: data[index],
                                                                                  ),
                                        // )
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
                        height: 30,
                      ),
                    ],
                    
                  ),
                ),
        ));
  }
}
