import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/network/requests/post_audit_request.dart';
import 'package:HFSPL/network/responses/AuditModel/audit_category_model.dart';

class AuditQuestion extends StatefulWidget {
  final List<Question> questionList;
  final int? subCategoryId;
  const AuditQuestion({super.key, required this.questionList, this.subCategoryId});

  @override
  State<AuditQuestion> createState() => _AuditQuestionState();
}

class _AuditQuestionState extends State<AuditQuestion> {
  List<String?> selectedAnswers = [];
  List<TextEditingController> commentControllers = [];
  final DioClient _client = DioClient();

  @override
  void initState() {
    super.initState();
    selectedAnswers = List<String?>.filled(widget.questionList.length, null);
    commentControllers =
        List.generate(widget.questionList.length, (_) => TextEditingController());
  }

  _submit(data) async {
    try {
      var response = await _client.postAudit(data);
      print(response);
    } catch (e) {
      print("error: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questions"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.questionList.length + 1, // Add 1 for the button
          itemBuilder: (context, index) {
            if (index == widget.questionList.length) {
              // Last item: Add the button
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: FilledButton(
                  onPressed: () {
                    // Perform desired action here
                  //   var question = QuestionRequest(
                  //     auditSnapshotItemId: 1,
                  //     comment: 'done',
                  //     questionId: 
                  //   );
                  //  var data = RequestPostAudit(
                  //   branchId: 1,
                  //   feid: 25,
                  //   snapshotId: 1,
                  //   groupId: 4053,
                  //   questionSubCategoryId: widget.subCategoryId,
                  //   questions: 
                  //  );
                  //  var json = jsonEncode(data);
                    debugPrint("Submit button pressed ${json}");
                    // print("subCategoryId ${}");
                    _submit(json);
                  },
                  child: const Text("Submit"),
                ),
              );
            }

            // Regular question card
            final question = widget.questionList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ${question.question}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: "Yes",
                            groupValue: selectedAnswers[index],
                            title: const Text("Yes"),
                            onChanged: (value) {
                              setState(() {
                                selectedAnswers[index] = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: "No",
                            groupValue: selectedAnswers[index],
                            title: const Text("No"),
                            onChanged: (value) {
                              setState(() {
                                selectedAnswers[index] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentControllers[index],
                      decoration: InputDecoration(
                        labelText: "Add Comment",
                        hintText: "Type your comment here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // maxLines: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
