import 'package:birth_certify/features/certificate/presentation/providers/certificate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              DataCell(Text(cert.name)),
              DataCell(Text(cert.dob)),
              DataCell(Text(cert.placeOfBirth)),
              DataCell(Text(cert.nin)),
              DataCell(Text(cert.dateRegistered)),
            ],
          );
        }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _TopNavBar(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

class _TopNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      title: Row(
        children: [
          const Text("LOGO", style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text("Home")),
          TextButton(onPressed: () {}, child: const Text("Register")),
          TextButton(onPressed: () {}, child: const Text("Certificates")),
          const SizedBox(width: 16),
          const CircleAvatar(child: Text('DA')),
          const SizedBox(width: 8),
          const Text('Dara Williams'),
        ],
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2942),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Hello, $name.\nEasily register new births, access digital certificates, all in one trusted place.',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
