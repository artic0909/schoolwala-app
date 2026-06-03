import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/app_drawer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String studentName;

  const PrivacyPolicyScreen({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      drawer: AppDrawer(studentName: studentName, currentRoute: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.article_rounded, 'How We Use Information'),
            const SizedBox(height: 12),
            const Text(
              'Your information helps us create the best learning adventure:',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildDashedCard(Icons.edit, 'Personalize', 'Create activities just right for you'),
                _buildDashedCard(Icons.show_chart, 'Track Progress', 'Show how much you\'re learning'),
                _buildDashedCard(Icons.smart_toy, 'Make Fun', 'Design games you\'ll love to play'),
                _buildDashedCard(Icons.security, 'Keep Safe', 'Protect your learning space'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'We promise never to sell your information to anyone!',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // Superhero Security
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3), style: BorderStyle.solid), // Dashed can be complex, using solid for now
              ),
              child: Column(
                children: [
                  const Icon(Icons.shield, color: AppColors.primaryOrange, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Superhero Security',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We use special tools to protect your information like a superhero shield! Our security team works 24/7 to keep your data safe from any baddies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGray, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecurityBadge(Icons.lock, 'Encryption', Colors.orange),
                      const SizedBox(width: 12),
                      _buildSecurityBadge(Icons.admin_panel_settings, 'Protection', Colors.blue),
                      const SizedBox(width: 12),
                      _buildSecurityBadge(Icons.privacy_tip, 'Privacy', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(Icons.cookie, 'Cookies & Tracking'),
            const SizedBox(height: 12),
            const Text(
              'We use cookies - but not the chocolate chip kind! These are tiny helpers that:',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildDashedCard(Icons.login, 'Remember You', 'So you don\'t have to login every time'),
                _buildDashedCard(Icons.thumb_up, 'Know Preferences', 'Remember your favorite settings'),
                _buildDashedCard(Icons.trending_up, 'Improve', 'Make Schoolwala better for everyone'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'You can control cookies in your browser, but some features might not work without them.',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(Icons.rocket_launch, 'Your Space Powers'),
            const SizedBox(height: 12),
            const Text(
              'You\'re the captain of your privacy spaceship! You can:',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildDashedCard(Icons.visibility, 'See Data', 'Ask to see what info we have'),
                _buildDashedCard(Icons.build, 'Fix Mistakes', 'Tell us if something\'s wrong'),
                _buildDashedCard(Icons.pause, 'Take Breaks', 'Pause your account anytime'),
                _buildDashedCard(Icons.delete, 'Delete', 'Ask us to delete your info'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Just ask your parents to help with these - they\'re your co-pilots!',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
        ),
      ],
    );
  }

  Widget _buildDashedCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.2), style: BorderStyle.solid), // Simulating dashed with solid light color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textGray),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
