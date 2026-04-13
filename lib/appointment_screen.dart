import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/services/api_service.dart';
import 'package:patient_app/app_constants.dart';
import 'chat_screen.dart';
import 'models/appointment_model.dart';

IconData consultTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return Icons.videocam_rounded;
    case 'audio':
    case 'phone':
      return Icons.call_rounded;
    case 'chat':
    case 'message':
      return Icons.chat_bubble_rounded;
    default:
      return Icons.local_hospital_rounded;
  }
}

String consultTypeLabel(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return 'भिडियो';
    case 'audio':
    case 'phone':
      return 'अडियो';
    case 'chat':
    case 'message':
      return 'च्याट';
    default:
      return 'भौतिक';
  }
}

Color consultTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return const Color(0xFF6C5CE7);
    case 'audio':
    case 'phone':
      return const Color(0xFF00B894);
    case 'chat':
    case 'message':
      return const Color(0xFF0984E3);
    default:
      return const Color(0xFFE17055);
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = true;
  bool _cancelling = false;
  String? _error;
  List<Appt> _today = [];
  List<Appt> _upcoming = [];
  List<Appt> _pending = [];
  List<Appt> _completed = [];
  List<Appt> _cancelled = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ApiService.getMyAppointmentsEnriched();
      final all = rows.map(Appt.fromApi).toList();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      setState(() {
        _today =
            all
                .where(
                  (a) =>
                      a.status == 'confirmed' &&
                      a.scheduledAt.isAfter(todayStart) &&
                      a.scheduledAt.isBefore(todayEnd),
                )
                .toList()
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        _upcoming =
            all
                .where(
                  (a) =>
                      a.status == 'confirmed' &&
                      a.scheduledAt.isAfter(todayEnd),
                )
                .toList()
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        _pending = all.where((a) => a.status == 'pending').toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        _completed = all.where((a) => a.status == 'completed').toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        _cancelled =
            all
                .where((a) => a.status == 'cancelled' || a.status == 'no_show')
                .toList()
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _cancelAppointment(Appt appt) async {
    final confirm = await _showCancelDialog(appt);
    if (confirm != true) return;
    setState(() => _cancelling = true);
    try {
      await ApiService.cancelAppointment(appt.id);
      Get.snackbar(
        'रद्द गरियो',
        'अपोइन्टमेन्ट सफलतापूर्वक रद्द गरियो।',
        backgroundColor: const Color(0xFFEAF7EF),
        colorText: const Color(0xFF1A7A4A),
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      await _loadAppointments();
    } catch (e) {
      Get.snackbar(
        'त्रुटि',
        'रद्द गर्न सकिएन: $e',
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFEF4444),
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<bool?> _showCancelDialog(Appt appt) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'अपोइन्टमेन्ट रद्द गर्नुहुन्छ?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'डा. ${appt.doctorName}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            appt.dateTimeLabel,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            'यो कार्य पूर्ववत गर्न सकिँदैन।',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('फिर्ता', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('रद्द गर्नुहोस्'),
        ),
      ],
    ),
  );

  void _handleJoin(Appt appt) {
    final type = appt.consultType.toLowerCase();
    if (type == 'video') {
      Get.to(() => VideoConsultScreen(appt: appt));
    } else if (type == 'audio' || type == 'phone') {
      Get.to(() => AudioConsultScreen(appt: appt));
    } else if (type == 'chat' || type == 'message') {
      Get.to(() => ChatScreen(appt: appt));
    } else {
      Get.snackbar(
        'भौतिक भेट',
        'डा. ${appt.doctorName} सँग भौतिक परामर्श – ${appt.healthpostName}',
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
        colorText: AppConstants.primaryColor,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: _loading
          ? _buildShimmer()
          : _error != null
          ? _buildError()
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildTabContent(_today, 'today'),
                _buildTabContent(_upcoming, 'upcoming'),
                _buildTabContent(_pending, 'pending'),
                _buildTabContent(_completed, 'completed'),
                _buildTabContent(_cancelled, 'cancelled'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(
          () => const SimpleBookScreen(),
        )?.then((_) => _loadAppointments()),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'नयाँ बुक',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppConstants.primaryColor,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    leading: Navigator.canPop(context)
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          )
        : null,
    title: const Text(
      'मेरा अपोइन्टमेन्ट',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        onPressed: _loadAppointments,
      ),
    ],
    bottom: TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      tabs: [
        Tab(
          child: _BadgeTab(
            label: 'आज',
            count: _today.length,
            badgeColor: AppConstants.primaryColor,
            showDot: _today.isNotEmpty,
          ),
        ),
        Tab(
          text: 'आउँदो${_upcoming.isNotEmpty ? " (${_upcoming.length})" : ""}',
        ),
        Tab(
          child: _BadgeTab(
            label: 'पर्खाइमा',
            count: _pending.length,
            badgeColor: const Color(0xFFF57F17),
            showDot: _pending.isNotEmpty,
          ),
        ),
        const Tab(text: 'सम्पन्न'),
        const Tab(text: 'रद्द'),
      ],
    ),
  );

  Widget _buildTabContent(List<Appt> list, String type) {
    if (list.isEmpty) return _buildEmpty(type);
    final showJoin = type == 'today';
    final canCancel =
        type == 'today' || type == 'upcoming' || type == 'pending';
    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: list.length,
        itemBuilder: (_, i) => _ApptCard(
          appt: list[i],
          showJoin: showJoin,
          showCancel: canCancel,
          cancelling: _cancelling,
          onCancel: () => _cancelAppointment(list[i]),
          onJoin: () => _handleJoin(list[i]),
          onTap: type == 'today' ? () => _showDetailSheet(list[i]) : null,
        ),
      ),
    );
  }

  void _showDetailSheet(Appt a) {
    final canJoin = a.isToday;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        appt: a,
        onCancel: (a.isUpcoming || a.isPending || a.isToday)
            ? () {
                Navigator.pop(context);
                _cancelAppointment(a);
              }
            : null,
        onJoin: canJoin
            ? () {
                Navigator.pop(context);
                _handleJoin(a);
              }
            : null,
      ),
    );
  }

  Widget _buildEmpty(String type) {
    final icon = switch (type) {
      'today' => Icons.today_rounded,
      'upcoming' => Icons.calendar_today_outlined,
      'pending' => Icons.hourglass_empty_rounded,
      'completed' => Icons.check_circle_outline_rounded,
      _ => Icons.cancel_outlined,
    };
    final msg = switch (type) {
      'today' => 'आज कुनै अपोइन्टमेन्ट छैन',
      'upcoming' => 'कुनै आउँदो अपोइन्टमेन्ट छैन',
      'pending' => 'कुनै पर्खाइमा रहेको अपोइन्टमेन्ट छैन',
      'completed' => 'कुनै सम्पन्न अपोइन्टमेन्ट छैन',
      _ => 'कुनै रद्द गरिएको अपोइन्टमेन्ट छैन',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          if (type == 'today' || type == 'upcoming' || type == 'pending')
            Text(
              'नयाँ अपोइन्टमेन्ट बुक गर्न तलको बटन थिच्नुहोस्',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    itemBuilder: (_, __) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
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
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('पुन: प्रयास'),
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
}

class _BadgeTab extends StatelessWidget {
  final String label;
  final int count;
  final Color badgeColor;
  final bool showDot;
  const _BadgeTab({
    required this.label,
    required this.count,
    required this.badgeColor,
    required this.showDot,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      if (showDot) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ],
  );
}

class _ApptCard extends StatelessWidget {
  final Appt appt;
  final bool showJoin;
  final bool showCancel;
  final bool cancelling;
  final VoidCallback onCancel;
  final VoidCallback onJoin;
  final VoidCallback? onTap; 

  const _ApptCard({
    required this.appt,
    required this.showJoin,
    required this.showCancel,
    required this.cancelling,
    required this.onCancel,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = consultTypeColor(appt.consultType);
    final typeIcon = consultTypeIcon(appt.consultType);
    final typeLabel = consultTypeLabel(appt.consultType);

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: appt.isPending
            ? const Border(left: BorderSide(color: Color(0xFFF57F17), width: 4))
            : appt.isToday
            ? Border(
                left: BorderSide(color: AppConstants.primaryColor, width: 4),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (appt.isToday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.today_rounded,
                    size: 14,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'आजको अपोइन्टमेन्ट',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (appt.isPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty_rounded,
                    size: 14,
                    color: Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'डाक्टरको पुष्टिको प्रतीक्षामा छ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _Avatar(
                      name: appt.doctorName,
                      url: appt.avatarUrl,
                      size: 50,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: typeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(typeIcon, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'डा. ${appt.doctorName}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appt.specialty.isNotEmpty
                            ? appt.specialty
                            : appt.healthpostName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: Color(0xFFB71C1C),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                appt.dateTimeLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB71C1C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 12, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  typeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (appt.patientNotes != null &&
                          appt.patientNotes!.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          appt.patientNotes!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: appt.statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appt.statusNe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showJoin || showCancel)
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFFE2E8F0),
            ),
          if (showJoin || showCancel)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: [
                  if (showJoin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: Icon(typeIcon, size: 17),
                        label: Text(
                          _joinLabel(appt.consultType),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: typeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (showJoin && showCancel) const SizedBox(height: 8),
                  if (showCancel)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: cancelling ? null : onCancel,
                        icon: cancelling
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined, size: 17),
                        label: const Text(
                          'अपोइन्टमेन्ट रद्द गर्नुहोस्',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      cardContent = GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }

  String _joinLabel(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'भिडियो कल जोइन गर्नुहोस्';
      case 'audio':
      case 'phone':
        return 'अडियो कल गर्नुहोस्';
      case 'chat':
      case 'message':
        return 'च्याट सुरु गर्नुहोस्';
      default:
        return 'विवरण हेर्नुहोस्';
    }
  }
}

class _DetailSheet extends StatelessWidget {
  final Appt appt;
  final VoidCallback? onCancel;
  final VoidCallback? onJoin;

  const _DetailSheet({required this.appt, this.onCancel, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final typeColor = consultTypeColor(appt.consultType);
    final typeIcon = consultTypeIcon(appt.consultType);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(typeIcon, size: 18, color: typeColor),
                  const SizedBox(width: 10),
                  Text(
                    consultTypeLabel(appt.consultType),
                    style: TextStyle(
                      fontSize: 13,
                      color: typeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _consultDescription(appt.consultType),
                    style: TextStyle(
                      fontSize: 12,
                      color: typeColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (appt.isPending)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 16,
                      color: Color(0xFFF57F17),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'यो अपोइन्टमेन्ट अझै डाक्टरले पुष्टि गर्नु बाँकी छ।',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          _Avatar(
                            name: appt.doctorName,
                            url: appt.avatarUrl,
                            size: 56,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                typeIcon,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'डा. ${appt.doctorName}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appt.specialty.isNotEmpty
                                  ? appt.specialty
                                  : appt.healthpostName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            if (appt.specialty.isNotEmpty &&
                                appt.healthpostName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                appt.healthpostName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: appt.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appt.statusNe,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SheetRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'मिति',
                    value: appt.dateLabel,
                  ),
                  _SheetRow(
                    icon: Icons.access_time_rounded,
                    label: 'समय',
                    value: appt.timeLabel,
                  ),
                  _SheetRow(
                    icon: typeIcon,
                    label: 'परामर्श प्रकार',
                    value: consultTypeLabel(appt.consultType),
                  ),
                  if (appt.patientNotes != null &&
                      appt.patientNotes!.isNotEmpty)
                    _SheetRow(
                      icon: Icons.notes_rounded,
                      label: 'कारण',
                      value: appt.patientNotes!,
                    ),
                  _SheetRow(
                    icon: Icons.home_outlined,
                    label: 'स्वास्थ्य संस्था',
                    value: appt.healthpostName.isEmpty
                        ? '—'
                        : appt.healthpostName,
                  ),
                  const SizedBox(height: 24),
                  if (onJoin != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: Icon(typeIcon, size: 18),
                        label: Text(
                          _joinLabelFull(appt.consultType),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: typeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (onJoin != null) const SizedBox(height: 10),
                  if (onCancel != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          'अपोइन्टमेन्ट रद्द गर्नुहोस्',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          backgroundColor: Colors.red.shade50,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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

  String _joinLabelFull(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'भिडियो कल जोइन गर्नुहोस्';
      case 'audio':
      case 'phone':
        return 'अडियो कल गर्नुहोस्';
      case 'chat':
      case 'message':
        return 'च्याट सुरु गर्नुहोस्';
      default:
        return 'स्थान हेर्नुहोस्';
    }
  }

  String _consultDescription(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return 'भिडियो परामर्श';
      case 'audio':
      case 'phone':
        return 'फोन परामर्श';
      case 'chat':
      case 'message':
        return 'सन्देश परामर्श';
      default:
        return 'भौतिक भेट';
    }
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppConstants.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    ),
  );
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double size;
  const _Avatar({required this.name, this.url, required this.size});

  String get _initials {
    final pts = name.trim().split(' ');
    if (pts.length >= 2) return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final r = size / 2;
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: r,
        backgroundImage: NetworkImage(url!),
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      );
    }
    return CircleAvatar(
      radius: r,
      backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: r * 0.65,
        ),
      ),
    );
  }
}

class AudioConsultScreen extends StatelessWidget {
  final Appt appt;
  const AudioConsultScreen({super.key, required this.appt});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Audio – डा. ${appt.doctorName}'),
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    body: const Center(child: Text('Audio call screen placeholder')),
  );
}

class VideoConsultScreen extends StatelessWidget {
  final Appt appt;
  const VideoConsultScreen({super.key, required this.appt});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Video – डा. ${appt.doctorName}'),
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    body: const Center(child: Text('Video call screen placeholder')),
  );
}
