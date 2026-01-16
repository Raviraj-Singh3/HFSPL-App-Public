import 'package:HFSPL/Layouts/show_message.dart';
import 'package:flutter/material.dart';
import 'package:HFSPL/network/responses/cgt/cgt_model.dart';
import 'package:HFSPL/group_training/perform_group_training_day_1_3.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:HFSPL/utils/globals.dart';

class GroupSchedule extends StatefulWidget {
  const GroupSchedule({super.key});

  @override
  State<GroupSchedule> createState() => _GroupScheduleState();
}

class _GroupScheduleState extends State<GroupSchedule> {
  final DioClient _client = DioClient();
  List<CGTModel> CGTResponseList = [];
  int day = 0;
  bool isLoading = true;
  // Fetch groups
  fetch() async {
    try {

      var response = await _client.getCGT(Global_uid);
      
      setState(() {
        CGTResponseList = response;
      });

    } catch (e) {
      if (!mounted) return;
      showMessage(context, "Error fetching data: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // if (CGTResponseList[0]. == 0) {
    //   day=1;
    // }
    // else if (widget.cgtGroup.status == 2) {
    //   day=2;
    // }
    // else if (widget.cgtGroup.status == 4) {
    //   day=3;
    // }
    fetch();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Schedule')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (CGTResponseList.isEmpty) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Schedule')),
      body: const Center(child: Text('Data not available')),
    );
  }

    return Scaffold(
      appBar: AppBar(title: const Text("Group Schedule"),),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                    itemCount: CGTResponseList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CGTResponseList[index].group!,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Status: ${CGTResponseList[index].status == 0 ? 'Day 1 Assigned' : (CGTResponseList[index].status == 2 ? 'Day 2 Assigned' : (CGTResponseList[index].status == 4 ? 'Day 3 Assigned' : 'PreGRT Assigned'))}')
                                ],
                              ),
                            ),
                            CGTResponseList[index].status! <= 4 ? ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PerformGroupTrainingDay1To3(
                                                  cgtGroup: CGTResponseList[
                                                    index]))).then((onValue)=> setState(() {
                                                            //refresh the page
                                                            fetch();
                                                          }));
                                },
                                child: const Text("Continue")): const Text(""),
                          ],
                        ),
                      );
                    },
              padding: EdgeInsets.only(bottom: 80),
                  ),

          ),
        ],
      ),
    );
  }
}
