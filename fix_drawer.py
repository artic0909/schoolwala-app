
import sys

file_path = r'e:\Saklin Mustak\All Websites\Schoolwala\schoolwala-app\lib\widgets\app_drawer.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('const AppDrawer({super.key, required this.studentName});', 'final String currentRoute;\n  const AppDrawer({super.key, required this.studentName, this.currentRoute = \'Home\'});')

old_build_item = '''  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryOrange),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        onTap: onTap,
        hoverColor: AppColors.primaryOrange.withValues(alpha: 0.05),
      ),
    );
  }'''

new_build_item = '''  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.primaryOrange.withValues(alpha: 0.1) : Colors.transparent,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange : AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppColors.primaryOrange),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.primaryOrange : AppColors.darkNavy,
          ),
        ),
        onTap: onTap,
        hoverColor: AppColors.primaryOrange.withValues(alpha: 0.05),
      ),
    );
  }'''

content = content.replace(old_build_item, new_build_item)

content = content.replace('''                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'My Profile',
                  onTap: () {''',
'''                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'My Profile',
                  isSelected: widget.currentRoute == 'Profile',
                  onTap: () {''')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Drawer patched')

