import sys

file_path = r'e:\Saklin Mustak\All Websites\Schoolwala\schoolwala-app\lib\screens\profile_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove leading from AppBars
content = content.replace('''          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
            onPressed: () => Navigator.of(context).pop(),
          ),''', '')

content = content.replace('''        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),''', '')

# Replace bottomNavigationBar in main Scaffold
content = content.replace('bottomNavigationBar: const GlobalBottomBar(currentIndex: 0),', """drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),""")

# Also add drawer and bottomNavigationBar to _isLoading Scaffold
content = content.replace('''        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );''', '''        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
        drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
        bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),
      );''')

# Also add drawer and bottomNavigationBar to _errorMessage Scaffold
content = content.replace('''              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );''', '''              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
        bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),
      );''')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Profile patched')
