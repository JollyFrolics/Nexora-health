class DoctorInfo {
  final String id; 
  final int doctorTableId; 
  final String name, specialty, hospital;
  final String province, district, municipality;
  final String qualification, licenseNumber;
  final int? experienceYears;
  final double rating;
  final bool isVerified, isAvailable;
  final String? avatarUrl;
  final String phone, email;

  const DoctorInfo({
    required this.id,
    required this.doctorTableId,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.province,
    required this.district,
    required this.municipality,
    required this.qualification,
    required this.licenseNumber,
    this.experienceYears,
    required this.rating,
    required this.isVerified,
    required this.isAvailable,
    this.avatarUrl,
    required this.phone,
    required this.email,
  });

  factory DoctorInfo.fromMap(Map<String, dynamic> m) {
   
    dynamic profilesRaw = m['user_profiles'];
    Map<String, dynamic>? profile;

    if (profilesRaw is List && profilesRaw.isNotEmpty) {
      profile = Map<String, dynamic>.from(profilesRaw.first);
    } else if (profilesRaw is Map<String, dynamic>) {
      profile = profilesRaw;
    }

    return DoctorInfo(
      id: m['user_id']?.toString() ?? '',
      doctorTableId: m['id'] as int? ?? 0,
      name: profile?['full_name']?.toString() ?? 'Unknown Doctor',
      specialty: m['specialty']?.toString() ?? '',
      hospital: m['healthpost_name']?.toString() ?? '',
      province: profile?['province']?.toString() ?? '',
      district: profile?['district']?.toString() ?? '',
      municipality: profile?['municipality']?.toString() ?? '',
      qualification: m['qualification']?.toString() ?? '',
      licenseNumber: m['license_number']?.toString() ?? '',
      experienceYears: m['experience_years'] as int?,
      rating: double.tryParse(m['rating']?.toString() ?? '') ?? 4.5,
      isVerified: m['is_verified'] as bool? ?? false,
      isAvailable: m['is_active'] as bool? ?? true,
      avatarUrl: profile?['avatar_url']?.toString(),
      phone: profile?['phone']?.toString() ?? '',
      email: profile?['email']?.toString() ?? '',
    );
  }
  String get initials {
    final pts = name.trim().split(' ');
    if (pts.length >= 2) return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }
}
