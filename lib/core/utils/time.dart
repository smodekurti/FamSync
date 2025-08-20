import 'package:intl/intl.dart';

String formatRelativeTime(DateTime dateTime, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(dateTime);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d, h:mm a').format(dateTime);
}

String formatDate(DateTime dateTime) {
  return DateFormat('MMM d, yyyy').format(dateTime);
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
}

String formatHeaderDate(DateTime dateTime) {
  return DateFormat('EEEE, MMM d').format(dateTime);
}
