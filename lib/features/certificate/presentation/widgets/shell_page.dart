import 'package:birth_certify/features/auth/presentation/providers/auth_provider.dart';
import 'package:birth_certify/features/auth/presentation/providers/auth_status_provider.dart';
import 'package:birth_certify/features/certificate/presentation/pages/certificate_list_page.dart';
import 'package:birth_certify/features/registration/presentation/pages/registration_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userAsync = ref.watch(currentUserProvider);
       if (userAsync.isLoading) {
      return const Center(child: SizedBox());
    }
    if (userAsync.hasError) {
      return SizedBox();
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
            child: const Text(
              "LOGO",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.3,
            child: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Text(
                    "Certificates",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: GoogleFonts.albertSans().fontFamily,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Register",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: GoogleFonts.albertSans().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: 320,
              child: ListTile(
                leading: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle
                ),
                  child:  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${user?.firstName.substring(0, 1)}${user?.lastName.substring(0, 1)}', 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: GoogleFonts.albertSans().fontFamily,
                      ),
                    ),
                  ),
                ),
                title:  Text("${user?.firstName} ${user?.lastName}"),
                trailing: PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: const [
                            Icon(Icons.person),
                            SizedBox(width: 8),
                            Text('Profile'),
                          ],
                        ),
                      ),

                      PopupMenuItem(
                        value: 'logout',
                        onTap:
                            () async => await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await ref
                                            .read(authProvider.notifier)
                                            .logout();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ),
                        child: Row(
                          children: const [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
                onTap: () async {},
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [CertificateListPage(), RegistrationFormPage()],
        ),
      ),
    );
  }
}
