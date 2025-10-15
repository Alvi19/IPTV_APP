import 'package:intl/intl.dart';

class DateTimeUtil {
  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm').format(now);
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('EEE, dd MMM yyyy').format(now);
  }
}
