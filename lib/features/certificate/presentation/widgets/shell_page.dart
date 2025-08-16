// lib/features/certificate/presentation/widgets/shell_page.dart
import 'package:birth_certify/features/auth/presentation/providers/auth_provider.dart';
import 'package:birth_certify/features/certificate/presentation/pages/enhanced_certificate_list_pages.dart';
import 'package:birth_certify/features/registration/presentation/widgets/enhanced_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    if (userAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (userAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading user data: ${userAsync.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    final user = userAsync.value;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          title: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.3,
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dashboard, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Dashboard",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: GoogleFonts.albertSans().fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Register",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: GoogleFonts.albertSans().fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Public verification button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: OutlinedButton.icon(
                onPressed: () => context.go('/verify'),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Verify Certificate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue.shade300),
                ),
              ),
            ),
            
            // User profile section
            SizedBox(
              width: 320,
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '${user?.firstName.substring(0, 1)}${user?.lastName.substring(0, 1)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.albertSans().fontFamily,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  "${user?.firstName} ${user?.lastName}",
                  style: GoogleFonts.albertSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  user?.role.toUpperCase() ?? 'USER',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  offset: const Offset(0, 40),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: const [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 12),
                          Text('Profile Settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'verify',
                      child: Row(
                        children: const [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 12),
                          Text('Verify Certificate'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red[600]),
                          const SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red[600])),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'profile':
                        _showProfileDialog(context, user);
                        break;
                      case 'verify':
                        context.go('/verify');
                        break;
                      case 'logout':
                        _showLogoutDialog(context, ref);
                        break;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            EnhancedCertificateListPage(),
            EnhancedRegistrationForm(),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Name', '${user?.firstName} ${user?.lastName}'),
            _buildProfileRow('Email', user?.email ?? 'Not available'),
            _buildProfileRow('Role', user?.role.toUpperCase() ?? 'USER'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to profile edit page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile editing not yet implemented'),
                ),
              );
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}