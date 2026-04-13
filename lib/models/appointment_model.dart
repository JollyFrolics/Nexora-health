



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Appt {
  final String id;
  final String doctorName;
  final String specialty;
  final String healthpostName;
  final String? avatarUrl; // null when no valid URL exists
  final DateTime scheduledAt;
  final String status;
  final String consultType; // 'video' | 'audio' | 'chat' | 'physical'
  final String? patientNotes;
  final int? doctorId;

  const Appt({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.healthpostName,
    this.avatarUrl,
    required this.scheduledAt,
    required this.status,
    required this.consultType,
    this.patientNotes,
    this.doctorId,
  });

  factory Appt.fromApi(Map<String, dynamic> row) {
    final name = _resolveDoctorName(row);

    final rawAvatar = _resolveAvatarUrl(row);
    final safeAvatar = _isValidUrl(rawAvatar) ? rawAvatar : null;

    final specialty = _str(row, ['specialty', 'doctor_specialty']);
    final healthpost = _str(row, [
      'healthpost_name',
      'doctor_healthpost',
      'health_post_name',
    ]);

    final rawType = _str(row, ['consultation_type', 'consult_type', 'type']);
    final consultType = _normaliseConsultType(rawType);

    DateTime scheduledAt;
    try {
      scheduledAt = DateTime.parse(row['scheduled_at'].toString()).toLocal();
    } catch (_) {
      scheduledAt = DateTime.now();
    }

    return Appt(
      id: row['id']?.toString() ?? '',
      doctorName: name,
      specialty: specialty,
      healthpostName: healthpost,
      avatarUrl: safeAvatar,
      scheduledAt: scheduledAt,
      status: row['status']?.toString() ?? 'pending',
      consultType: consultType,
      patientNotes:
          row['patient_notes']?.toString() ?? row['notes']?.toString(),
      doctorId: int.tryParse(row['doctor_id']?.toString() ?? ''),
    );
  }

  static String _resolveDoctorName(Map<String, dynamic> row) {
    // 1. Flat keys the API sometimes returns directly on the appointment
    for (final key in ['doctor_name', 'full_name', 'doctor_full_name']) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }

    // 2. Nested doctor object  → profile sub-object
    final doctor = row['doctor'];
    if (doctor is Map<String, dynamic>) {
      // Try profile sub-object first
      final profile = doctor['profile'];
      if (profile is Map<String, dynamic>) {
        for (final key in ['full_name', 'name']) {
          final v = profile[key]?.toString().trim();
          if (v != null && v.isNotEmpty && v != 'null') return v;
        }
      }
      // Try flat keys on doctor map
      for (final key in ['full_name', 'name', 'doctor_name']) {
        final v = doctor[key]?.toString().trim();
        if (v != null && v.isNotEmpty && v != 'null') return v;
      }
    }

    // 3. Nested profile object at top level
    final profile = row['profile'];
    if (profile is Map<String, dynamic>) {
      for (final key in ['full_name', 'name']) {
        final v = profile[key]?.toString().trim();
        if (v != null && v.isNotEmpty && v != 'null') return v;
      }
    }

    return 'डाक्टर';
  }

  static String? _resolveAvatarUrl(Map<String, dynamic> row) {
    // Flat keys
    for (final key in [
      'avatar_url',
      'doctor_avatar',
      'doctor_avatar_url',
      'profile_picture',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final doctor = row['doctor'];
    if (doctor is Map<String, dynamic>) {
      final profile = doctor['profile'];
      if (profile is Map<String, dynamic>) {
        final v = profile['avatar_url']?.toString().trim();
        if (v != null && v.isNotEmpty && v != 'null') return v;
      }
      final v = doctor['avatar_url']?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final profile = row['profile'];
    if (profile is Map<String, dynamic>) {
      final v = profile['avatar_url']?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    return null;
  }

  static String _str(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    return '';
  }

  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static String _normaliseConsultType(String raw) {
    switch (raw.toLowerCase()) {
      case 'video':
        return 'video';
      case 'audio':
      case 'phone':
      case 'call':
        return 'audio';
      case 'chat':
      case 'message':
      case 'text':
        return 'chat';
      default:
        return 'physical';
    }
  }

  String get initials {
    final pts = doctorName.trim().split(' ');
    if (pts.length >= 2) {
      return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    }
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day + 1);
    return status == 'confirmed' && scheduledAt.isAfter(todayEnd);
  }

  bool get isPending => status == 'pending';

  String get dateLabel =>
      DateFormat('yyyy MMMM dd, EEEE', 'ne').format(scheduledAt);

  String get timeLabel => DateFormat('hh:mm a').format(scheduledAt);

  String get dateTimeLabel => DateFormat('MMM d, hh:mm a').format(scheduledAt);

  Color get statusColor {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'no_show':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusNe {
    switch (status) {
      case 'confirmed':
        return 'पुष्टि भयो';
      case 'pending':
        return 'पर्खाइमा';
      case 'completed':
        return 'सम्पन्न';
      case 'cancelled':
        return 'रद्द';
      case 'no_show':
        return 'अनुपस्थित';
      default:
        return status;
    }
  }
}
