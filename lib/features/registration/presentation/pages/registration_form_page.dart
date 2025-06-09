import 'package:birth_certify/features/registration/domain/models/registration_model.dart';
import 'package:birth_certify/features/registration/presentation/providers/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationFormPage extends ConsumerStatefulWidget {
  const RegistrationFormPage({super.key});

  @override
  ConsumerState<RegistrationFormPage> createState() =>
      _RegistrationFormPageState();
}

class _RegistrationFormPageState extends ConsumerState<RegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // TODO: Add document upload logic

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
              Text(
                'Register',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              Text(
                'Register a new birth certificate',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: GoogleFonts.albertSans().fontFamily,
                ),
              ),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const Text(
                        "Parent's Information",
                        style: TextStyle(
                          fontSize: 16,
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
                      const Text(
                        "Wallet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: wallet,
                              decoration: const InputDecoration(
                                hintText:
                                    'Wallet to link the birth certificate to',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Generate wallet logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: const Text('Generate wallet'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        "Supporting Documents",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Include supporting documents (e.g., hospital slip, affidavit)",
                      ),

                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: File picker logic
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Document'),
                      ),

                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final request = RegistrationRequest(
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
                                  documentUrl:
                                      null, // TODO: upload and pass file URL
                                );

                                await ref.read(registerBirthProvider(request));
                              }
                            },
                            child: const Text('Submit Registration'),
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

  /// Wraps two widgets in a Row with spacing
  Widget _buildDoubleRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  /// Reusable TextField with label
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
