

import 'package:flutter/material.dart';

class RowWithData extends StatelessWidget {
  final String title;
  final String? data;
  final Color? color;
  final FontWeight? fontWeight;

  const RowWithData({
    super.key,
     required this.title, required this.data, this.color, this.fontWeight
  });


  @override
  Widget build(BuildContext context) {
    return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            
    children: [
       Text(title, style: TextStyle(fontSize: 16),),
      // SizedBox(width: 40,),
      Expanded(
        child: Text(
          data ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end, // Align text to the end for better UX
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black,
            fontWeight: fontWeight ?? FontWeight.normal,
          ),
        ),
      ),
    ],
                                );
  }
}