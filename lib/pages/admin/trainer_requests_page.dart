import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import 'package:intl/intl.dart';

class TrainerRequestsPage extends StatefulWidget {
  const TrainerRequestsPage({super.key});

  @override
  State<TrainerRequestsPage> createState() => _TrainerRequestsPageState();
}

class _TrainerRequestsPageState extends State<TrainerRequestsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final requests = await AdminApiService.getTrainerRequests();
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(int requestId) async {
    final success = await AdminApiService.approveTrainerRequest(requestId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved. User is now a TRAINER.'),
        ),
      );
      _loadRequests();
    }
  }

  Future<void> _handleReject(int requestId, String email) async {
    final success = await AdminApiService.rejectTrainerRequest(requestId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request rejected. Rejection email sent to $email.'),
        ),
      );
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trainer Sign-up Requests',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2F),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadRequests,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B58E6)),
                  )
                : _requests.isEmpty
                ? const Center(
                    child: Text(
                      'No pending requests',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      final date = DateTime.tryParse(req['createdAt'] ?? '');
                      final dateStr = date != null
                          ? DateFormat('dd MMM yyyy').format(date)
                          : '-';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(
                                  0xFF6B58E6,
                                ).withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF6B58E6),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req['user']?['name'] ?? 'Unknown User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      req['user']?['email'] ?? '-',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Bio: ${req['bio'] ?? '-'}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Experience: ${req['experience'] ?? '-'}',
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Submitted: $dateStr',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.download),
                                    label: const Text('View CV'),
                                  ),
                                  const SizedBox(height: 12),
                                  if (req['status'] == 'PENDING')
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleApprove(req['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text(
                                            'Approve',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () =>
                                              _handleReject(req['id'], req['user']?['email'] ?? 'unknown'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    )
                                  else
                                    Chip(label: Text(req['status'] ?? '-')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
