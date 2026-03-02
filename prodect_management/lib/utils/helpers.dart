import 'package:intl/intl.dart';

String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}