import 'package:flutter/material.dart';

class AttendanceRadio extends StatefulWidget {
  final Function(bool isPresent) onChanged;
  const AttendanceRadio({super.key, required this.onChanged, });

  @override
  State<AttendanceRadio> createState() => _AttendanceRadioState();
}

class _AttendanceRadioState extends State<AttendanceRadio> {
  String _attendance = 'Absent'; // Default selected value

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          title: const Text('Present'),
          // leading: Radio<String>(
            value: 'Present',
            groupValue: _attendance,
            onChanged: (String? value) {
              setState(() {
                _attendance = value!;
                widget.onChanged(true);
              });
            },
          // ),
        ),
        RadioListTile(
          title: const Text('Absent'),
          // leading: Radio<String>(
            value: 'Absent',
            groupValue: _attendance,
            onChanged: (String? value) {
              setState(() {
                _attendance = value!;
                 widget.onChanged(false);
              });
            },
          // ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text('Selected: $_attendance'),
        // ),
      ],
    );
  }
}
