import 'package:birth_certify/features/certificate/presentation/pages/certificate_list_page.dart';
import 'package:birth_certify/features/registration/presentation/pages/registration_form_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          centerTitle: true,
          leading: const Text(
            "LOGO",
            style: TextStyle(fontWeight: FontWeight.bold),
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
              width: 250,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: const Text('DA'),
                ),
                title: const Text("Dara Williams"),
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
                onTap: () {
                  // Handle notifications tap
                },
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
