import 'package:intl/intl.dart';

extension DateTimeExtensions on String {
  DateTime convertToDate() {
    return DateTime.parse(this);
    //return DateFormat('dd MMM yyyy').parse(dateString);
  }

  String convertToDateThenString() {
    return formatAsString(DateTime.parse(this));
    //return DateFormat('dd MMM yyyy').parse(dateString);
  }

  String formatAsString(DateTime dateTime) {
    return DateFormat('dd-MMM-yyyy').format(dateTime);
  }
}
