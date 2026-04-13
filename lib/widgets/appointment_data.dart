import 'package:flutter/material.dart';

class AppointmentData {
  final String id;
  final String doctorName;
  final String specialty;
  final String healthpostName;
  final String? doctorAvatarUrl;
  final DateTime scheduledAt;
  final String status;
  final String consultationType;

  const AppointmentData({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.healthpostName,
    this.doctorAvatarUrl,
    required this.scheduledAt,
    required this.status,
    required this.consultationType,
  });

  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) && status == 'confirmed' ||
      status == 'pending';

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  String get initials {
    final parts = doctorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'D';
  }

  String get formattedTime {
    final h = scheduledAt.hour % 12 == 0 ? 12 : scheduledAt.hour % 12;
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    final ap = scheduledAt.hour < 12 ? 'बिहान' : 'दिउँसो';
    return '$ap $h:$m';
  }

  String get formattedDate {
    const months = [
      'जनवरी',
      'फेब्रुअरी',
      'मार्च',
      'अप्रिल',
      'मे',
      'जुन',
      'जुलाई',
      'अगस्ट',
      'सेप्टेम्बर',
      'अक्टोबर',
      'नोभेम्बर',
      'डिसेम्बर',
    ];
    if (isToday) return 'आज, $formattedTime';
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}';
  }

  Color get statusColor {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF1565C0);
      case 'pending':
        return const Color(0xFFE65100);
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return const Color(0xFF757575);
      case 'no_show':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF546E7A);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'पुष्टि';
      case 'pending':
        return 'पर्खाइ';
      case 'completed':
        return 'सम्पन्न';
      case 'cancelled':
        return 'रद्द';
      case 'no_show':
        return 'गैरहाजिर';
      default:
        return status;
    }
  }

  IconData get consultIcon {
    switch (consultationType) {
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.phone_rounded;
      default:
        return Icons.chat_rounded;
    }
  }
}

class Stats {
  final int total;
  final int thisMonth;
  final int pending;
  const Stats({
    required this.total,
    required this.thisMonth,
    required this.pending,
  });
}
