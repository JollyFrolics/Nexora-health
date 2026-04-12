import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


class _Contact {
  final String titleNe;
  final String titleEn;
  final String number;
  final String descNe;
  final String descEn;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isPrimary; // big card treatment

  const _Contact({
    required this.titleNe,
    required this.titleEn,
    required this.number,
    required this.descNe,
    required this.descEn,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.isPrimary = false,
  });
}

const List<_Contact> _primaryContacts = [
  _Contact(
    titleNe: 'एम्बुलेन्स',
    titleEn: 'Ambulance',
    number: '102',
    descNe: 'राष्ट्रिय एम्बुलेन्स सेवा',
    descEn: 'National Ambulance Service',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFB71C1C),
    bgColor: Color(0xFFFFEBEE),
    isPrimary: true,
  ),
  _Contact(
    titleNe: 'प्रहरी',
    titleEn: 'Police',
    number: '100',
    descNe: 'नेपाल प्रहरी',
    descEn: 'Nepal Police',
    icon: Icons.local_police_rounded,
    color: Color(0xFF1565C0),
    bgColor: Color(0xFFE3F2FD),
    isPrimary: true,
  ),
];

const List<_Contact> _secondaryContacts = [
  _Contact(
    titleNe: 'दमकल सेवा',
    titleEn: 'Fire Brigade',
    number: '101',
    descNe: 'दमकल तथा उद्धार सेवा',
    descEn: 'Fire & Rescue Service',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFE65100),
    bgColor: Color(0xFFFFF3E0),
  ),
  _Contact(
    titleNe: 'सशस्त्र प्रहरी',
    titleEn: 'Armed Police',
    number: '103',
    descNe: 'सशस्त्र प्रहरी बल',
    descEn: 'Armed Police Force',
    icon: Icons.shield_rounded,
    color: Color(0xFF2E7D32),
    bgColor: Color(0xFFE8F5E9),
  ),
  _Contact(
    titleNe: 'नेपाल रेडक्रस',
    titleEn: 'Red Cross',
    number: '4270650',
    descNe: 'नेपाल रेडक्रस सोसाइटी',
    descEn: 'Nepal Red Cross Society',
    icon: Icons.medical_services_rounded,
    color: Color(0xFFC62828),
    bgColor: Color(0xFFFFEBEE),
  ),
  _Contact(
    titleNe: 'विष नियन्त्रण',
    titleEn: 'Poison Control',
    number: '9851255834',
    descNe: 'विष उपचार केन्द्र',
    descEn: 'Poison Treatment Center',
    icon: Icons.warning_rounded,
    color: Color(0xFF6A1B9A),
    bgColor: Color(0xFFF3E5F5),
  ),
  _Contact(
    titleNe: 'मानसिक स्वास्थ्य',
    titleEn: 'Mental Health',
    number: '1660-0102005',
    descNe: 'सहारा हेल्पलाइन',
    descEn: 'Sahara Helpline',
    icon: Icons.favorite_rounded,
    color: Color(0xFF00695C),
    bgColor: Color(0xFFE0F2F1),
  ),
  _Contact(
    titleNe: 'स्वास्थ्य हेल्पलाइन',
    titleEn: 'Health Helpline',
    number: '1115',
    descNe: 'स्वास्थ्य तथा जनसंख्या मन्त्रालय',
    descEn: 'Ministry of Health & Population',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF1B5E8A),
    bgColor: Color(0xFFE1F5FE),
  ),
];




class EmergencyCallscreen extends StatefulWidget {
  const EmergencyCallscreen({super.key});

  @override
  State<EmergencyCallscreen> createState() => _EmergencyCallscreenState();
}

class _EmergencyCallscreenState extends State<EmergencyCallscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _call(String number, String name) async {
    // Show confirm dialog before dialing
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFFB71C1C),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'नम्बर / Number:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'यो नम्बरमा कल गर्न चाहनुहुन्छ?',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('रद्द', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.phone_rounded, size: 16),
            label: const Text('कल गर्नुहोस्'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clean number — remove dashes and spaces
    final cleaned = number.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: copy to clipboard
        await Clipboard.setData(ClipboardData(text: number));
        if (mounted) {
          Get.snackbar(
            'नम्बर कपी गरियो',
            '$number क्लिपबोर्डमा कपी गरियो',
            backgroundColor: const Color(0xFFEAF7EF),
            colorText: const Color(0xFF1A7A4A),
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: number));
      if (mounted) {
        Get.snackbar(
          'नम्बर कपी गरियो',
          '$number कपी गरियो',
          backgroundColor: const Color(0xFFEAF7EF),
          colorText: const Color(0xFF1A7A4A),
          borderRadius: 12,
          margin: const EdgeInsets.all(12),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'आपतकालीन सम्पर्क',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              'Emergency',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _AlertBanner(pulse: _pulse),
            const SizedBox(height: 20),

            const _SectionLabel(
              ne: 'मुख्य आपतकालीन सेवाहरू',
              en: 'Primary Emergency Services',
            ),
            const SizedBox(height: 12),
            Row(
              children: _primaryContacts
                  .map(
                    (c) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: c == _primaryContacts.first ? 8 : 0,
                          left: c == _primaryContacts.last ? 8 : 0,
                        ),
                        child: _PrimaryCard(
                          contact: c,
                          onCall: () =>
                              _call(c.number, '${c.titleNe} (${c.titleEn})'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            const _SectionLabel(
              ne: 'अन्य आपतकालीन सेवाहरू',
              en: 'Other Emergency Services',
            ),
            const SizedBox(height: 12),
            ...(_secondaryContacts.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SecondaryCard(
                  contact: c,
                  onCall: () => _call(c.number, '${c.titleNe} (${c.titleEn})'),
                ),
              ),
            )),
            const SizedBox(height: 24),

            const _SafetyTips(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final AnimationController pulse;
  const _AlertBanner({required this.pulse});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFB71C1C),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, child) => Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1 + pulse.value * 0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3 + pulse.value * 0.3),
                width: 2,
              ),
            ),
            child: child,
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'आपतकालीन अवस्थामा',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'तुरुन्त तलका नम्बरहरूमा सम्पर्क गर्नुहोस्',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'In an emergency, call the numbers below immediately',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



class _SectionLabel extends StatelessWidget {
  final String ne, en;
  const _SectionLabel({required this.ne, required this.en});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ne,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(en, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    ],
  );
}




class _PrimaryCard extends StatelessWidget {
  final _Contact contact;
  final VoidCallback onCall;
  const _PrimaryCard({required this.contact, required this.onCall});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onCall,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: contact.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(contact.icon, color: contact.color, size: 26),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            contact.titleNe,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: contact.color,
            ),
          ),
          Text(
            contact.titleEn,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          // Number — big
          Text(
            contact.number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: contact.color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            contact.descNe,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          // Call button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: contact.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'कल गर्नुहोस्',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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




class _SecondaryCard extends StatelessWidget {
  final _Contact contact;
  final VoidCallback onCall;
  const _SecondaryCard({required this.contact, required this.onCall});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
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
        // Left colored accent
        Container(
          width: 6,
          height: 76,
          decoration: BoxDecoration(
            color: contact.color,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
          ),
        ),
        // Icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: contact.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(contact.icon, color: contact.color, size: 22),
          ),
        ),
        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.titleNe,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${contact.titleEn}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  contact.number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: contact.color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.descNe,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
        // Call button
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: onCall,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: contact.bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: contact.color.withOpacity(0.3)),
              ),
              child: Icon(Icons.phone_rounded, color: contact.color, size: 20),
            ),
          ),
        ),
      ],
    ),
  );
}




class _SafetyTips extends StatelessWidget {
  const _SafetyTips();

  static const _tips = [
    ('शान्त रहनुहोस्', 'Keep calm — speak clearly and slowly'),
    ('आफ्नो ठेगाना स्पष्ट भन्नुहोस्', 'State your exact location clearly'),
    ('के भयो भनी बताउनुहोस्', 'Describe what happened'),
    ('फोन नराख्नुहोस्', 'Don\'t hang up until told to do so'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFE082)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.tips_and_updates_rounded,
              color: Color(0xFFE65100),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'कल गर्दा याद राख्नुहोस् / Call tips',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._tips.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE65100),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value.$1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        e.value.$2,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
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
