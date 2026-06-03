import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/student_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/global_bottom_bar.dart';
import '../screens/payment_screen.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  final String studentName;

  const FeesScreen({super.key, required this.studentName});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _paymentInfo;

  @override
  void initState() {
    super.initState();
    _fetchPaymentInfo();
  }

  Future<void> _fetchPaymentInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await StudentService.getPaymentInfo();

    if (mounted) {
      if (response['success']) {
        setState(() {
          _paymentInfo = response['data']['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load fees details';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Fees & Plans',
          style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Fees'),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 2), // Index 2 is Fees
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.coral),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16, color: AppColors.textGray),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPaymentInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_paymentInfo == null) {
      return const Center(child: Text('No details available'));
    }

    final hasSubscription = _paymentInfo!['has_active_subscription'] ?? false;
    final feesData = _paymentInfo!['fees'];
    final classData = _paymentInfo!['class'];
    final currentSubscription = _paymentInfo!['current_subscription'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSubscription) ...[
            _buildActivePlanCard(currentSubscription, classData, feesData),
          ] else ...[
            _buildPendingFeesCard(classData, feesData),
          ],
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(dynamic subscription, dynamic classData, dynamic feesData) {
    final subDateStr = subscription['subscription_date'];
    final expiryDateStr = subscription['expiry_date'];
    final className = classData['name'] ?? 'Class';
    
    final subDate = subDateStr != null ? DateTime.tryParse(subDateStr) : null;
    final expiryDate = expiryDateStr != null ? DateTime.tryParse(expiryDateStr) : null;
    
    final subDateFormatted = subDate != null ? DateFormat('dd MMM yyyy').format(subDate) : 'Unknown';
    final expiryDateFormatted = expiryDate != null ? DateFormat('dd MMM yyyy').format(expiryDate) : 'Unknown';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50), // Green for active
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE PLAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$className Plan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have full access to all video lessons and practice activities.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlanDetailColumn('Subscribed On', subDateFormatted),
              _buildPlanDetailColumn('Valid Till', expiryDateFormatted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingFeesCard(dynamic classData, dynamic feesData) {
    final amount = double.tryParse(feesData['amount']?.toString() ?? '0') ?? 0.0;
    final className = classData['name'] ?? 'Class';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending_actions, color: AppColors.deepOrange, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'PAYMENT REQUIRED',
                      style: TextStyle(
                        color: AppColors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet, color: AppColors.primaryOrange, size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$className Plan',
            style: const TextStyle(
              color: AppColors.darkNavy,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock all video lessons and practice tests for $className.',
            style: TextStyle(
              color: AppColors.textGray.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.darkNavy,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        classId: classData['id'].toString(),
                        subjectId: '', // General payment doesn't need subject
                        feeId: feesData['id'].toString(),
                        amount: amount.toString(),
                        studentName: widget.studentName,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchPaymentInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
