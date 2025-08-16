// lib/features/certificate/presentation/pages/enhanced_certificate_list_page.dart
import 'package:birth_certify/features/certificate/presentation/pages/certificate_id_fixer.dart';
import 'package:birth_certify/features/certificate/presentation/providers/enhanced_certificate_providers.dart';
import 'package:birth_certify/features/certificate/presentation/widgets/debug_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EnhancedCertificateListPage extends ConsumerStatefulWidget {
  const EnhancedCertificateListPage({super.key});

  @override
  ConsumerState<EnhancedCertificateListPage> createState() =>
      _EnhancedCertificateListPageState();
}

class _EnhancedCertificateListPageState extends ConsumerState<EnhancedCertificateListPage> {
  String searchQuery = '';
  String selectedFilter = 'all';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(enhancedCertificateListProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              
              // Dashboard Banner
              userAsync.when(
                data: (user) => _DashboardBanner(
                  name: '${user?.firstName} ${user?.lastName.substring(0, 1)}',
                ),
                loading: () => const _SkeletonBanner(),
                error: (e, _) => _ErrorBanner(error: e.toString()),
              ),
              
              const SizedBox(height: 32),
              // const DebugVerificationWidget(),
// const CertificateIdFixer(),
              // Statistics Cards
              certificatesAsync.when(
                data: (certificates) => _buildStatisticsCards(certificates),
                loading: () => _buildSkeletonStats(),
                error: (e, _) => _buildErrorStats(),
              ),

              const SizedBox(height: 32),

              // Table Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registered Certificates',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.albertSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overview of all registered birth certificates',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: GoogleFonts.albertSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _refreshData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search and Filter Controls
              _buildSearchAndFilter(),
              const SizedBox(height: 24),

              // Certificates Table
              certificatesAsync.when(
                data: (certificates) => _buildCertificatesTable(
                  _filterCertificates(certificates),
                ),
                loading: () => _buildSkeletonTable(),
                error: (error, _) => _buildErrorState(error.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(List<EnhancedCertificate> certificates) {
    final totalCertificates = certificates.length;
    final recentCertificates = certificates.where((cert) =>
        cert.registeredAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length;
    final blockchainVerified = certificates.where((cert) => cert.blockchainVerified).length;
    final nftMinted = certificates.where((cert) => cert.nftTokenId != null).length;

    return Row(
      children: [
        Expanded(child: _StatCard(
          title: 'Total Certificates',
          value: totalCertificates.toString(),
          icon: Icons.description,
          color: Colors.blue,
        )),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(
          title: 'Recent (30 days)',
          value: recentCertificates.toString(),
          icon: Icons.schedule,
          color: Colors.green,
        )),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(
          title: 'Blockchain Verified',
          value: blockchainVerified.toString(),
          icon: Icons.verified,
          color: Colors.purple,
        )),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(
          title: 'NFT Minted',
          value: nftMinted.toString(),
          icon: Icons.token,
          color: Colors.orange,
        )),
      ],
    );
  }

  Widget _buildSkeletonStats() {
    return Row(
      children: List.generate(4, (index) => 
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStats() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Failed to load statistics'),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 1;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or NIN...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Filter Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_alt),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Certificates')),
              DropdownMenuItem(value: 'recent', child: Text('Recent (30 days)')),
              DropdownMenuItem(value: 'verified', child: Text('Blockchain Verified')),
              DropdownMenuItem(value: 'nft', child: Text('With NFT')),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
                currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Export Button
        OutlinedButton.icon(
          onPressed: () => _exportCertificates(),
          icon: const Icon(Icons.download),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }

  Widget _buildCertificatesTable(List<EnhancedCertificate> certificates) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, certificates.length);
    final paginatedCertificates = certificates.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Table
        Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name'), numeric: false),
                DataColumn(label: Text('Date of Birth')),
                DataColumn(label: Text('Place of Birth')),
                DataColumn(label: Text('Registration Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: paginatedCertificates.map((cert) => DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cert.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (cert.certificateId != null)
                          Text(
                            'ID: ${cert.certificateId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(Text(cert.dateOfBirth)),
                  DataCell(Text(cert.placeOfBirth)),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(cert.registeredAt))),
                  DataCell(_buildStatusChip(cert)),
                  DataCell(_buildActionButtons(cert)),
                ],
              )).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pagination
        _buildPagination(certificates.length),
      ],
    );
  }

  Widget _buildStatusChip(EnhancedCertificate cert) {
    if (cert.nftTokenId != null) {
      return Chip(
        label: const Text('NFT Minted'),
        backgroundColor: Colors.green[100],
        labelStyle: TextStyle(color: Colors.green[800]),
        avatar: const Icon(Icons.token, size: 16),
      );
    } else if (cert.blockchainVerified) {
      return Chip(
        label: const Text('Verified'),
        backgroundColor: Colors.blue[100],
        labelStyle: TextStyle(color: Colors.blue[800]),
        avatar: const Icon(Icons.verified, size: 16),
      );
    } else {
      return Chip(
        label: const Text('Registered'),
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(color: Colors.grey[800]),
        avatar: const Icon(Icons.description, size: 16),
      );
    }
  }

  Widget _buildActionButtons(EnhancedCertificate cert) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Certificate
        if (cert.certificateUrl != null)
          IconButton(
            icon: const Icon(Icons.visibility, size: 20),
            onPressed: () => _launchUrl(cert.certificateUrl!),
            tooltip: 'View Certificate',
          ),
        
        // Copy verification link
        IconButton(
          icon: const Icon(Icons.link, size: 20),
          onPressed: () => _copyVerificationLink(cert),
          tooltip: 'Copy Verification Link',
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) => _handleMenuAction(value, cert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (cert.nftTokenId != null)
              const PopupMenuItem(
                value: 'nft',
                child: Row(
                  children: [
                    Icon(Icons.token, size: 16),
                    SizedBox(width: 8),
                    Text('View NFT'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    
    if (totalPages <= 1) return const SizedBox();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        
        // Page numbers
        ...List.generate(totalPages.clamp(0, 5), (index) {
          final pageNum = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => setState(() => currentPage = pageNum),
              style: OutlinedButton.styleFrom(
                backgroundColor: currentPage == pageNum ? Colors.blue : null,
                foregroundColor: currentPage == pageNum ? Colors.white : null,
              ),
              child: Text('$pageNum'),
            ),
          );
        }),
        
        // Next button
        IconButton(
          onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        
        const SizedBox(width: 16),
        Text('Page $currentPage of $totalPages'),
      ],
    );
  }

  Widget _buildSkeletonTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(5, (index) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: List.generate(6, (i) => 
                  Expanded(
                    child: Container(
                      height: 20,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load certificates',
              style: GoogleFonts.albertSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  List<EnhancedCertificate> _filterCertificates(List<EnhancedCertificate> certificates) {
    var filtered = certificates;

    // Apply text search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((cert) =>
          cert.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (cert.certificateId?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          cert.nin.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Apply filter
    switch (selectedFilter) {
      case 'recent':
        filtered = filtered.where((cert) =>
            cert.registeredAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList();
        break;
      case 'verified':
        filtered = filtered.where((cert) => cert.blockchainVerified).toList();
        break;
      case 'nft':
        filtered = filtered.where((cert) => cert.nftTokenId != null).toList();
        break;
    }

    return filtered;
  }

  void _refreshData() {
    ref.invalidate(enhancedCertificateListProvider);
  }

  void _exportCertificates() {
    // Implement CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented'),
      ),
    );
  }

  void _copyVerificationLink(EnhancedCertificate cert) {
    final link = 'https://your-domain.com/verify/${cert.certificateId ?? cert.certificateCid}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification link copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleMenuAction(String action, EnhancedCertificate cert) {
    switch (action) {
      case 'details':
        _showCertificateDetails(cert);
        break;
      case 'nft':
        _viewNFT(cert);
        break;
      case 'download':
        _downloadCertificate(cert);
        break;
    }
  }

  void _showCertificateDetails(EnhancedCertificate cert) {
    showDialog(
      context: context,
      builder: (context) => _CertificateDetailsDialog(certificate: cert),
    );
  }

  void _viewNFT(EnhancedCertificate cert) {
    // Implement NFT viewing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NFT Token ID: ${cert.nftTokenId}'),
      ),
    );
  }

  void _downloadCertificate(EnhancedCertificate cert) {
    if (cert.certificateUrl != null) {
      _launchUrl(cert.certificateUrl!);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Supporting Widgets
class _DashboardBanner extends StatelessWidget {
  final String name;

  const _DashboardBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0A2942), const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name.',
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Easily register new births, access digital certificates, all in one trusted place.',
            style: GoogleFonts.albertSans(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBanner extends StatelessWidget {
  const _SkeletonBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;

  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Error loading user: $error',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: GoogleFonts.albertSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateDetailsDialog extends StatelessWidget {
  final EnhancedCertificate certificate;

  const _CertificateDetailsDialog({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Certificate Details'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', certificate.name),
            _buildDetailRow('Date of Birth', certificate.dateOfBirth),
            _buildDetailRow('Place of Birth', certificate.placeOfBirth),
            _buildDetailRow('NIN', certificate.nin),
            _buildDetailRow('Registration Date', DateFormat('MMM dd, yyyy').format(certificate.registeredAt)),
            if (certificate.certificateId != null)
              _buildDetailRow('Certificate ID', certificate.certificateId!),
            if (certificate.certificateCid != null)
              _buildDetailRow('IPFS CID', certificate.certificateCid!),
            if (certificate.nftTokenId != null)
              _buildDetailRow('NFT Token ID', certificate.nftTokenId.toString()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (certificate.certificateUrl != null)
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(certificate.certificateUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: const Text('View Certificate'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
}