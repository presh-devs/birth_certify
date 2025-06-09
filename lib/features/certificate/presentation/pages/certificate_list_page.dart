import 'package:birth_certify/features/certificate/presentation/providers/certificate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CertificateListPage extends ConsumerWidget {
  const CertificateListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificateListProvider);

    if (certsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (certsAsync.hasError) {
      return Center(child: Text('Error: ${certsAsync.error}'));
    }
    final certificates = certsAsync.value!;

    final rows =
        certificates.map((cert) {
          return DataRow(
            cells: [
              DataCell(Text(cert.firstName)),
              DataCell(Text(cert.dateOfBirth.toString())),
              DataCell(Text(cert.placeOfBirth)),
              DataCell(Text(cert.nin)),
              DataCell(Text(cert.registeredAt.toString())),
            ],
          );
        }).toList();

    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(70),
      //   child: ShellPage(),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              _DashboardBanner(name: 'Dara W.'),
              const SizedBox(height: 32),

              const Text(
                'Registered Certificates',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Overview of all registered birth certificates',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Search and filter
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search here...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text('Filter'),
                      ),
                    ],
                  ),

                  // Export and register
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Export as CSV'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Go to register page
                          Navigator.pushNamed(context, '/register');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Date of Birth')),
                    DataColumn(label: Text('Place of Birth')),
                    DataColumn(label: Text('NIN')),
                    DataColumn(label: Text('Date Registered')),
                  ],
                  rows: rows,
                ),
              ),

              const SizedBox(height: 24),

              // Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Previous')),
                  for (var i = 1; i <= 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text('$i'),
                      ),
                    ),
                  TextButton(onPressed: () {}, child: const Text('Next')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBanner extends StatelessWidget {
  final String name;

  const _DashboardBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 227,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2942),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: GoogleFonts.manrope().fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Easily register new births, access digital certificates, all in one trusted place.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: GoogleFonts.manrope().fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
