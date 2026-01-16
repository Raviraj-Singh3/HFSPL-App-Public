import 'package:flutter/material.dart';
import 'package:HFSPL/Layouts/Button/primary_button.dart';
import 'package:HFSPL/custom_views/app_button.dart';
import 'package:HFSPL/group_training/group_schedule.dart';
import 'package:HFSPL/group_training/assign_schedule.dart';

class GroupTraining extends StatelessWidget {
  const GroupTraining({super.key});

  @override
  Widget build(BuildContext context) {
    void onDay1Click(dynamic valueBack) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupTrainingDay1(),
          ));
    }

    void onGroupSchedule(dynamic valueBack) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupSchedule(),
          ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Training"),),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryButton(
                onPressed: (){
                  onDay1Click(context);
                } , text: 'Assign Group Training Day 1'),
            const SizedBox(
              height: 10,
            ),
            PrimaryButton(
                onPressed: (){
                  onGroupSchedule(context);
                },
                text: 'View Group Training Schedule'),
          ],
        ),
      )),
    );
  }

  // void onDay1Click(dynamic valueBack) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => const GroupTraining(
  //               // isIndividual: true,
  //               )));
  // }
}
