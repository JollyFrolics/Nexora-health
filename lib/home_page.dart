


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:patient_app/widgets/appointment_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_screen.dart';
import 'package:patient_app/emergency_callscreen.dart';
import 'package:patient_app/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supa = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  PatientProfile? _profile;
  AppointmentData? _nextAppointment;
  List<AppointmentData> _recentAppointments = [];
  Stats _stats = const Stats(total: 0, thisMonth: 0, pending: 0);

  List<Map<String, dynamic>> _upcomingRaw = [];
  List<Map<String, dynamic>> _quickDoctors = [];
  String _cancellingId = '';
  bool _loadingDoctors = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadQuickDoctors();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = _supa.auth.currentUser?.id;
      if (uid == null) throw Exception('Not authenticated');


      final results = await Future.wait([
        _supa
            .from('user_profiles')
            .select('full_name, avatar_url')
            .eq('id', uid)
            .maybeSingle(),
        _supa
            .from('appointments')
            .select('id, scheduled_at, status, consultation_type, doctor_id')
            .eq('patient_id', uid)
            .order('scheduled_at', ascending: false)
            .limit(50),
      ]);

      try {
        _upcomingRaw = await ApiService.getUpcomingAppointmentsEnriched();
      } catch (_) {
        _upcomingRaw = [];
      }

      final profileMap = results[0] as Map<String, dynamic>?;
      _profile = PatientProfile(
        id: '',
        userId: uid,
        fullName: profileMap?['full_name']?.toString() ?? 'सदस्य',
        email: '',
        phone: '',
        dateOfBirth: null,
        gender: 'male',
        address: '',
        bloodGroup: '',
        conditions: [],
        avatar: profileMap?['avatar_url']?.toString() ?? '',
      );

      final apptRaw = results[1] as List<dynamic>;
      final doctorIds = apptRaw
          .map((e) => (e as Map<String, dynamic>)['doctor_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> doctorMap = {};
      if (doctorIds.isNotEmpty) {
        try {
          final doctorRows = await _supa
              .from('doctors')
              .select('id, user_id, specialty, healthpost_name')
              .inFilter('id', doctorIds);

          final userIds = (doctorRows as List)
              .map((row) => row['user_id']?.toString())
              .where((id) => id != null && id.isNotEmpty)
              .toSet()
              .toList();

          final profileRows = userIds.isEmpty
              ? <dynamic>[]
              : await _supa
                    .from('user_profiles')
                    .select('id, full_name, avatar_url')
                    .inFilter('id', userIds);
          final profileList = List<Map<String, dynamic>>.from(profileRows);
          final doctorList = List<Map<String, dynamic>>.from(doctorRows);
          final profileLookup = <String, Map<String, dynamic>>{
            for (final row in profileList) row['id'].toString(): row,
          };

          for (final doctor in doctorList) {
            final doctorUserId = doctor['user_id']?.toString() ?? '';
            final doctorProfile = profileLookup[doctorUserId] ?? {};
            final doctorId = doctor['id']?.toString() ?? '';
            if (doctorId.isEmpty) continue;
            doctorMap[doctorId] = {
              'specialty': doctor['specialty']?.toString() ?? '',
              'healthpost_name': doctor['healthpost_name']?.toString() ?? '',
              'full_name': doctorProfile['full_name']?.toString() ?? 'डाक्टर',
              'avatar_url': doctorProfile['avatar_url']?.toString(),
            };
          }
        } catch (_) {}
      }

      final apptList = apptRaw
          .map((e) {
            final m = e as Map<String, dynamic>;
            final did = m['doctor_id']?.toString() ?? '';
            return _parseAppointment(m, doctorMap[did] ?? {});
          })
          .where((a) => a != null)
          .cast<AppointmentData>()
          .toList();

      apptList.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      final now = DateTime.now();
      _nextAppointment = apptList.firstWhereOrNull(
        (a) =>
            a.scheduledAt.isAfter(now) &&
            (a.status == 'confirmed' || a.status == 'pending'),
      );

      _recentAppointments = apptList.take(5).toList();

      final monthStart = DateTime(now.year, now.month, 1);

      final apiPendingCount = _upcomingRaw.length;
      _stats = Stats(
        total: apptList.length,
        thisMonth: apptList
            .where((a) => a.scheduledAt.isAfter(monthStart))
            .length,
        pending: apiPendingCount > 0
            ? apiPendingCount
            : apptList
                  .where(
                    (a) => a.status == 'pending' || a.status == 'confirmed',
                  )
                  .length,
      );

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadQuickDoctors() async {
    setState(() => _loadingDoctors = true);
    try {
      final doctors = await ApiService.fetchDoctors(specialty: '');
      setState(() {
        _quickDoctors = doctors.take(4).toList();
        _loadingDoctors = false;
      });
    } catch (_) {
      setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _cancelAppointment(
    String appointmentId,
    String doctorName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'अपोइन्टमेन्ट रद्द गर्नुहोस्?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'डा. $doctorName सँगको अपोइन्टमेन्ट रद्द गर्न चाहनुहुन्छ?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('नहोस्'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('रद्द गर्नुहोस्'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancellingId = appointmentId);
    try {
      await ApiService.cancelAppointment(appointmentId);
      Get.snackbar(
        'सफल',
        'अपोइन्टमेन्ट रद्द गरियो।',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
      _loadAll();
    } catch (e) {
      Get.snackbar(
        'त्रुटि',
        e.toString(),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
    } finally {
      setState(() => _cancellingId = '');
    }
  }

  AppointmentData? _parseAppointment(
    Map<String, dynamic> m,
    Map<String, dynamic> doctorData,
  ) {
    try {
      return AppointmentData(
        id: m['id']?.toString() ?? '',
        doctorName: doctorData['full_name']?.toString() ?? 'डाक्टर',
        specialty: doctorData['specialty']?.toString() ?? '',
        healthpostName: doctorData['healthpost_name']?.toString() ?? '',
        doctorAvatarUrl: doctorData['avatar_url']?.toString(),
        scheduledAt: DateTime.parse(m['scheduled_at']).toLocal(),
        status: m['status']?.toString() ?? 'pending',
        consultationType: m['consultation_type']?.toString() ?? 'audio',
      );
    } catch (_) {
      return null;
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'शुभ बिहान';
    if (h < 17) return 'शुभ दिउँसो';
    return 'शुभ साँझ';
  }

  String get _firstName {
    final name = _profile?.fullName ?? '';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: _loading
          ? _buildShimmer()
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              color: AppConstants.primaryColor,
              onRefresh: _loadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildGreeting(),
                    const SizedBox(height: 20),
                    _buildActionCards(),
                    const SizedBox(height: 24),
                    _buildNextAppointmentSection(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    
                    if (_upcomingRaw.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildUpcomingApiSection(),
                    ],
                   
                    const SizedBox(height: 24),
                    _buildQuickDoctorsSection(),
                    const SizedBox(height: 24),
                    _buildRecentHeader(),
                    const SizedBox(height: 12),
                    if (_recentAppointments.isEmpty)
                      _buildEmptyRecent()
                    else
                      ..._recentAppointments.map((a) => _buildRecentCard(a)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppConstants.primaryColor,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    title: const Row(
      children: [
        Image(
          image: AssetImage('assets/images/gov_logo.webp'),
          width: 40,
          height: 40,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.nepalSarkar,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppConstants.govtOfNepal,
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () {},
      ),
    ],
  );

  Widget _buildGreeting() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF1A1A1A)),
                children: [
                  TextSpan(
                    text: '$_greeting, $_firstName ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '👋', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
          ),
          if (_profile?.avatar != null && _profile!.avatar.isNotEmpty)
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(_profile!.avatar),
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            )
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
              child: Text(
                _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 4),
      const Text(
        'आज तपाईंलाई कस्तो महसुस भइरहेको छ?',
        style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
      ),
    ],
  );
  Widget _buildActionCards() => Row(
    children: [
      Expanded(
        child: _ActionCard(
          icon: Icons.calendar_today_rounded,
          titleNe: 'अपोइन्टमेन्ट\nबुक गर्नुहोस्',
          titleEn: 'Book Appointment',
          color: AppConstants.primaryColor,
          onTap: () => Get.to(() => const SimpleBookScreen()),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ActionCard(
          icon: Icons.emergency_rounded,
          titleNe: 'आपतकालीन\nसम्पर्क',
          titleEn: 'Emergency Contact',
          color: const Color(0xFFB71C1C),
          onTap: () => Get.to(() => EmergencyCallscreen()),
        ),
      ),
    ],
  );

  Widget _buildNextAppointmentSection() {
    if (_nextAppointment == null) return _buildNoUpcoming();
    final a = _nextAppointment!;
    return GestureDetector(
      onTap: () => Get.to(() => AppointmentsScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const Text(
                    'आउँदो अपोइन्टमेन्ट',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: a.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DoctorAvatar(
                    name: a.doctorName,
                    avatarUrl: a.doctorAvatarUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'डा. ${a.doctorName}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.specialty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.healthpostName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              a.formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(a.consultIcon, size: 13, color: Colors.grey),
                            const SizedBox(width: 3),
                            Text(
                              _consultTypeLabel(a.consultationType),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => AppointmentsScreen()),
                      icon: Icon(a.consultIcon, size: 18),
                      label: Text(
                        a.consultationType == 'video'
                            ? 'Join Video'
                            : a.consultationType == 'audio'
                            ? 'Join Call'
                            : 'Open Chat',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (a.status == 'pending' || a.status == 'confirmed')
                    _cancellingId == a.id
                        ? const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () =>
                                _cancelAppointment(a.id, a.doctorName),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'रद्द',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUpcoming() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: AppConstants.primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'कुनै आउँदो अपोइन्टमेन्ट छैन',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'नयाँ अपोइन्टमेन्ट बुक गर्न तलको बटन थिच्नुहोस्',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.to(() => const SimpleBookScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'बुक',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsRow() => Row(
    children: [
      _StatCard(
        value: '${_stats.total}',
        label: 'कुल परामर्श',
        color: AppConstants.primaryColor,
      ),
      const SizedBox(width: 12),
      _StatCard(
        value: '${_stats.thisMonth}',
        label: 'यो महिना',
        color: const Color(0xFF1565C0),
      ),
      const SizedBox(width: 12),
      _StatCard(
        value: '${_stats.pending}',
        label: 'आउँदो',
        color: const Color(0xFFE65100),
      ),
    ],
  );

  Widget _buildUpcomingApiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'यो हप्ता अपोइन्टमेन्ट',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_upcomingRaw.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _upcomingRaw.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildUpcomingApiCard(_upcomingRaw[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingApiCard(Map<String, dynamic> appt) {
    final id = appt['id']?.toString() ?? '';
    final doctor = appt['doctor'];
    final doctorMap = doctor is Map<String, dynamic> ? doctor : null;
    final doctorProfile = doctorMap?['profile'];
    final doctorProfileMap =
        doctorProfile is Map<String, dynamic> ? doctorProfile : null;
    final doctorName =
        appt['doctor_name']?.toString() ??
        appt['full_name']?.toString() ??
        doctorMap?['full_name']?.toString() ??
        doctorProfileMap?['full_name']?.toString() ??
        appt['doctor']?.toString() ??
        'डाक्टर';
    final scheduledAt = appt['scheduled_at'] != null
        ? DateTime.tryParse(appt['scheduled_at'].toString())?.toLocal()
        : null;
    final type = appt['consultation_type']?.toString() ?? 'audio';
    final status = appt['status']?.toString() ?? 'pending';

    final statusColor = status == 'confirmed'
        ? Colors.green
        : status == 'cancelled'
        ? Colors.red
        : Colors.orange;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'डा. $doctorName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (scheduledAt != null)
            Text(
              '${scheduledAt.day}/${scheduledAt.month} – ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: AppConstants.primaryColor),
            ),
          const SizedBox(height: 4),
          Text(
            _consultTypeLabel(type),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Spacer(),
          if (status == 'pending' || status == 'confirmed')
            Align(
              alignment: Alignment.centerRight,
              child: _cancellingId == id
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : GestureDetector(
                      onTap: () => _cancelAppointment(id, doctorName),
                      child: Text(
                        'रद्द गर्नुहोस्',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'डाक्टर खोज्नुहोस्',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.to(() => const SimpleBookScreen()),
              child: Text(
                'सबै हेर्नुहोस्',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingDoctors)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_quickDoctors.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                'डाक्टर उपलब्ध छैनन्',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          )
        else
          ...(_quickDoctors.map((d) => _buildDoctorListTile(d))),
      ],
    );
  }

  Widget _buildDoctorListTile(Map<String, dynamic> doctor) {
    final name =
        doctor['full_name']?.toString() ??
        doctor['name']?.toString() ??
        'डाक्टर';
    final specialty = doctor['specialty']?.toString() ?? '';
    final healthpost = doctor['healthpost_name']?.toString() ?? '';
    final avatarUrl = doctor['avatar_url']?.toString();
    final doctorId = doctor['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _DoctorAvatar(name: name, avatarUrl: avatarUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'डा. $name',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (specialty.isNotEmpty)
                  Text(
                    specialty,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (healthpost.isNotEmpty)
                  Text(
                    healthpost,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const SimpleBookScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'बुक',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader() => Row(
    children: [
      const Text(
        'हालका अपोइन्टमेन्ट',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () => Get.to(() => AppointmentsScreen()),
        child: Text(
          'सबै हेर्नुहोस्',
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildRecentCard(AppointmentData a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        _DoctorAvatar(
          name: a.doctorName,
          avatarUrl: a.doctorAvatarUrl,
          size: 44,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'डा. ${a.doctorName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                a.specialty.isEmpty ? a.healthpostName : a.specialty,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 11,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    a.formattedDate,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Icon(a.consultIcon, size: 11, color: Colors.grey),
                  const SizedBox(width: 3),
                  Text(
                    _consultTypeLabel(a.consultationType),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: a.statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.statusLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            if (a.status == 'pending' || a.status == 'confirmed') ...[
              const SizedBox(height: 6),
              _cancellingId == a.id
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : GestureDetector(
                      onTap: () => _cancelAppointment(a.id, a.doctorName),
                      child: Text(
                        'रद्द',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _buildEmptyRecent() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade200),
          const SizedBox(height: 10),
          Text(
            'अहिलेसम्म कुनै अपोइन्टमेन्ट छैन',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    ),
  );

  Widget _buildShimmer() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        const SizedBox(height: 20),
        ...List.generate(
          5,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'डेटा लोड गर्न सकिएन',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? '',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('पुन: प्रयास गर्नुहोस्'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  String _consultTypeLabel(String type) {
    switch (type) {
      case 'video':
        return 'भिडियो';
      case 'audio':
        return 'अडियो';
      default:
        return 'च्याट';
    }
  }
}


class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String titleNe, titleEn;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.titleNe,
    required this.titleEn,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            titleNe,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titleEn,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _DoctorAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  const _DoctorAvatar({required this.name, this.avatarUrl, required this.size});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
