import 'package:flutter/material.dart';

import 'kyc_constants.dart';

class FilledAnswer extends StatelessWidget {
  final String? type;
  final String? filledAnswer;
  const FilledAnswer({Key? key, this.type, this.filledAnswer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filledAnswer == null) {
      return Container();
    }
    if (type == KycConstants.questionTypeText ||
        type == KycConstants.questionTypeNumber ||
        type == KycConstants.questionTypeDate ||
        type == KycConstants.questionTypeSelect) {
      return SizedBox(
            width: 200, // Set the width you want for the Text widget
            child: Text(
              filledAnswer!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.blue),
            ),
          );
    } else if (type == KycConstants.questionTypePhoto) {
      return const Text(
        'Done',
        style: TextStyle(color: Colors.amber),
      );
    }
    else if (type == KycConstants.questionTypePDF) {
      return const Text(
        'Done',
        style: TextStyle(color: Colors.deepOrangeAccent),
      );
    }

    return Container();
  }
}
