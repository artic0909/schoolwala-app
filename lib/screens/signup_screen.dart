import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../services/common_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  // Form controllers
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childAgeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _selectedClass;

  int _currentPage = 0;
  Timer? _carouselTimer;

  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  // Carousel images
  final List<String> _carouselImages = [
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/7.jpeg',
  ];

  List<Map<String, dynamic>> _classes = [];
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _setupArrowAnimation();
    _startCarouselAutoPlay();
  }

  Future<void> _fetchClasses() async {
    try {
      final classes = await CommonService.getClasses();
      if (mounted) {
        setState(() {
          // We expect a list of objects or maps
          if (classes.isNotEmpty) {
            _classes =
                classes.map((e) {
                  if (e is Map) {
                    return {
                      'id': e['id'].toString(),
                      'name': e['name'].toString(),
                    };
                  }
                  // Fallback if it's just strings (unlikely given the error)
                  return {'id': e.toString(), 'name': e.toString()};
                }).toList();
          }
          _isLoadingClasses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClasses = false;
          _classes = []; // Use empty list on error
        });
      }
    }
  }

  void _setupArrowAnimation() {
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startCarouselAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _carouselImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _scrollToForm() {
    _scrollController.animateTo(
      MediaQuery.of(context).size.height,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    _arrowAnimationController.dispose();
    _parentNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms & Conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final registerData = {
        'parent_name': _parentNameController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
        'student_name': _childNameController.text,
        'age': _childAgeController.text,
        'class_id': _selectedClass ?? '',
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      final result = await AuthService.register(registerData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Successful. Please Login.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to login or dashboard
          Navigator.of(context).pop(); // Pops back to login if came from there
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Split-screen landing section
            SizedBox(
              height: screenHeight,
              child: Column(
                children: [
                  // Top half - Image Carousel
                  Expanded(
                    child: Stack(
                      children: [
                        // Image PageView
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _carouselImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                                child: Image.asset(
                                  _carouselImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: AppColors.orangeGradient,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        // Page indicators
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _carouselImages.length,
                              (index) =>
                                  _buildPageIndicator(index == _currentPage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom half - Intro content
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Scroll button (moved to top)
                          GestureDetector(
                            onTap: _scrollToForm,
                            child: AnimatedBuilder(
                              animation: _arrowAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _arrowAnimation.value),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryOrange
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Scroll Up to Signup',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const Spacer(),

                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.school,
                                  size: 50,
                                  color: AppColors.primaryOrange,
                                );
                              },
                            ),
                          ),

                          const Spacer(),

                          // Title + Subtitle group
                          Column(
                            children: [
                              const Text(
                                'Make Your Future',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkNavy,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Join the Schoolwala community',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Registration form section
            _buildRegistrationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent's Name
                CustomTextField(
                  controller: _parentNameController,
                  label: "Parent's Name",
                  hintText: "Enter Parent's Name",
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter parent's name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email Address
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'sosi@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mobile Number
                CustomTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  hintText: '1234567890',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Student's Name
                CustomTextField(
                  controller: _childNameController,
                  label: "Student's Name",
                  hintText: "Enter Student's Name",
                  prefixIcon: Icons.child_care_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Student's name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Student's Age
                CustomTextField(
                  controller: _childAgeController,
                  label: "Student's Age",
                  hintText: "Enter Student's Age",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.cake_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Student's age";
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 5 || age > 18) {
                      return 'Please enter a valid age (5-18)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Select Class Dropdown
                const Text('Select Class', style: AppTextStyles.inputLabel),
                const SizedBox(height: 8),
                _isLoadingClasses
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        hintText: 'Choose Class',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGray.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                          color: AppColors.textGray,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items:
                          _classes.map<DropdownMenuItem<String>>((
                            Map<String, dynamic> classItem,
                          ) {
                            return DropdownMenuItem<String>(
                              value: classItem['id'],
                              child: Text(classItem['name']),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClass = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a class';
                        }
                        return null;
                      },
                    ),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: '••••••••',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Terms and Conditions
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text(
                            'I agree to the ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGray,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Open Terms & Conditions
                            },
                            child: const Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryOrange,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                    : CustomButton(text: 'Sign Up', onPressed: _handleSignUp),

                const SizedBox(height: 20),

                // Already have account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textGray),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
