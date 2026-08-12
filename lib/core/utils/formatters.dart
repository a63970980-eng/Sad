import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String date(DateTime d, String locale) =>
      DateFormat('d MMM yyyy', locale).format(d);

  static String dateTime(DateTime d, String locale) =>
      DateFormat('d MMM yyyy • h:mm a', locale).format(d);

  static String relative(DateTime d, String locale) {
    final diff = DateTime.now().difference(d);
    final isAr = locale.startsWith('ar');
    if (diff.inMinutes < 1) return isAr ? 'الآن' : 'just now';
    if (diff.inMinutes < 60) {
      return isAr ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return isAr ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return isAr ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
    }
    return date(d, locale);
  }
}
