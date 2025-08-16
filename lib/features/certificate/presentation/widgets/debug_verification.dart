// lib/features/certificate/presentation/widgets/debug_verification_widget.dart
import 'package:birth_certify/features/certificate/presentation/providers/verification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugVerificationWidget extends ConsumerStatefulWidget {
  const DebugVerificationWidget({super.key});

  @override
  ConsumerState<DebugVerificationWidget> createState() => _DebugVerificationWidgetState();
}

class _DebugVerificationWidgetState extends ConsumerState<DebugVerificationWidget> {
  final _controller = TextEditingController(text: 'BC-1755341140128');
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Certificate ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isVerifying ? null : () => _testVerification(),
                  child: _isVerifying 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test Verification'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _testRawData(),
                  child: const Text('Test Raw Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Show verification result
            Consumer(
              builder: (context, ref, child) {
                if (!_isVerifying) return const SizedBox();
                
                final verificationAsync = ref.watch(verifyCertificateByIdProvider(_controller.text));
                
                return verificationAsync.when(
                  data: (result) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _isVerifying = false;
                      });
                    });
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: result.isValid ? Colors.green[50] : Colors.red[50],
                        border: Border.all(
                          color: result.isValid ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.isValid ? '✅ Valid Certificate' : '❌ Invalid Certificate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: result.isValid ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          if (result.certificate != null) ...[
                            const SizedBox(height: 8),
                            Text('Name: ${result.certificate!.name}'),
                            Text('DOB: ${result.certificate!.dateOfBirth}'),
                            Text('Place: ${result.certificate!.placeOfBirth}'),
                          ],
                          if (result.error != null) ...[
                            const SizedBox(height: 8),
                            Text('Error: ${result.error}'),
                          ],
                        ],
                      ),
                    );
                  },
                  loading: () => const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Verifying...'),
                    ],
                  ),
                  error: (error, stack) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _isVerifying = false;
                      });
                    });
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Error: $error'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testVerification() {
    setState(() {
      _isVerifying = true;
    });
    
    // Invalidate and refresh the provider
    ref.invalidate(verifyCertificateByIdProvider);
  }

  void _testRawData() async {
    try {
      final repository = ref.read(verificationRepositoryProvider);
      print('🧪 Testing raw data access...');
      
      // Test the datasource directly
      final datasource = repository.datasource;
      await datasource.debugCertificateId(_controller.text);
      
      // Test the repository method
      final result = await repository.verifyCertificateById(_controller.text);
      print('🧪 Raw result: ${result.isValid ? 'Valid' : 'Invalid'}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Raw test completed. Check console for details.'),
            backgroundColor: result.isValid ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('🧪 Raw test error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Raw test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}