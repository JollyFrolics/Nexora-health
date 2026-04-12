import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/models/doctor_model.dart';
import 'package:patient_app/widgets/image.dart';

class DoctorInitials extends StatelessWidget {
  final String initials;

  const DoctorInitials(this.initials, {super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppConstants.primaryColor,
      ),
    ),
  );
}

class DChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DChip(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppConstants.primaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildAvatar(DoctorInfo doctor) {
  final url = doctor.avatarUrl;

  if (url != null && url.isNotEmpty) {
    return ClipOval(
      child:SafeNetworkImage(url: doctor.avatarUrl)
    );
  }

  return DoctorInitials(doctor.initials);
}

class DoctorCard extends StatelessWidget {
  final DoctorInfo doctor;
  final bool isSelected;
  final ValueChanged<DoctorInfo> onSelect;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onSelect(doctor),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppConstants.primaryColor.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppConstants.primaryColor
              : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppConstants.primaryColor, width: 2)
                        : null,
                  ),
                  child: _buildAvatar(doctor),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'डा. ${doctor.name}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppConstants.primaryColor
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),

                          if (doctor.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7EF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 11,
                                    color: Color(0xFF27AE60),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'NMC',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A7A4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor.withOpacity(0.8),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        doctor.hospital,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Rating
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < doctor.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 13,
                              color: const Color(0xFFF39C12),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Availability
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: doctor.isAvailable
                        ? const Color(0xFFEAF7EF)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    doctor.isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: doctor.isAvailable
                          ? const Color(0xFF1A7A4A)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                Container(
                  height: 0.5,
                  color: const Color(0xFFF1F5F9),
                  margin: const EdgeInsets.only(bottom: 10),
                ),

                Row(
                  children: [
                    DChip(
                      Icons.school_outlined,
                      doctor.qualification.isEmpty
                          ? 'MBBS'
                          : doctor.qualification,
                    ),
                    const SizedBox(width: 8),
                    DChip(
                      Icons.workspace_premium_outlined,
                      'NMC #${doctor.licenseNumber}',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [
                          if (doctor.municipality.isNotEmpty)
                            doctor.municipality,
                          if (doctor.district.isNotEmpty) doctor.district,
                          if (doctor.province.isNotEmpty) doctor.province,
                        ].join(', '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
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
  );
}
