import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:HFSPL/Layouts/show_message.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_audit_request.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_members_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_saved_model.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_snapshots_model.dart';
import 'package:HFSPL/network/responses/AuditModel/fe_model.dart';
import 'package:HFSPL/network/responses/AuditModel/groups_model.dart';
import 'package:HFSPL/utils/globals.dart';

class AuditProcess extends StatefulWidget {
  final AuditSnapshotModel snapshot;
  const AuditProcess({super.key, required this.snapshot});
  @override
  _AuditProcessState createState() => _AuditProcessState();
}

class _AuditProcessState extends State<AuditProcess> {
  final DioClient _client = DioClient();

  List<AuditCategoryModel> auditCategories = [];
  List<QuestionSubCategory> subcategories = [];
  List<ActiveFeModel> feList = [];
  List<ActiveGroupsModel> groupList = [];
  List<AuditMembersModel> membersList = [];

  List<SavedAuditResponseModel> savedAnswers = [];

  AuditCategoryModel? selectedCategory;
  QuestionSubCategory? selectedSubCategory;
  ActiveFeModel? selectedFe;
  ActiveGroupsModel? selectedGroup;
  AuditMembersModel? selecttedMember;
  List<QuestionRequest> selectQuestionOptions = [];

  String? selectedCategoryName;
  String? selectedSubCategoryName;
  String? selectedFeName;
  String? selectedGroupName;
  String? selecttedMemberName;

  Map<int, String?> selectedOptions = {};
  final List<TextEditingController> _controllers = [];

  RequestPostAudit requestPostAudit = RequestPostAudit();

  List imageList = [];

  @override
  void initState() {
    super.initState();
    _getAuditCategories();
    _getFe();
    // Future.delayed(Duration(milliseconds: 2000),
    //   () => _selectCategory(),
    // );
    
  }

  void initializeQuestionData() {
 // if (_controllers.isEmpty && selectedSubCategory != null) {
    print("_controllers.isEmpty && selectedSubCategory if empty response ");
    _controllers.clear();
    _controllers.addAll(
      List.generate(
        selectedSubCategory!.questions!.length,
        (_) => TextEditingController(),
      ),
    );
  // }

  // if (selectQuestionOptions.isEmpty && selectedSubCategory != null) {
  //   print("selectQuestionOptions.isEmpty && selectedSubCategory  if empty response ");
    // selectQuestionOptions = List.generate(
    //   selectedSubCategory!.questions!.length,
    //   (index) => QuestionRequest(
    //     questionId: selectedSubCategory!.questions![index].questionId,
    //     auditSnapshotItemId: widget.snapshot.auditSnapshotId,
    //     comment: "",
    //     customValue: "",
    //     imageValidation: false
    //   ),
    // );
  // }
}
  @override
  void dispose() {
    // TODO: implement dispose
    for (TextEditingController c in _controllers) {       c.dispose();     }
    super.dispose();
  }

  _loadSavedAudit() async {
    context.loaderOverlay.show();
      
    initializeQuestionData();

    for (TextEditingController c in _controllers) {       c.text = '';   }
    for (var savedoption in savedAnswers) {       savedoption.answerId = null;   }

     requestPostAudit = RequestPostAudit();
     requestPostAudit.snapshotId = widget.snapshot.auditSnapshotId;
     requestPostAudit.questionSubCategoryId = selectedSubCategory?.subCategoryId;
     requestPostAudit.branchId = widget.snapshot.branchId;
     requestPostAudit.feid = selectedFe?.feId;
     requestPostAudit.centerId = 0;
      requestPostAudit.groupId = selectedGroup?.groupId;
      requestPostAudit.clientId = selecttedMember?.clientId;
      requestPostAudit.questions = selectQuestionOptions;

    try {

      var response = await _client.getAuditSavedData(requestPostAudit);
      selectQuestionOptions.clear();
      
      selectedSubCategory?.questions?.forEach(
        (it){
          it.savedComment="";
          it.savedAnswer="";
          it.savedAnswerId=0;
        } 
      );
      // print("saved ${savedAnswers.length}");
      setState(() {
          savedAnswers = response;
          });
      print("saved ${savedAnswers.length}");
          print("controller ${_controllers.length}");

      if(savedAnswers.isNotEmpty){

        for (var i = 0; i < savedAnswers.length; i++) {
            _controllers[i].text = savedAnswers[i].comment ?? "";
            
          }
      }
      else{
        savedAnswers = List.generate(
        selectedSubCategory!.questions!.length,
        (index) => SavedAuditResponseModel(answerId: null, answer: "", auditSnapshotItemId: null, auditSnapshotModuleId: null, comment: "", customValue: "", questionId: null),
      );
      // setState(() {
        
      // });
      }
    } catch (e) {
      print("error $e");
    }
    context.loaderOverlay.hide();
  }

_submitAudit() async {
  context.loaderOverlay.show();

  selectQuestionOptions = List.generate(
      selectedSubCategory!.questions!.length,
      (index) => QuestionRequest(
        questionId: selectedSubCategory!.questions![index].questionId,
        auditSnapshotItemId: widget.snapshot.auditSnapshotId,
        comment: "",
        customValue: "",
        imageValidation: false
      ),
    );

  for(var i=0; i<savedAnswers.length; i++){
    selectQuestionOptions[i].selectedAnswerId = savedAnswers[i].answerId;
    selectQuestionOptions[i].comment = savedAnswers[i].comment;
    selectQuestionOptions[i].customValue = "";
    if(savedAnswers[i].answerId == null){
      showMessage(context, "Please complete all the options");
      return;
    }
  }
      requestPostAudit = RequestPostAudit(
    snapshotId: widget.snapshot.auditSnapshotId,
    questionSubCategoryId: selectedSubCategory?.subCategoryId,
    branchId: widget.snapshot.branchId,
    feid: selectedFe?.feId,
    centerId: 0,
    groupId: selectedGroup?.groupId,
    clientId: selecttedMember?.clientId,
    questions: selectQuestionOptions,
    comment: "",
    customValue: ""
  );

    try {
      var response = await _client.postAudit(jsonEncode(requestPostAudit));
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("$response")),
    );
    Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Error: $e")),
    );

    }
    context.loaderOverlay.hide();
}
  

  void _selectCategory() async {
    setState(() {
        selectedCategory = null;
        selectedSubCategory = null;
        selectedFe = null;
        selectedGroup = null;
        selecttedMember = null;
        // selectQuestionOptions = [];
        
      });
      askCategory();
   
  }
  askCategory()async {
     var category = await _showSelectionDialog(auditCategories, "Select Category");
    if (category != null) {
      setState(() {
        selectedCategory = category;
        selectedCategoryName = category.category.isEmpty? "No Name" : category.category ;
        // selectedSubCategory = null;
        // selectedFe = null;
        // selectedGroup = null;
        // selecttedMember = null;
      });
      _selectSubCategory();
    }
  }

  void _selectSubCategory() async {
    setState(() {
      selectedSubCategory = null;
        selectedFe = null;
        selectedGroup = null;
        selecttedMember = null;
          savedAnswers = [];

        // selectQuestionOptions = [];
    });
    askSubCategory();
    
  }
  askSubCategory()async {
    var subCategory = await _showSelectionDialog(selectedCategory!.questionSubCategories!, "Select Sub-Category");
    if (subCategory != null) {
      setState(() {
        selectedSubCategory = subCategory;
        selectedSubCategoryName = subCategory.subCategory;
      });
      _decideAfterSubcategory();
      
    }
  }

  void _decideAfterSubcategory([String param = ""]) async {

    switch (selectedCategory?.module) {
      case "FE":
        await _askSelectFe();
        _loadSavedAudit();
        break;
      case "GM":
        if(param.isEmpty){
          await _askSelectFe();
          await _changeGroup(selectedFe?.feId);
          _loadSavedAudit();
        }
        else if(param == "CG"){
          await _changeGroup(selectedFe?.feId);
          _loadSavedAudit();
        }
        break;
      case "CV":
        if(param.isEmpty){
          await _askSelectFe();
          await _changeGroup(selectedFe?.feId);
          await _changemember(selectedGroup?.groupId);
          _loadSavedAudit();
        }
        else if(param == "CG"){
          await _changeGroup(selectedFe?.feId);
        }
        else if(param == "CC"){
          await _changemember(selectedGroup?.groupId);
          _loadSavedAudit();
        }
        break;
      case "CGT":
        if(param.isEmpty){
         await _askSelectFe();
          await _changeGroup(selectedFe?.feId);

          _loadSavedAudit();
        }
        else if(param == "CG"){
           await _changeGroup(selectedFe?.feId);
           _loadSavedAudit();
        }
        break;
      case "GRT":
        if(param.isEmpty){
         await _askSelectFe();
          await _changeGroup(selectedFe?.feId);
          _loadSavedAudit();
        }
        else if(param == "CG"){
           await _changeGroup(selectedFe?.feId);
           _loadSavedAudit();
        }
        break;
      default:
      print("default ");
      _loadSavedAudit();
      break;
    }
  }

  _selectFe() async {
    
    setState(() {
      
      selectedFe = null;
        selectedGroup = null;
        selecttedMember = null;
        
    });
    _decideAfterSubcategory();
  
 }
 _askSelectFe()async{
  var fe = await _showSelectionDialog(feList, "Select FE");
  if (fe != null) {
      setState(() {
        selectedFe = fe;
        selectedFeName = fe.feName;
      });
    }
 }

  _selectGroup() async {

    setState(() {
      selectedGroup = null;
      selecttedMember = null;
    });
    _decideAfterSubcategory("CG");
    
  }

  _changeGroup(feId)async {
    if(feId == null){
      return;
    }
    await _getGroups(feId);
    var group = await _showSelectionDialog(groupList, "Select Group");
    if (group != null) {
      setState(() {
        selectedGroup = group;
        selectedGroupName = group.groupName;
      });
      // _selectMember(selectedGroup?.groupId);
    }
  }

   _selectMember() async {

    setState(() {
      selecttedMember = null;
    });
    _decideAfterSubcategory("CC");
    
  }

  _changemember(groupId) async {
    await _getMembers(groupId);
    if(membersList.isEmpty){
      selecttedMemberName = "No Data";
      return;
    }
    var member = await _showSelectionDialog(membersList, "Select Member");
    if (member != null) {
      setState(() {
        selecttedMember = member;
        selecttedMemberName = member.clientName;
      });
    }
  }

  Future _showSelectionDialog<T>(List<T> items, String title) async {
    
    if(items.isEmpty){
      print("in dialog");
      return;
    }
  else { return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: items
                .map((item) {
                  // Cast the item to the specific type for accessing fields
                  if (item is AuditCategoryModel) {
                    return ListTile(
                      title: Text(item.category!.isEmpty ? "No Name" : item.category ?? "No"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  } else if (item is QuestionSubCategory) {
                    return ListTile(
                      title: Text(item.subCategory ?? "Unknown"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                  else if (item is ActiveGroupsModel) {
                    return ListTile(
                      title: Text(item.groupName ?? "Unknown"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                  else if (item is ActiveFeModel) {
                    return ListTile(
                      title: Text(item.feName ?? "Unknown"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                  else if (item is AuditMembersModel) {
                    return ListTile(
                      title: Text(item.clientName ?? "Unknown"),
                      onTap: () => Navigator.pop(context, item),
                    );
                  }
                   else {
                    return ListTile(
                      title: Text("Unsupported item"),
                      onTap: () => Navigator.pop(context, null),
                    );
                  }
                })
                .toList(), // Ensures it returns List<Widget>
          ),
        ),
      );
    },
  );
  }
}



  _getFe()async {
    try {
      var response = await _client.getAllActiveFe(widget.snapshot.branchId!);
      setState(() {
        feList = response;
      });
      print("fe $feList");
    } catch (e) {
      showMessage(context, '$e');
    }
  }

  _getGroups(int feId)async {
    try {
      var response = await _client.getAllActiveGroups(feId);
      setState(() {
        groupList = response;
      });
    } catch (e) {
      showMessage(context, '$e');
    }
  }

  _getDisbGroups(int feId)async {
    try {
      var response = await _client.getDisbGroups(feId);
      setState(() {
        groupList = response;
      });
    } catch (e) {
      showMessage(context, '$e');
    }
  }

  _getMembers(int groupId)async {
    try {
      var response = await _client.getAllActiveMembers(groupId);
      setState(() {
        membersList = response;
      });
    } catch (e) {
      showMessage(context, '$e');
    }
  }

  Future<void> _getAuditCategories() async {
    context.loaderOverlay.show();
    try {
      final data = await _client.getAuditCategories(Global_uid);
      setState(() {
        auditCategories = data;
      });
      askCategory();
    } catch (e) {
      print("Error fetching categories: $e");
    }
    context.loaderOverlay.hide();
  }

  void _onCategoryChanged(int? categoryId) {
    setState(() {
      // selectedCategoryId = categoryId;
      // subcategories = auditCategories
      //     .firstWhere((cat) => cat.categoryId == categoryId)
      //     .questionSubCategories ?? [];
      // selectedSubcategoryId = null;
      // selectedFe = null;
      // selectedGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
   // // initializeQuestionData();
    return Scaffold(
      appBar: AppBar(title: const Text("Audit Process")),
      body: SingleChildScrollView(
        child: Padding(
          // padding: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.only(bottom: 80.0, left: 16, right: 16, top: 16),
          child: Column(
            children: [
              TextButton(
                onPressed: () => _selectCategory(),
                child: Text(
                  selectedCategoryName ?? "Select Audit Category",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => _selectSubCategory(),
                child: Text(
                  selectedSubCategoryName ?? "Select Audit Sub-Category",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
                if(selectedCategory?.module == "FE")
                  feList.isNotEmpty ?
                      TextButton(
                        onPressed: () => _selectFe(),
                        child: Text(
                        selectedFeName ?? "Select FE",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                      : Text("No Data")
                      ,
                if(selectedCategory?.module == "GM" || selectedCategory?.module == "CGT" || selectedCategory?.module == "GRT" )
                Column(
                  children: [
                      TextButton(
                        onPressed: () => _selectFe(),
                        child: Text(
                        selectedFeName ?? "Select FE",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectGroup(),
                        child: Text(
                        selectedGroupName ?? "Select Group",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
        
                if(selectedCategory?.module == "CV")
                Column(
                  children: [
                      TextButton(
                        onPressed: () => _selectFe(),
                        child: Text(
                        selectedFeName ?? "Select FE",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectGroup(),
                        child: Text(
                        selectedGroupName ?? "Select Group",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectMember(),
                        child: Text(
                        selecttedMemberName ?? "Select Member",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              if(selectedSubCategory != null)
               SizedBox(
                // height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  itemCount: selectedSubCategory?.questions?.length ?? 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // if (index >= (selectQuestionOptions.length) || index >= (_controllers.length)) {
                    // return SizedBox.shrink(); // Safeguard against out-of-bound indices
                    // }
                    final question = selectedSubCategory!.questions![index];
                    // final questionRequest = selectQuestionOptions[index];
                    // _controllers[index].text = savedAnswers[index].comment ?? "";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. ${question.question}"),
                        if(savedAnswers.isNotEmpty)
                        Column(
                          children: [
                            DropdownButton<int>(
                          value: savedAnswers[index].answerId ,
                          hint: Text("Select"),
                          onChanged: (value) {
                            setState(() {
                              savedAnswers[index].answerId = value!;
                            });
                          },
                          items: question.answers!.map((answer) {
                            return DropdownMenuItem<int>(
                              value: answer.id,
                              child: Text(answer.option!),
                            );
                          }).toList(),
                        ),
                        TextField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            labelText: "Comment",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            savedAnswers[index].comment = value;
                          },
                        ),
                          ],
                        )
                        else SizedBox(),
                        SizedBox(height: 10,)
                      ],
                    );
                  },
                )
              ),
              SizedBox(
                height: 20,
              ),
              FilledButton(onPressed: (){
                _submitAudit();
              }, child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
    
  }
  Widget questionDropdown(Question question, QuestionRequest questionRequest) {
  return DropdownButton<String>(
    value: questionRequest.selectedAnswerId?.toString(),
    hint: Text("Select"),
    onChanged: (value) {
      setState(() {
        questionRequest.selectedAnswerId = int.parse(value!);
      });
    },
    items: question.answers!.map((answer) {
      return DropdownMenuItem<String>(
        value: answer.id.toString(),
        child: Text(answer.option!),
      );
    }).toList(),
  );
}

}

