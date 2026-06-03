import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/student_service.dart';
import 'package:intl/intl.dart';

class SupportHistoryScreen extends StatefulWidget {
  final String studentName;

  const SupportHistoryScreen({super.key, required this.studentName});

  @override
  State<SupportHistoryScreen> createState() => _SupportHistoryScreenState();
}

class _SupportHistoryScreenState extends State<SupportHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final result = await StudentService.getSupportHistory();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _history = result['data']['data'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Support History',
          style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.textGray.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No support history found.',
              style: TextStyle(fontSize: 16, color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final dateStr = item['created_at'];
        String formattedDate = '';
        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
          }
        }
        
        final reply = item['reply'];
        final hasReply = reply != null && reply.toString().trim().isNotEmpty;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['subject'] ?? 'No Subject',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasReply ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasReply ? 'Resolved' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasReply ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['message'] ?? '',
                    style: const TextStyle(fontSize: 14, color: AppColors.darkNavy),
                  ),
                ),
                if (hasReply) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Reply:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reply.toString(),
                      style: const TextStyle(fontSize: 14, color: AppColors.darkNavy),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
