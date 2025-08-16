// lib/features/certificate/presentation/pages/public_verification_page.dart
import 'package:birth_certify/features/certificate/presentation/providers/verification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicVerificationPage extends ConsumerStatefulWidget {
  final String? initialCertificateId;
  
  const PublicVerificationPage({
    super.key,
    this.initialCertificateId,
  });

  @override
  ConsumerState<PublicVerificationPage> createState() =>
      _PublicVerificationPageState();
}

class _PublicVerificationPageState extends ConsumerState<PublicVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _certificateIdController = TextEditingController();
  final _cidController = TextEditingController();
  
  String _verificationType = 'certificate_id'; // 'certificate_id' or 'cid'

  @override
  void initState() {
    super.initState();
    if (widget.initialCertificateId != null) {
      _certificateIdController.text = widget.initialCertificateId!;
    }
  }

  @override
  void dispose() {
    _certificateIdController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  void _verify() {
    if (!_formKey.currentState!.validate()) return;

    // Force refresh the providers by invalidating them first
    if (_verificationType == 'certificate_id') {
      ref.invalidate(verifyCertificateByIdProvider);
      // Trigger the provider
      ref.read(verifyCertificateByIdProvider(_certificateIdController.text));
    } else {
      ref.invalidate(verifyCertificateByCidProvider);
      // Trigger the provider
      ref.read(verifyCertificateByCidProvider(_cidController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the appropriate provider based on what's being verified
    AsyncValue<VerificationResult>? verificationAsync;
    
    if (widget.initialCertificateId != null) {
      verificationAsync = ref.watch(verifyCertificateByIdProvider(widget.initialCertificateId!));
    } else if (_certificateIdController.text.isNotEmpty && _verificationType == 'certificate_id') {
      verificationAsync = ref.watch(verifyCertificateByIdProvider(_certificateIdController.text));
    } else if (_cidController.text.isNotEmpty && _verificationType == 'cid') {
      verificationAsync = ref.watch(verifyCertificateByCidProvider(_cidController.text));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Certificate Verification',
          style: GoogleFonts.albertSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Birth Certificate Verification',
                            style: GoogleFonts.albertSans(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verify the authenticity of birth certificates using blockchain technology and IPFS.',
                        style: GoogleFonts.albertSans(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Verification Form
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verification Method',
                            style: GoogleFonts.albertSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Verification Type Selector
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Certificate ID'),
                                  subtitle: const Text('Use the certificate ID from the system'),
                                  value: 'certificate_id',
                                  groupValue: _verificationType,
                                  onChanged: (value) {
                                    setState(() {
                                      _verificationType = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('IPFS CID'),
                                  subtitle: const Text('Use the IPFS Content Identifier'),
                                  value: 'cid',
                                  groupValue: _verificationType,
                                  onChanged: (value) {
                                    setState(() {
                                      _verificationType = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Input Fields
                          if (_verificationType == 'certificate_id') ...[
                            TextFormField(
                              controller: _certificateIdController,
                              decoration: const InputDecoration(
                                labelText: 'Certificate ID',
                                hintText: 'Enter certificate ID (e.g., BC-1234567890)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.confirmation_number),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a certificate ID';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _cidController,
                              decoration: const InputDecoration(
                                labelText: 'IPFS CID',
                                hintText: 'Enter IPFS Content Identifier',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.link),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an IPFS CID';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _verify,
                              icon: const Icon(Icons.search),
                              label: const Text('Verify Certificate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Results Section
                if (verificationAsync != null)
                  _buildResultsSection(verificationAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(AsyncValue<VerificationResult> verificationAsync) {
    return verificationAsync.when(
      data: (result) => _buildVerificationResult(result),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying certificate...'),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Verification Failed',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationResult(VerificationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.verified : Icons.error_outline,
                  color: result.isValid ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  result.isValid ? 'Certificate Verified' : 'Invalid Certificate',
                  style: GoogleFonts.albertSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: result.isValid ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            if (result.isValid && result.certificate != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Certificate Details
              Text(
                'Certificate Information',
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Full Name', result.certificate!.name),
              _buildDetailRow('Date of Birth', result.certificate!.dateOfBirth),
              _buildDetailRow('Place of Birth', result.certificate!.placeOfBirth),
              _buildDetailRow('Registration Date', result.certificate!.registeredAt.toString()),

              if (result.certificateUrl != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(result.certificateUrl!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],

              // Blockchain Information
              if (result.nftInfo != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Blockchain Information',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('NFT Token ID', result.nftInfo!.tokenId.toString()),
                _buildDetailRow('Transaction Hash', '${result.nftInfo!.transactionHash.substring(0, 20)}...'),
                _buildDetailRow('Owner Address', '${result.nftInfo!.ownerAddress.substring(0, 20)}...'),
                _buildDetailRow('Contract Address', '${result.nftInfo!.contractAddress.substring(0, 20)}...'),
              ],
            ],

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This certificate is ${result.isValid ? 'authentic and stored on the blockchain' : 'not found or invalid'}.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}