import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001/api'; // Chrome
    } else {
      return 'http://10.0.2.2:8001/api'; // Android emulator
    }
  }

  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Attach Supabase JWT if available
            final session = Supabase.instance.client.auth.currentSession;
            debugPrint('🔑 Session exists: ${session != null}');
            debugPrint(
              '🔑 Token: ${session?.accessToken?.substring(0, 30) ?? "NULL"}',
            );

            if (session != null) {
              options.headers['Authorization'] =
                  'Bearer ${session.accessToken}';
            } else {
              // If no session, you may want to handle this (e.g., redirect to login)
              debugPrint(
                '⚠️ No Supabase session found; request will be unauthenticated.',
              );
            }
            return handler.next(options);
          },
      onError: (DioException e, handler) async {
            // Only retry ONCE — track with a flag in requestOptions.extra
            if (e.response?.statusCode == 401 &&
                e.requestOptions.extra['retried'] != true) {
              try {
                await Supabase.instance.client.auth.refreshSession();
                final newSession = Supabase.instance.client.auth.currentSession;
                if (newSession != null) {
                  e.requestOptions.headers['Authorization'] =
                      'Bearer ${newSession.accessToken}';
                  e.requestOptions.extra['retried'] = true; // ← prevent loop
                  final retry = await _dio!.fetch(e.requestOptions);
                  return handler.resolve(retry);
                }
              } catch (_) {}
            }
            return handler.next(e);
          },
        ),
      );
    }
    return _dio!;
  }


  static Future<Map<String, dynamic>> bookAppointment({
    required int doctorTableId,
    required String consultationType,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? patientNotes,
  }) async {
    try {
      final res = await dio.post(
        '/appointments/',
        data: {
          'doctor_id': doctorTableId,
          'consultation_type': consultationType,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'duration_minutes': durationMinutes,
          'patient_notes': patientNotes,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check booked slots for a doctor on a given date
  static Future<List<String>> checkSlotAvailability({
    required int doctorTableId,
    required DateTime date,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final res = await dio.post(
        '/appointments/check-slots',
        data: {'doctor_id': doctorTableId, 'date': dateStr},
      );
      final data = res.data as Map<String, dynamic>;
      return List<String>.from(data['booked_slots'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all my appointments
  static Future<List<Map<String, dynamic>>> getMyAppointments() async {
    try {
      final res = await dio.get('/appointments/');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get upcoming appointments (next 7 days)
  static Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final res = await dio.get('/appointments/upcoming/list');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Filter appointments by status
  static Future<List<Map<String, dynamic>>> getAppointmentsByStatus(
    String status,
  ) async {
    try {
      final res = await dio.get('/appointments/filter/$status');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single appointment by ID
  static Future<Map<String, dynamic>> getAppointment(
    String appointmentId,
  ) async {
    try {
      final res = await dio.get('/appointments/$appointmentId');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel an appointment
  static Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId,
  ) async {
    try {
      final res = await dio.patch('/appointments/$appointmentId/cancel');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }



  /// Fetch doctors by specialty and optional location filters
  static Future<List<Map<String, dynamic>>> fetchDoctors({
    required String specialty,
    String? province,

    String? district,
    String? municipality,
  }) async {
    final params = <String, dynamic>{'specialty': specialty};
    if (province != null && province.isNotEmpty) {
      params['province'] = province;
    }
    if (district != null) params['district'] = district;
    if (municipality != null && municipality.isNotEmpty)
      params['municipality'] = municipality;

    final res = await dio.get('/doctors/', queryParameters: params);
    return List<Map<String, dynamic>>.from(res.data);
  }
 
  static String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'सर्भरसँग जडान गर्न समय लाग्यो। पुनः प्रयास गर्नुहोस्।';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'इन्टरनेट जडान छैन वा सर्भर बन्द छ।';
    }

    final statusCode = e.response?.statusCode;
    final detail = e.response?.data is Map
        ? e.response?.data['detail'] ?? 'अज्ञात त्रुटि'
        : 'अज्ञात त्रुटि';

    switch (statusCode) {
      case 400:
        return 'अनुरोध गलत छ: $detail';
      case 401:
        return 'लग इन आवश्यक छ।';
      case 403:
        return 'यो काम गर्न अनुमति छैन।';
      case 404:
        return 'डाटा भेटिएन।';
      case 409:
        return 'यो समय अहिले बुक भयो। अर्को छान्नुहोस्।';
      case 500:
        return 'सर्भर त्रुटि। पछि पुनः प्रयास गर्नुहोस्।';
      default:
        return detail.toString();
    }
  }
}
