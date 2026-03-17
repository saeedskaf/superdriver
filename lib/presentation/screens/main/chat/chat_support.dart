import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/utils/date_time_formatter.dart';

class ChatSession {
  final String userId;
  final String userName;
  final String? userPhone;

  const ChatSession({
    required this.userId,
    required this.userName,
    this.userPhone,
  });
}

Future<ChatSession?> loadChatSession(BuildContext context) async {
  final profileState = context.read<ProfileBloc>().state;
  if (profileState is ProfileLoaded) {
    final id = profileState.profileData['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      return ChatSession(
        userId: id,
        userName: profileState.fullName,
        userPhone: profileState.phoneNumber.isEmpty
            ? null
            : profileState.phoneNumber,
      );
    }
  }

  final userData = await secureStorage.getUserData();
  final userId = userData['userId'] ?? '';
  if (userId.isEmpty) return null;

  final userName =
      '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
  final phone = userData['phone'];

  return ChatSession(
    userId: userId,
    userName: userName,
    userPhone: phone is String && phone.isNotEmpty ? phone : null,
  );
}

String formatConversationTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  if (now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day) {
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minutes $period';
  }

  return DateTimeFormatter.formatDayMonth(dateTime);
}

String formatDateSeparator(DateTime date, AppLocalizations l10n) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(messageDay).inDays;

  if (diff == 0) return l10n.chatToday;
  if (diff == 1) return l10n.chatYesterday;

  return DateTimeFormatter.formatDate(date);
}
