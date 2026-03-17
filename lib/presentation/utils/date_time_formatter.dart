import 'package:superdriver/l10n/app_localizations.dart';

class DateTimeFormatter {
  static String formatTimeAmPm(DateTime value, AppLocalizations l10n) {
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? l10n.pm : l10n.am;
    return '$hour12:$minute $period';
  }

  static String formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String formatDayMonth(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  static String formatDateTimeAmPm(DateTime value, AppLocalizations l10n) {
    return '${formatDate(value)} - ${formatTimeAmPm(value, l10n)}';
  }

  static String formatDateTimeWithTodayLabel(
    DateTime value,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(value.year, value.month, value.day);

    if (target == today) {
      return '${l10n.today} - ${formatTimeAmPm(value, l10n)}';
    }
    if (target == yesterday) {
      return '${l10n.yesterday} - ${formatTimeAmPm(value, l10n)}';
    }
    return formatDateTimeAmPm(value, l10n);
  }

  static String formatRelative(DateTime value, AppLocalizations l10n) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return l10n.today;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return formatDate(value);
  }
}
