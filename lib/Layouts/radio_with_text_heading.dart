
import 'package:flutter/material.dart';

class RadioWithTextHeading extends StatefulWidget {
  final String heading;
  final String radioTitle1;
  final String radioTitle2;
  bool? groupValue;
  final Function(bool?) onChanged;
  final String? row1Title;
  final String? row1Data;
  final String? row2Title;
  final String? row2Data;
   RadioWithTextHeading(
    {super.key, required this.heading, 
    required this.radioTitle1, 
    required this.radioTitle2, 
    required this.groupValue, 
    required this.onChanged, 
     this.row1Title,
     this.row1Data,
     this.row2Title,
     this.row2Data,
             
    });

  @override
  State<RadioWithTextHeading> createState() => _RadioWithTextHeadingState();
}

class _RadioWithTextHeadingState extends State<RadioWithTextHeading> {
  @override
  Widget build(BuildContext context) {
    return Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green.shade700),
                                
                              ),
                              child: Column(
                              children: [
                                Text(widget.heading,style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                               
                              widget.row1Title != null 
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.row1Title!, style: const TextStyle(fontSize: 16)),
                                    Text(widget.row1Data ?? "", style: const TextStyle(fontSize: 16)),
                                  ],
                                )
                              : const SizedBox.shrink(),

                              widget.row2Title != null 
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.row2Title!, style: const TextStyle(fontSize: 16)),
                                    Text(widget.row2Data ?? "", style: const TextStyle(fontSize: 16)),

                                  ],
                                )
                              : const SizedBox.shrink(),
                                
                                RadioListTile(
                                  title: Text(widget.radioTitle1),
                                  value: true,
                                  groupValue: widget.groupValue,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      widget.groupValue = value!;
                                    });
                                    widget.onChanged(value);
                                  },
                                ),
                                RadioListTile(
                                  title: Text(widget.radioTitle2),
                                  value: false,
                                  groupValue: widget.groupValue,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      widget.groupValue = value!;
                                    });
                                    widget.onChanged(value);
                                  },
                                ),
                              ],
                            )
                            );
  }
}