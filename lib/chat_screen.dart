import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/models/appointment_model.dart';
import 'package:patient_app/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Appt? appt;
  const ChatScreen({super.key, this.appt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _loading = false;
  String? _error;
  List<Appt> _chatAppointments = [];

  @override
  void initState() {
    super.initState();
    if (widget.appt == null) _loadChatAppointments();
  }

  Future<void> _loadChatAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ApiService.getMyAppointmentsEnriched();
      final all = rows.map(Appt.fromApi).toList();
      final chatItems = all
          .where((a) =>
      (a.consultType.toLowerCase() == 'chat' || a.consultType.toLowerCase() == 'message') &&
          a.status != 'cancelled' &&
          a.status != 'no_show')
          .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      if (!mounted) return;
      setState(() {
        _chatAppointments = chatItems;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appt;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(appt == null ? 'Chats' : 'Dr. ${appt.doctorName}'),
      ),
      body: appt != null ? _buildConversation(appt) : _buildChatList(),
    );
  }

  Widget _buildChatList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Unable to load chats', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadChatAppointments, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_chatAppointments.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No chat appointments found.', textAlign: TextAlign.center)));
    }
    return RefreshIndicator(
      onRefresh: _loadChatAppointments,
      color: AppConstants.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _chatAppointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _chatAppointments[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Get.to(() => ChatScreen(appt: item)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: Text(
                        item.initials,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${item.doctorName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(item.dateTimeLabel, style: const TextStyle(color: Colors.grey)),
                          if (item.specialty.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(item.specialty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversation(Appt appt) {
    final avatarUrl = (appt.avatarUrl != null && appt.avatarUrl!.isNotEmpty) ? appt.avatarUrl : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(appt.initials, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.primaryColor))
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Dr. ${appt.doctorName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(appt.dateTimeLabel, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text('Chat UI goes here.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}