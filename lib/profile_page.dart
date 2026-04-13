import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/change_password.dart';
import 'package:patient_app/controller/app_setting.dart';
import 'package:patient_app/controller/profile_controller.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _genderOptions = ['male', 'female', 'other'];
const _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = PatientService();

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;

  PatientProfile? _profile;

  // Form controllers & edit-mode state
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  String _selectedGender = 'male';
  String _selectedBloodGroup = '';
  DateTime? _selectedDob;
  List<String> _conditions = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _conditionCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final p = await _service.fetchMyProfile();
      _applyProfile(p);
    } catch (e) {
      _showSnack('डेटा लोड गर्न सकिएन: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyProfile(PatientProfile? p) {
    _profile = p;
    _nameCtrl.text = p?.fullName ?? '';
    _phoneCtrl.text = p?.phone ?? '';
    _addressCtrl.text = p?.address ?? '';
    _selectedGender = (_genderOptions.contains(p?.gender) ? p!.gender : 'male');
    _selectedBloodGroup = p?.bloodGroup ?? '';
    _selectedDob = p?.dateOfBirth;
    _conditions = List<String>.from(p?.conditions ?? []);
  }

  Future<void> _saveProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      _showSnack('लगइन छैन', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = PatientProfile(
        id: _profile?.id ?? '',
        userId: uid,
        fullName: _nameCtrl.text.trim(),
        email: _profile?.email ?? '',
        phone: _phoneCtrl.text.trim(),
        dateOfBirth: _selectedDob,
        gender: _selectedGender,
        address: _addressCtrl.text.trim(),
        bloodGroup: _selectedBloodGroup,
        conditions: List<String>.from(_conditions),
        avatar: ''
      );
      await _service.saveProfile(updated);
      setState(() {
        _profile = updated;
        _editing = false;
      });
      _showSnack('प्रोफाइल सुरक्षित गरियो ✓');
    } catch (e) {
      _showSnack('सुरक्षित गर्न सकिएन: $e', isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }

  void _cancelEdit() {
    _applyProfile(_profile);
    setState(() => _editing = false);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'जन्म मिति छान्नुहोस्',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB71C1C),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(15))
        ),
        title: Row(
          children: [
            Image.asset("assets/images/gov_logo.webp", width: 40, height: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  AppConstants.nepalSarkar,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppConstants.govtOfNepal,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!_editing)
            GestureDetector(
              onTap: () => setState(() => _editing = true),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'सम्पादन',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: _saving ? null : _cancelEdit,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'रद्द',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _saving ? null : _saveProfile,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFB71C1C),
                            ),
                          )
                        : const Text(
                            'सुरक्षित',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildMedicalHistoryCard(),
                  const SizedBox(height: 16),
                  _buildSettingsCard(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  // ── Profile card ──────────────────────────
  Widget _buildProfileCard() {
    final age = _profile?.ageInYears;
    final dobStr = _selectedDob != null
        ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + name/phone
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFEEEEEE),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 11,
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
                    _editing
                        ? _inputField(_nameCtrl, hint: 'पूरा नाम')
                        : Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                    const SizedBox(height: 3),
                    _editing
                        ? _inputField(
                            _phoneCtrl,
                            hint: 'फोन नम्बर',
                            keyboardType: TextInputType.phone,
                          )
                        : Text(
                            _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                    if (!_editing && (_profile?.email.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 3),
                      Text(
                        _profile!.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (!_editing) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'सत्यापित',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 1: Date of birth + Gender
          Row(
            children: [
              // Date of birth (date picker in edit mode)
              Expanded(
                child: _editing
                    ? GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: _styledBox(
                          label: 'जन्म मिति',
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dobStr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Color(0xFFB71C1C),
                              ),
                            ],
                          ),
                          editing: true,
                        ),
                      )
                    : _infoBox(
                        label: 'उमेर / जन्म मिति',
                        value: age != null ? '$age वर्ष  ($dobStr)' : dobStr,
                      ),
              ),
              const SizedBox(width: 10),
              // Gender dropdown
              Expanded(
                child: _editing
                    ? _styledBox(
                        label: 'लिङ्ग',
                        editing: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _genderOptions.contains(_selectedGender)
                                ? _selectedGender
                                : 'male',
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            items: _genderOptions
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGender = v!),
                          ),
                        ),
                      )
                    : _infoBox(
                        label: 'लिङ्ग',
                        value: _selectedGender.isNotEmpty
                            ? _selectedGender
                            : '—',
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Address + Blood group
          Row(
            children: [
              // Address text field
              Expanded(
                child: _editing
                    ? _styledBox(
                        label: 'ठेगाना',
                        editing: true,
                        child: TextField(
                          controller: _addressCtrl,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    : _infoBox(
                        label: 'ठेगाना',
                        value: _addressCtrl.text.isNotEmpty
                            ? _addressCtrl.text
                            : '—',
                      ),
              ),
              const SizedBox(width: 10),
              // Blood group dropdown
              Expanded(
                child: _editing
                    ? _styledBox(
                        label: 'रगत समूह',
                        editing: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _bloodGroupOptions.contains(_selectedBloodGroup)
                                ? _selectedBloodGroup
                                : null,
                            hint: const Text(
                              'छान्नुस्',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            items: _bloodGroupOptions
                                .map(
                                  (bg) => DropdownMenuItem(
                                    value: bg,
                                    child: Text(bg),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBloodGroup = v!),
                          ),
                        ),
                      )
                    : _infoBox(
                        label: 'रगत समूह',
                        value: _selectedBloodGroup.isNotEmpty
                            ? _selectedBloodGroup
                            : '—',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Read-only info box (view mode).
  Widget _infoBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  /// Styled container used for edit-mode fields (date picker, dropdowns, text).
  Widget _styledBox({
    required String label,
    required Widget child,
    bool editing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: editing ? const Color(0xFFFFF8F8) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: editing
              ? const Color(0xFFB71C1C).withOpacity(0.4)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  // ── Medical history card ──────────────────
  Widget _buildMedicalHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🩺', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Text(
                'चिकित्सा इतिहास',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (_editing)
                GestureDetector(
                  onTap: _showAddConditionDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 14, color: Color(0xFFB71C1C)),
                        SizedBox(width: 3),
                        Text(
                          'थप्नुस्',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB71C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_conditions.isEmpty)
            const Text(
              'कुनै रेकर्ड छैन',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            )
          else
            ...List.generate(
              _conditions.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB71C1C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _conditions[i],
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (_editing)
                      GestureDetector(
                        onTap: () => setState(() => _conditions.removeAt(i)),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddConditionDialog() {
    _conditionCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'रोग थप्नुस्',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _conditionCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'जस्तै: Hypertension',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = _conditionCtrl.text.trim();
              if (val.isNotEmpty) setState(() => _conditions.add(val));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('थप्नुस्', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Settings card ─────────────────────────
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚙️', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'सेटिङ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          // Language
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    size: 18,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'भाषा / Language',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'नेपाली',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [LanguageToggleButton()],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF0F0F0),
          ),
          // Low data mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.data_saver_on,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'कम डेटा मोड',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Low Data Mode',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: AppSettings.of(context).lowDataMode,
                  onChanged: (val) =>
                      AppSettings.of(context).setLowDataMode(val),
                  activeTrackColor: const Color(0xFFB71C1C),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF0F0F0),
          ),
          // Change password
          InkWell(
            onTap: () {
              Get.to(() => ChangePasswordScreen(),transition: Transition.downToUp);
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'पासवर्ड परिवर्तन गर्नुहोस्',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout, size: 18, color: Color(0xFFB71C1C)),
        label: const Text(
          'लगआउट / Logout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB71C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'लगआउट',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text('के तपाईं लगआउट गर्न चाहनुहुन्छ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
              await _service.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('लगआउट', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Shared underline text input ───────────
  Widget _inputField(
    TextEditingController ctrl, {
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
