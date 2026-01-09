import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const ProfileEditScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Selected Interests/Showcase
  final List<String> _allInterests = [
    'Mathematics',
    'Science',
    'Art & Drawing',
    'Reading',
    'Coding',
    'Music',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
    'English Literature',
    'Hindi',
    'Sanskrit',
    'Drawing & Craft',
    'Dance (Classical)',
    'Dance (Western)',
    'Photography',
    'Chess',
    'Cricket',
    'Football',
    'Basketball',
    'Robotics & AI',
    'Gardening',
    'Yoga & Meditation',
    'Debate & Public Speaking',
    'Storytelling',
    'Vocal Music',
    'Instrumental Music',
    'Photography & Videography',
    'Cooking',
    'Magic & Tricks',
    'Science Experiments',
    'Languages (French, Spanish, etc.)',
    'Environment & Nature',
  ];

  final Set<String> _selectedInterests = {
    'Mathematics',
    'Science',
    'Coding',
    'Hindi',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.darkNavy,
            size: 18, // Smaller size as requested
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Text(
                  'Customize Your Profile!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Center(
                child: Text(
                  'Make your profile uniquely yours!',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ),
              const SizedBox(height: 30),

              // Profile Image Upload
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.5),
                          width: 4,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/profile.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Show Camera/Gallery options
                          showModalBottomSheet(
                            context: context,
                            builder:
                                (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  height: 160,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Change Profile Picture',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Simulate Camera pick
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Opening Camera...',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    size: 30,
                                                    color:
                                                        AppColors.primaryOrange,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text('Camera'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Simulate Gallery pick
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Opening Gallery...',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.photo_library,
                                                    size: 30,
                                                    color:
                                                        AppColors.primaryOrange,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text('Gallery'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Full Name
              const Text('Your Full Name', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Interests / Showcase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Interests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Save Interests Logic
                      setState(() {
                        _isLoading = true;
                      });

                      // Simulate API call
                      await Future.delayed(const Duration(milliseconds: 800));

                      setState(() {
                        _isLoading = false;
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Interests saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryOrange),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white, // ensure touch target
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Select what you\'re interested in learning about:',
                style: TextStyle(fontSize: 13, color: AppColors.textGray),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: AppColors.primaryOrange,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkNavy,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.inputBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.primaryOrange
                                    : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 30),

              // Security Section
              const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'gopi@gmail.com',
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
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
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Confirm Password',
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
                  if (_passwordController.text.isNotEmpty &&
                      value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? () {} : _handleSave,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
