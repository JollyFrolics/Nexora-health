import 'package:patient_app/models/patients_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────
class PatientService {
  final _supabase = Supabase.instance.client;

  SupabaseQueryBuilder get _patients => _supabase.from('patients');
  SupabaseQueryBuilder get _userProfiles => _supabase.from('user_profiles');
  GoTrueClient get _auth => _supabase.auth;

  Future<PatientProfile?> fetchMyProfile() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return null;

    final results = await Future.wait([
      _userProfiles.select().eq('id', uid).maybeSingle(),
      _patients.select().eq('user_id', uid).maybeSingle(),
    ]);

    final userProfile = results[0];
    final patient = results[1];

    if (userProfile == null) return null;

    return PatientProfile.fromBoth(
      userProfile: userProfile,
      patient: patient ?? {},
    );
  }

  Future<void> saveProfile(PatientProfile p) async {
    await Future.wait([
      _patients.upsert(p.toPatientUpsert(), onConflict: 'user_id'),
      _userProfiles.update(p.toUserProfileUpdate()).eq('id', p.userId),
    ]);
  }

  Future<void> signOut() async => _auth.signOut();
}
