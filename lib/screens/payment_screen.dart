// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../constants/app_constants.dart';
import '../services/student_service.dart';
import '../services/auth_service.dart';
import '../utils/toast_helper.dart';

class PaymentScreen extends StatefulWidget {
  final String studentName;
  final String className;
  final String feeId;
  final String amount;
  final String subjectId;
  final String classId;
  final String? qrCodeUrl; // Kept for backward compatibility but won't be displayed

  const PaymentScreen({
    super.key,
    required this.studentName,
    this.className = 'Class 8',
    required this.feeId,
    required this.amount,
    required this.subjectId,
    required this.classId,
    this.qrCodeUrl,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _amount;
  String? _feeId;

  bool _isSubmitting = false;
  bool _isLoadingFees = false;
  
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _amount = widget.amount;
    _feeId = widget.feeId;

    _studentNameController.text = widget.studentName;
    _classController.text = widget.className;
    _amountController.text = widget.amount;
    
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadUserData();
    _fetchFeesInfo();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchFeesInfo() async {
    setState(() => _isLoadingFees = true);
    try {
      final result = await StudentService.getPaymentInfo();
      if (result['success'] && result['data'] != null) {
        final apiResponse = result['data'];
        final data = apiResponse['data'] ?? apiResponse;

        final classInfo = data['class'];
        if (classInfo != null && mounted) {
          setState(() {
            String className =
                classInfo['name'] ??
                classInfo['class_name'] ??
                widget.className;
            _classController.text = className;
          });
        }

        final fees = data['fees'];
        if (fees != null && mounted) {
          setState(() {
            _amount = fees['amount']?.toString();
            _amountController.text = _amount ?? '';
            _feeId = fees['id']?.toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching fees info: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFees = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          // Some structures nest the user details under 'student'
          final studentData = user.containsKey('student') ? user['student'] : user;
          
          _emailController.text = studentData['email'] ?? '';
          _phoneController.text = studentData['phone'] ?? studentData['mobile'] ?? '';
          _studentNameController.text =
              studentData['student_name'] ?? studentData['name'] ?? widget.studentName;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _startRazorpayPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      // 1. Create Order on Backend
      final orderResult = await StudentService.createRazorpayOrder({
        'class_id': widget.classId,
        'fees_id': _feeId ?? widget.feeId,
      });

      if (!orderResult['success']) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ToastHelper.showError(context, orderResult['message'] ?? 'Failed to create order');
        return;
      }

      // The API response is wrapped in { success: ..., data: ..., message: ... }
      // AND StudentService returns { success: true, data: json.decode(response.body) }
      // So orderResult['data'] is the full JSON response body. The actual order is inside orderResult['data']['data']
      final apiResponse = orderResult['data'];
      final orderData = apiResponse['data'] ?? apiResponse;
      
      final String orderId = orderData['order_id'];
      final String key = orderData['key'];
      
      final amountRaw = orderData['amount'];
      final num amountInRupees = amountRaw is num ? amountRaw : num.tryParse(amountRaw.toString()) ?? 0;
      final int amountInPaise = (amountInRupees * 100).toInt();

      // 2. Setup Razorpay Options
      var options = {
        'key': key,
        'amount': amountInPaise,
        'name': 'Schoolwala',
        'order_id': orderId,
        'description': 'Subscription for ${_classController.text}',
        'prefill': {
          'contact': _phoneController.text,
          'email': _emailController.text,
          'name': _studentNameController.text
        },
        'theme': {
          'color': '#4f46e5'
        }
      };

      // 3. Open Razorpay Checkout
      // The state will be reset when the callback handlers run
      _razorpay.open(options);

    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ToastHelper.showError(context, 'Error initiating payment: $e');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify payment with backend
      final verifyResult = await StudentService.verifyRazorpayPayment({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
        'class_id': widget.classId,
        'fees_id': _feeId ?? widget.feeId,
        'subject_id': widget.subjectId,
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        
        if (verifyResult['success']) {
          ToastHelper.showSuccess(context, 'Payment successful! Your subscription is active.');
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context, true);
          });
        } else {
          ToastHelper.showError(context, verifyResult['message'] ?? 'Payment verification failed.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ToastHelper.showError(context, 'Error verifying payment: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isSubmitting = false);
      ToastHelper.showError(context, 'Payment Failed: ${response.message ?? "Unknown error"}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      setState(() => _isSubmitting = false);
      ToastHelper.showInfo(context, 'External wallet selected: ${response.walletName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4f46e5), Color(0xFF6366f1)], // Modern Indigo gradient
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x334f46e5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      )
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure Checkout',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your payment in seconds',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingFees)
              const LinearProgressIndicator(
                backgroundColor: AppColors.primaryOrange,
                color: Colors.white,
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Subscription Details Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)], // Slate dark
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.subscriptions,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Class:', _classController.text),
                        const Divider(color: Colors.white24, height: 24),
                        _buildDetailRow('Student:', _studentNameController.text),
                        const Divider(color: Colors.white24, height: 24),
                        _buildDetailRow('Amount:', '₹${_amount ?? widget.amount}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Details Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Billing Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verify your details before proceeding to payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildInputField(
                            'Student Name',
                            _studentNameController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            'Email Address',
                            _emailController,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            'Phone Number',
                            _phoneController,
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSubmitting || _isLoadingFees ? null : _startRazorpayPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4f46e5), // Razorpay brand color matches web theme
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFF4f46e5).withValues(alpha: 0.5),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.security, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Pay ₹${_amount ?? widget.amount} Securely',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, size: 14, color: AppColors.textGray),
                                const SizedBox(width: 4),
                                Text(
                                  'Payments are 100% secure and encrypted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGray,
                                    fontFamily: 'Poppins',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.inputLabel,
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: textColor ?? AppColors.darkNavy,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryOrange,
                width: 2,
              ),
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
