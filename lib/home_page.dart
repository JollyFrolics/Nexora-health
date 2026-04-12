
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

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ── Load everything in one go ─────────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = _supa.auth.currentUser?.id;
      if (uid == null) throw Exception('Not authenticated');

      // Parallel fetch: profile + appointments
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

      // ── Profile ───────────────────────────────────────────────────────────
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

      // ── Get unique doctor_ids from appointments ────────────────────────────
      final apptRaw = results[1] as List<dynamic>;
      final doctorIds = apptRaw
          .map((e) => (e as Map<String, dynamic>)['doctor_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      // ── Fetch specialty + healthpost for those doctors ────────────────────
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

          final profileRows =
              userIds.isEmpty
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
        } catch (_) {
          // Non-fatal — specialty/healthpost will show empty
        }
      }

      // ── Parse appointments ────────────────────────────────────────────────
      final apptList = apptRaw
          .map((e) {
            final m = e as Map<String, dynamic>;
            final did = m['doctor_id']?.toString() ?? '';
            return _parseAppointment(m, doctorMap[did] ?? {});
          })
          .where((a) => a != null)
          .cast<AppointmentData>()
          .toList();

      // Sort: upcoming first, then by date desc
      apptList.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      final now = DateTime.now();
      _nextAppointment = apptList.firstWhereOrNull(
        (a) =>
            a.scheduledAt.isAfter(now) &&
            (a.status == 'confirmed' || a.status == 'pending'),
      );

      _recentAppointments = apptList.take(5).toList();

      final monthStart = DateTime(now.year, now.month, 1);
      _stats = Stats(
        total: apptList.length,
        thisMonth: apptList
            .where((a) => a.scheduledAt.isAfter(monthStart))
            .length,
        pending: apptList
            .where((a) => a.status == 'pending' || a.status == 'confirmed')
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

  // ── AppBar ────────────────────────────────────────────────────────────────
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
      // Notification bell placeholder
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () {},
      ),
    ],
  );

  // ── Greeting ──────────────────────────────────────────────────────────────
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
          // Avatar
          if (_profile?.avatar != null)
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

  // ── Action Cards ──────────────────────────────────────────────────────────
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

  // ── Next Appointment ──────────────────────────────────────────────────────
  Widget _buildNextAppointmentSection() {
    if (_nextAppointment == null) {
      return _buildNoUpcoming();
    }
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
            // Header
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
            // Doctor row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Avatar
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
            // Join button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => AppointmentsScreen()),
                  icon: Icon(a.consultIcon, size: 18),
                  label: Text(
                    a.consultationType == 'video'
                        ? 'भिडियो जोइन गर्नुहोस् / Join'
                        : a.consultationType == 'audio'
                        ? 'कल जोइन गर्नुहोस् / Join'
                        : 'च्याट खोल्नुहोस् / Open Chat',
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
        label: 'पर्खाइमा',
        color: const Color(0xFFE65100),
      ),
    ],
  );



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

  // ── Recent Appointment Card ───────────────────────────────────────────────
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
