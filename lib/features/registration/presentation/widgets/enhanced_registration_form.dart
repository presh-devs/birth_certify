// lib/features/registration/presentation/widgets/enhanced_registration_form.dart
import 'dart:io';
import 'package:birth_certify/features/auth/presentation/providers/auth_provider.dart';
import 'package:birth_certify/features/certificate/presentation/providers/certificate_provider.dart';
import 'package:birth_certify/features/registration/domain/models/enhanced_registration_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../storacha/presentation/providers/storacha_provider.dart';
import '../../../storacha/data/models/storacha_models.dart';

class EnhancedRegistrationForm extends ConsumerStatefulWidget {
  const EnhancedRegistrationForm({super.key});

  @override
  ConsumerState<EnhancedRegistrationForm> createState() =>
      _EnhancedRegistrationFormState();
}

class _EnhancedRegistrationFormState
    extends ConsumerState<EnhancedRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (same as your existing form)
  final firstName = TextEditingController();
  final middleName = TextEditingController();
  final lastName = TextEditingController();
  final placeOfBirth = TextEditingController();
  final dateOfBirth = TextEditingController();
  final motherFirstName = TextEditingController();
  final motherLastName = TextEditingController();
  final fatherFirstName = TextEditingController();
  final fatherLastName = TextEditingController();
  final motherNIN = TextEditingController();
  final fatherNIN = TextEditingController();
  final wallet = TextEditingController();

  File? supportingDocument;
  String? supportingDocumentName;
  bool isSubmitting = false;
  StorachaUploadResponse? lastUploadResponse;

  @override
  void dispose() {
    // Dispose controllers
    firstName.dispose();
    middleName.dispose();
    lastName.dispose();
    placeOfBirth.dispose();
    dateOfBirth.dispose();
    motherFirstName.dispose();
    motherLastName.dispose();
    fatherFirstName.dispose();
    fatherLastName.dispose();
    motherNIN.dispose();
    fatherNIN.dispose();
    wallet.dispose();
    super.dispose();
  }

  Future<void> _pickSupportingDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          supportingDocument = File(result.files.single.path!);
          supportingDocumentName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _generateWallet() async {
    try {
      final walletData = await ref.read(generateWalletProvider.future);
      setState(() {
        wallet.text = walletData.address;
      });

      // Show wallet details dialog
      _showWalletDialog(walletData);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating wallet: $e')));
    }
  }

  void _showWalletDialog(WalletData walletData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generated Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️ Save this information securely!'),
              const SizedBox(height: 16),
              _buildWalletInfo('Address:', walletData.address),
              if (walletData.privateKey != null)
                _buildWalletInfo('Private Key:', walletData.privateKey!),
              if (walletData.mnemonic != null)
                _buildWalletInfo('Mnemonic:', walletData.mnemonic!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWalletInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });
    final user = await ref.read(currentUserProvider.future);
    try {
      // Create the enhanced request
      final enhancedRequest = EnhancedRegistrationRequest(
        firstName: firstName.text,
        middleName: middleName.text,
        lastName: lastName.text,
        placeOfBirth: placeOfBirth.text,
        dateOfBirth: dateOfBirth.text,
        motherFirstName: motherFirstName.text,
        motherLastName: motherLastName.text,
        fatherFirstName: fatherFirstName.text,
        fatherLastName: fatherLastName.text,
        motherNIN: motherNIN.text,
        fatherNIN: fatherNIN.text,
        wallet: wallet.text,
        supportingDocument: supportingDocument,
      );

      // Use ONLY the enhanced repository (includes Firestore saving)
      final result = await ref.read(
        submitEnhancedRegistrationProvider((
          request: enhancedRequest,
          submittedBy: user!.id,
        )).future,
      );

      // Show success dialog and clear form
      _showEnhancedSuccessDialog(result);
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
void _showEnhancedSuccessDialog(RegistrationResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Registration Successful!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Certificate ID: ${result.certificateId}'),
                const SizedBox(height: 16),

                // 🖼️ Certificate Image Preview (if available)
                if (result.certificateImageUrl != null) ...[
                  const Text(
                    '🖼️ Certificate Image:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        result.certificateImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Loading certificate image...'),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image will be available shortly'),
                                Text('IPFS propagation in progress...', 
                                     style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(result.certificateImageUrl!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View Full Image'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 📜 PDF Certificate
                const Text(
                  '📜 Birth Certificate PDF:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Official Birth Certificate',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IPFS CID: ${result.certificateCid}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(result.certificateUrl),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 🎨 NFT Information
                if (result.nftInfo != null) ...[
                  const Text(
                    '🎨 NFT Minted Successfully:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.token, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Token ID: ${result.nftInfo!.tokenId}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Transaction: ${result.nftInfo!.transactionHash.substring(0, 20)}...'),
                        Text('Owner: ${result.nftInfo!.ownerAddress.substring(0, 20)}...'),
                        if (result.nftInfo!.imageUrl != null)
                          const Text('✅ NFT image available on IPFS'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (result.nftInfo!.metadataUrl != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _launchUrl(result.nftInfo!.metadataUrl!),
                                  icon: const Icon(Icons.info_outline, size: 16),
                                  label: const Text('View Metadata'),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _launchUrl(
                                  'https://polygonscan.com/tx/${result.nftInfo!.transactionHash}'
                                ),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('View Transaction'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'NFT minting failed (insufficient gas or network issue), but certificate was created successfully!',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 📄 Supporting Document
                if (result.supportingDocumentUrl != null) ...[
                  const Text(
                    '📄 Supporting Document:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Supporting document uploaded'),
                        ),
                        IconButton(
                          onPressed: () => _launchUrl(result.supportingDocumentUrl!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          tooltip: 'View Document',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ Success confirmation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Record saved to Firestore successfully!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (result.certificateImageUrl != null)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUrl(result.certificateImageUrl!);
                },
                child: const Text('View Image'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl(result.certificateUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Download PDF'),
            ),
          ],
        );
      },
    );
  }
  // void _showEnhancedSuccessDialog(RegistrationResult result) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('🎉 Registration Successful!'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Certificate ID: ${result.certificateId}'),
  //               const SizedBox(height: 16),

  //               const Text(
  //                 '📜 Birth Certificate:',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               Text('IPFS CID: ${result.certificateCid}'),
  //               InkWell(
  //                 onTap: () => _launchUrl(result.certificateUrl),
  //                 child: Text(
  //                   'View Certificate',
  //                   style: TextStyle(
  //                     color: Colors.blue,
  //                     decoration: TextDecoration.underline,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),

  //               if (result.nftInfo != null) ...[
  //                 const Text(
  //                   '🎨 NFT Minted:',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 Text('Token ID: ${result.nftInfo!.tokenId}'),
  //                 Text(
  //                   'Transaction: ${result.nftInfo!.transactionHash.substring(0, 20)}...',
  //                 ),
  //                 Text(
  //                   'Owner: ${result.nftInfo!.ownerAddress.substring(0, 20)}...',
  //                 ),
  //                 const SizedBox(height: 12),
  //               ] else ...[
  //                 const Text(
  //                   '⚠️ NFT minting failed (insufficient gas), but certificate was created successfully!',
  //                 ),
  //                 const SizedBox(height: 12),
  //               ],

  //               if (result.supportingDocumentUrl != null) ...[
  //                 const Text(
  //                   '📄 Supporting Document:',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 InkWell(
  //                   onTap: () => _launchUrl(result.supportingDocumentUrl!),
  //                   child: Text(
  //                     'View Document',
  //                     style: TextStyle(
  //                       color: Colors.blue,
  //                       decoration: TextDecoration.underline,
  //                     ),
  //                   ),
  //                 ),
  //               ],

  //               const SizedBox(height: 16),
  //               const Text(
  //                 '✅ Record saved to Firestore successfully!',
  //                 style: TextStyle(
  //                   color: Colors.green,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Close'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _launchUrl(result.certificateUrl);
  //             },
  //             child: const Text('View Certificate'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _launchUrl(String url) {
    // You can use url_launcher package here
    // For now, just show the URL
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Certificate URL'),
            content: SelectableText(url),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    firstName.clear();
    middleName.clear();
    lastName.clear();
    placeOfBirth.clear();
    dateOfBirth.clear();
    motherFirstName.clear();
    motherLastName.clear();
    fatherFirstName.clear();
    fatherLastName.clear();
    motherNIN.clear();
    fatherNIN.clear();
    wallet.clear();
    setState(() {
      supportingDocument = null;
      supportingDocumentName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Birth Certificate Registration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              Text(
                'Register birth details and mint NFT certificate on blockchain',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              const SizedBox(height: 24),

              // Health Status Card
              FutureBuilder<Map<String, dynamic>>(
                future: ref.read(healthStatusProvider.future),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final health = snapshot.data!;
                    return Card(
                      color:
                          health['storacha'] == 'connected'
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              health['storacha'] == 'connected'
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  health['storacha'] == 'connected'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Backend Status: ${health['storacha'] ?? 'unknown'}',
                            ),
                            const SizedBox(width: 16),
                            Text('Web3: ${health['web3'] ?? 'unknown'}'),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Checking backend status...'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Main Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Birth Information Section
                      Text(
                        'Birth Information',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: GoogleFonts.albertSans().fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDoubleRow(
                        _buildField(
                          controller: firstName,
                          label: 'First Name *',
                        ),
                        _buildField(
                          controller: middleName,
                          label: 'Middle Name',
                        ),
                      ),
                      _buildDoubleRow(
                        _buildField(controller: lastName, label: 'Last Name *'),
                        _buildField(
                          controller: placeOfBirth,
                          label: 'Place of Birth *',
                        ),
                      ),
                      _buildField(
                        controller: dateOfBirth,
                        label: 'Date of Birth *',
                      ),

                      const SizedBox(height: 32),

                      // Parent Information Section
                      Text(
                        "Parent's Information",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDoubleRow(
                        _buildField(
                          controller: motherFirstName,
                          label: "Mother's First Name",
                        ),
                        _buildField(
                          controller: motherLastName,
                          label: "Mother's Last Name",
                        ),
                      ),
                      _buildDoubleRow(
                        _buildField(
                          controller: fatherFirstName,
                          label: "Father's First Name",
                        ),
                        _buildField(
                          controller: fatherLastName,
                          label: "Father's Last Name",
                        ),
                      ),
                      _buildDoubleRow(
                        _buildField(
                          controller: motherNIN,
                          label: "Mother's NIN",
                        ),
                        _buildField(
                          controller: fatherNIN,
                          label: "Father's NIN",
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Wallet Section
                      Text(
                        "Blockchain Wallet",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "The NFT certificate will be minted to this wallet address",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: wallet,
                              decoration: const InputDecoration(
                                hintText:
                                    'Enter wallet address or generate new one',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _generateWallet,
                            icon: const Icon(Icons.wallet),
                            label: const Text('Generate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Supporting Documents Section
                      Text(
                        "Supporting Documents",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Upload supporting documents (hospital slip, affidavit, etc.)",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),

                      if (supportingDocumentName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected: $supportingDocumentName',
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    supportingDocument = null;
                                    supportingDocumentName = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      OutlinedButton.icon(
                        onPressed: _pickSupportingDocument,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          supportingDocumentName == null
                              ? 'Upload Document'
                              : 'Change Document',
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed:
                                isSubmitting ? null : _submitRegistration,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                isSubmitting
                                    ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Processing...'),
                                      ],
                                    )
                                    : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rocket_launch),
                                        SizedBox(width: 8),
                                        Text('Submit & Mint NFT'),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        validator:
            (value) =>
                (label.contains('*') && (value == null || value.isEmpty))
                    ? 'Required'
                    : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
