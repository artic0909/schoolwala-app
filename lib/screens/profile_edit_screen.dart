import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const ProfileEditScreen({super.key, required this.profileData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

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

  Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    final student = widget.profileData['student'];
    _nameController = TextEditingController(
      text: student['student_name'] ?? '',
    );

    // Load existing interests
    _selectedInterests = _getExistingInterests().toSet();
  }

  List<String> _getExistingInterests() {
    final profile = widget.profileData['profile'];
    if (profile == null) return [];

    final interestIn = profile['interest_in'];
    if (interestIn == null) return [];

    if (interestIn is List) {
      return List<String>.from(interestIn);
    } else if (interestIn is String) {
      try {
        final decoded = interestIn.replaceAll('\\', '');
        final List<dynamic> parsed =
            (decoded.startsWith('['))
                ? List<dynamic>.from(
                  decoded
                      .substring(1, decoded.length - 1)
                      .split(',')
                      .map((e) => e.trim().replaceAll('"', '')),
                )
                : [decoded];
        return List<String>.from(parsed);
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update profile (name, interests, image)
        final profileResult = await AuthService.updateProfile(
          name: _nameController.text,
          interests: _selectedInterests.toList(),
          imagePath: _imageFile?.path,
        );

        if (!profileResult['success']) {
          throw Exception(
            profileResult['message'] ?? 'Failed to update profile',
          );
        }

        // Handle password change if provided
        if (_currentPasswordController.text.isNotEmpty ||
            _passwordController.text.isNotEmpty) {
          if (_currentPasswordController.text.isEmpty) {
            throw Exception('Current password is required to change password');
          }

          final passwordResult = await AuthService.changePassword(
            _currentPasswordController.text,
            _passwordController.text,
            _confirmPasswordController.text,
          );

          if (!passwordResult['success']) {
            throw Exception(
              passwordResult['message'] ?? 'Failed to change password',
            );
          }
        }

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
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileData['profile'];

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
            size: 18,
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
                        image: DecorationImage(
                          image:
                              _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : (profile['profile_image'] != null
                                      ? NetworkImage(
                                        'https://schoolwala.info/storage/${profile['profile_image']}',
                                      )
                                      : const AssetImage(
                                            'assets/images/profile.jpg',
                                          )
                                          as ImageProvider),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
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
                                                _pickImage(ImageSource.camera);
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
                                                _pickImage(ImageSource.gallery);
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
              const Text(
                'Your Interests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
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
                    'Change Password (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Leave blank if you don\'t want to change your password',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(height: 16),

              // Current Password
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hintText: '••••••••',
                obscureText: _obscureCurrentPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textGray,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                controller: _passwordController,
                label: 'New Password',
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
                  if (_currentPasswordController.text.isNotEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter new password';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
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
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                  : CustomButton(text: 'Save Changes', onPressed: _handleSave),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
