import 'package:intl/intl.dart';

String returnDateFormat(String date) {
    if(date.isEmpty){
      date = "00:01 01/01/1999";
    }

    final utcDateTime = DateTime.parse(date);
    final localDateTime = utcDateTime.toLocal();
    final formattedDate = DateFormat('HH:mm • dd MMM yy').format(localDateTime);
    return formattedDate;
  }