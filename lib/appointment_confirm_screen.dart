

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/models/doctor_model.dart';
import 'package:patient_app/nepal_location.dart';
import 'package:patient_app/services/api_service.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step4_confirm_appointment.dart';
import 'package:patient_app/widgets/image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ConsultationType { chat, audio, video }

class Slot {
  final String display, value;
  final int hour, minute;
  const Slot(this.display, this.value, this.hour, this.minute);
}

const morningSlots = [
  Slot('९:०० बिहान', '9:00 AM', 9, 0),
  Slot('९:३० बिहान', '9:30 AM', 9, 30),
  Slot('१०:०० बिहान', '10:00 AM', 10, 0),
  Slot('१०:३० बिहान', '10:30 AM', 10, 30),
  Slot('११:०० बिहान', '11:00 AM', 11, 0),
  Slot('११:३० बिहान', '11:30 AM', 11, 30),
];
const afternoonSlots = [
  Slot('२:०० दिउँसो', '2:00 PM', 14, 0),
  Slot('२:३० दिउँसो', '2:30 PM', 14, 30),
  Slot('३:०० दिउँसो', '3:00 PM', 15, 0),
  Slot('३:३० दिउँसो', '3:30 PM', 15, 30),
  Slot('४:०० दिउँसो', '4:00 PM', 16, 0),
  Slot('४:३० दिउँसो', '4:30 PM', 16, 30),
];

List<Slot> get _allSlots => [...morningSlots, ...afternoonSlots];

class SimpleBookScreen extends StatefulWidget {
  const SimpleBookScreen({super.key});
  @override
  State<SimpleBookScreen> createState() => _SimpleBookScreenState();
}

class _SimpleBookScreenState extends State<SimpleBookScreen> {
  final _supa = Supabase.instance.client;
  int _step = 0;

  // Step 1
  ConsultationType? _type;

  // Step 2 — doctor with location filter
  String? _province, _district, _municipality; // ← _province added
  List<DoctorInfo> _doctors = [];
  bool _loadingDoctors = false;
  DoctorInfo? _doctor;

  // Step 3
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  Slot? _selectedSlot;
  Map<String, bool> _slotAvailability = {};
  bool _loadingSlots = false;

  // Step 4
  final _sympCtrl = TextEditingController();
  bool _booking = false;

  @override
  void dispose() {
    _sympCtrl.dispose();
    super.dispose();
  }
bool get _canProceed => switch (_step) {
    0 => _type != null,
    1 => _doctor != null,
    2 => _selectedDate != null && _selectedSlot != null,
    3 => true,
    _ => false,
  };

  void _snack(String msg, {bool err = false}) => Get.snackbar(
    err ? 'त्रुटि' : 'सफल',
    msg,
    backgroundColor: err ? const Color(0xFFFEF2F2) : const Color(0xFFEAF7EF),
    colorText: err ? const Color(0xFFEF4444) : const Color(0xFF1A7A4A),
    borderRadius: 14,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 4),
    snackPosition: SnackPosition.BOTTOM,
  );

bool _fetchLock = false;

Future<void> _fetchDoctors() async {
    print(
      ' _fetchDoctors called: province=$_province, district=$_district, municipality=$_municipality',
    );
    if (_district == null || _fetchLock) {
      print(' Skipping: district is null or fetchLock active');
      return;
    }
    _fetchLock = true;
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
    });
    try {
      final results = await ApiService.fetchDoctors(
        specialty: 'General',
        province: _province,
        district: _district,
        municipality: _municipality,
      );
      print(' Received ${results.length} doctors');
      print(
        ' First doctor raw: ${results.isNotEmpty ? results.first : 'none'}',
      );
      setState(() {
        _doctors = results.map((e) => DoctorInfo.fromMap(e)).toList();
        _loadingDoctors = false;
      });
    } catch (e, stack) {
      print(' Error fetching doctors: $e\n$stack');
      setState(() => _loadingDoctors = false);
      _snack('डाक्टर लोड गर्न सकिएन', err: true);
    } finally {
      _fetchLock = false;
    }
  }

  Future<void> _checkAvailability() async {
    if (_doctor == null || _selectedDate == null) return;
    setState(() {
      _loadingSlots = true;
      _slotAvailability = {};
    });
    try {
      final booked = await ApiService.checkSlotAvailability(
        doctorTableId: _doctor!.doctorTableId,
        date: _selectedDate!,
      );
      setState(() {
        _slotAvailability = {
          for (final s in _allSlots) s.value: booked.contains(s.value),
        };
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() => _loadingSlots = false);
    }
  }

  Future<void> _book() async {
    if (_supa.auth.currentUser == null) {
      _snack('कृपया पहिले लग इन गर्नुहोस्।', err: true);
      return;
    }
    setState(() => _booking = true);
    try {
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedSlot!.hour,
        _selectedSlot!.minute,
      );
      await ApiService.bookAppointment(
        doctorTableId: _doctor!.doctorTableId,
        consultationType: _type!.name,
        scheduledAt: dt,
        durationMinutes: 30,
        patientNotes: _sympCtrl.text.trim().isEmpty
            ? null
            : _sympCtrl.text.trim(),
      );
      setState(() => _booking = false);
      if (mounted) {
        await _showSuccess();
        Get.back();
      }
    } catch (e) {
      setState(() => _booking = false);
      if (e.toString().contains('409')) {
        _snack('यो समय बुक भयो, अर्को छान्नुहोस्।', err: true);
        await _checkAvailability();
      } else {
        _snack('बुकिङ असफल: $e', err: true);
      }
    }
  }

  Future<void> _showSuccess() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 38,
                color: Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'अपॉइन्टमेन्ट बुक भयो!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'डा. ${_doctor!.name} — ${_selectedSlot!.display}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ठीक छ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _next() {
    if (!_canProceed) return;
    if (_step == 3) {
      _book();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Get.back();
    }
  }

  static const _stepTitles = [
    'परामर्श प्रकार',
    'डाक्टर छान्नुहोस्',
    'मिति र समय',
    'लक्षण र सारांश',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _back,
      ),
      title: Text(
        _stepTitles[_step],
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    body: Column(
      children: [
        // Progress dots
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _step ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= _step
                      ? AppConstants.primaryColor
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
          ),
        ),
        // Bottom button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_canProceed && !_booking) ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF9CA3AF),
              ),
              child: _booking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _step == 3 ? 'अपॉइन्टमेन्ट बुक गर्नुहोस्' : 'अर्को →',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStep() => switch (_step) {
    0 => _Step1Type(
      selected: _type,
      onSelect: (t) => setState(() => _type = t),
    ),
    1 => _Step2Doctor(
      // ← private _ prefix, matches class name below
      province: _province,
      district: _district,
      municipality: _municipality,
      doctors: _doctors,
      loading: _loadingDoctors,
      selected: _doctor,
      onProvinceChange: (v) {
        setState(() {
          _province = v;
          _district = null;
          _municipality = null;
          _doctor = null;
          _doctors = [];
        });
      },
      onDistrictChange: (v) {
        setState(() {
          _district = v;
          _municipality = null;
          _doctor = null;
          _doctors = [];
        });
        if (v != null) _fetchDoctors();
      },
      onMunicipalityChange: (v) {
        setState(() {
          _municipality = v;
          _doctor = null;
        });
        _fetchDoctors();
      },
      onDoctorSelect: (d) => setState(() => _doctor = d),
    ),
    2 => Step4DateTime(
      focusedMonth: _focusedMonth,
      selectedDate: _selectedDate,
      selectedSlot: _selectedSlot,
      availability: _slotAvailability,
      loadingSlots: _loadingSlots,
      onMonthChanged: (m) => setState(() => _focusedMonth = m),
      onDateSelect: (d) {
        setState(() {
          _selectedDate = d;
          _selectedSlot = null;
        });
        _checkAvailability();
      },
      onSlotSelect: (s) => setState(() => _selectedSlot = s),
    ),
    3 => _Step4Confirm(
      doctor: _doctor!,
      type: _type!,
      date: _selectedDate!,
      slot: _selectedSlot!,
      sympCtrl: _sympCtrl,
    ),
    _ => const SizedBox(),
  };
}

class _Step1Type extends StatelessWidget {
  final ConsultationType? selected;
  final ValueChanged<ConsultationType> onSelect;
  const _Step1Type({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'कसरी डाक्टरसँग कुरा गर्न चाहनुहुन्छ?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'परामर्श प्रकार छान्नुहोस्',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            _TypeCard(
              icon: Icons.chat_bubble_outline_rounded,
              labelNe: 'च्याट',
              labelEn: 'Chat',
              type: ConsultationType.chat,
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(width: 12),
            _TypeCard(
              icon: Icons.phone_outlined,
              labelNe: 'अडियो',
              labelEn: 'Audio',
              type: ConsultationType.audio,
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(width: 12),
            _TypeCard(
              icon: Icons.videocam_outlined,
              labelNe: 'भिडियो',
              labelEn: 'Video',
              type: ConsultationType.video,
              selected: selected,
              onSelect: onSelect,
            ),
          ],
        ),
      ],
    ),
  );
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String labelNe, labelEn;
  final ConsultationType type;
  final ConsultationType? selected;
  final ValueChanged<ConsultationType> onSelect;

  const _TypeCard({
    required this.icon,
    required this.labelNe,
    required this.labelEn,
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
          decoration: BoxDecoration(
            color: sel
                ? AppConstants.primaryColor.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? AppConstants.primaryColor : const Color(0xFFE2E8F0),
              width: sel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: sel
                    ? AppConstants.primaryColor
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 10),
              Text(
                labelNe,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: sel
                      ? AppConstants.primaryColor
                      : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                labelEn,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step2Doctor extends StatelessWidget {
  final String? province, district, municipality;
  final List<DoctorInfo> doctors;
  final bool loading;
  final DoctorInfo? selected;
  final ValueChanged<String?> onProvinceChange;
  final ValueChanged<String?> onDistrictChange, onMunicipalityChange;
  final ValueChanged<DoctorInfo> onDoctorSelect;

  const _Step2Doctor({
    required this.province,
    required this.district,
    required this.municipality,
    required this.doctors,
    required this.loading,
    required this.selected,
    required this.onProvinceChange,
    required this.onDistrictChange,
    required this.onMunicipalityChange,
    required this.onDoctorSelect,
  });

  Widget _buildAvatar(String? url, String initials) {
    return ClipOval(
      child: SizedBox(
        width: 50,
        height: 50,
        child: (url != null && url.isNotEmpty)
            ? SafeNetworkImage(url: url)
            : _Initials(initials),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Province — reads directly from NepalLocation, Nepali keys
        _LocDrop(
          hint: 'प्रदेश छान्नुहोस्',
          value: province,
          items: NepalLocation.provinces,
          onChanged: onProvinceChange,
        ),
        const SizedBox(height: 10),
        // District — enabled only after province chosen
        _LocDrop(
          hint: province == null
              ? 'पहिले प्रदेश छान्नुहोस्'
              : 'जिल्ला छान्नुहोस्',
          value: district,
          enabled: province != null,
          items: province != null ? NepalLocation.districtsOf(province!) : [],
          onChanged: onDistrictChange,
        ),
        const SizedBox(height: 10),
        // Municipality — optional, enabled after district chosen
        _LocDrop(
          hint: district == null
              ? 'पहिले जिल्ला छान्नुहोस्'
              : 'नगरपालिका (वैकल्पिक)',
          value: municipality,
          enabled: district != null,
          items: district != null
              ? [
                  '',
                  ...NepalLocation.municipalitiesOf(province ?? '', district!),
                ]
              : [],
          onChanged: onMunicipalityChange,
        ),
        const SizedBox(height: 20),

        if (province == null || district == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 48,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'प्रदेश र जिल्ला छान्नुहोस्',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (doctors.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.person_search_outlined,
                    size: 48,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'यस क्षेत्रमा डाक्टर भेटिएन',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          )
        else
          ...doctors.map(
            (d) => GestureDetector(
              onTap: () => onDoctorSelect(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected?.id == d.id
                      ? AppConstants.primaryColor.withOpacity(0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected?.id == d.id
                        ? AppConstants.primaryColor
                        : const Color(0xFFE2E8F0),
                    width: selected?.id == d.id ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _buildAvatar(d.avatarUrl, d.initials),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'डा. ${d.name}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selected?.id == d.id
                                  ? AppConstants.primaryColor
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            d.hospital,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          if (d.district.isNotEmpty)
                            Text(
                              d.district,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (selected?.id == d.id)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppConstants.primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _LocDrop extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _LocDrop({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: enabled ? Colors.white : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: (value != null && items.contains(value)) ? value : null,
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            hint,
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isExpanded: true,
        icon: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
            size: 18,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    item.isEmpty ? 'सबै' : item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials(this.initials);

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
  );
}

class _Step4Confirm extends StatelessWidget {
  final DoctorInfo doctor;
  final ConsultationType type;
  final DateTime date;
  final Slot slot;
  final TextEditingController sympCtrl;

  const _Step4Confirm({
    required this.doctor,
    required this.type,
    required this.date,
    required this.slot,
    required this.sympCtrl,
  });

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${w[d.weekday - 1]}, ${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              _SRow(
                Icons.person_outline_rounded,
                'डाक्टर',
                'डा. ${doctor.name}',
              ),
              _SRow(Icons.home_outlined, 'स्वास्थ्य संस्था', doctor.hospital),
              _SRow(Icons.calendar_today_outlined, 'मिति', _fmtDate(date)),
              _SRow(Icons.access_time_rounded, 'समय', slot.display),
              _SRow(
                type == ConsultationType.chat
                    ? Icons.chat_bubble_outline_rounded
                    : type == ConsultationType.audio
                    ? Icons.phone_outlined
                    : Icons.videocam_outlined,
                'प्रकार',
                type == ConsultationType.chat
                    ? 'च्याट'
                    : type == ConsultationType.audio
                    ? 'अडियो'
                    : 'भिडियो',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'लक्षणहरू (वैकल्पिक)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: sympCtrl,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'आफ्नो लक्षण यहाँ लेख्नुहोस्...',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
