import 'package:flutter/material.dart';

Future<dynamic> pickDate(BuildContext context, DateTime initialDate, DateTime firstDate, DateTime lastDate  ) async {
    // final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      return picked;
    } else {
      return null; // Return the current date if no date is picked
    }
  }