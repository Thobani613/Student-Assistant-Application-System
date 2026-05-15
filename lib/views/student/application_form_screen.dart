/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Student Assistant Application Form (Create / Update)
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../models/application_model.dart';
import '../../core/theme/app_theme.dart';

// Available modules per academic level
const Map<String, List<String>> modulesByLevel = {
  'First Year': [
    'Introduction to Programming',
    'Computer Literacy',
    'Web Technologies I',
    'Database Fundamentals',
  ],
  'Second Year': [
    'Object-Oriented Programming',
    'Data Structures',
    'Web Technologies II',
    'Systems Analysis',
  ],
  'Third Year': [
    'Technical Programming III',
    'Mobile Development',
    'Software Engineering',
    'Network Security',
  ],
};

class ApplicationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingApplication;

  const ApplicationFormScreen({super.key, this.existingApplication});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _studentNameController = TextEditingController();
  final _studentNumberController = TextEditingController();

  int? _yearOfStudy;
  String? _module1Level;
  String? _module1Name;
  bool _addSecondModule = false;
  String? _module2Level;
  String? _module2Name;
  bool _meetsRequirements = false;
  File? _selectedDocument;
  String? _existingDocumentUrl;

  bool get _isEditing => widget.existingApplication != null;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
    if (_isEditing) _populateExistingData();
  }

  void _prefillFromProfile() {
    final profile = context.read<AuthViewModel>().currentProfile;
    if (profile != null) {
      _studentNameController.text = profile.fullName;
      _studentNumberController.text = profile.studentNumber;
    }
  }

  void _populateExistingData() {
    final app = widget.existingApplication!['application'] as ApplicationModel;
    _studentNameController.text = app.studentName;
    _studentNumberController.text = app.studentNumber;
    _yearOfStudy = app.yearOfStudy;
    _module1Level = app.module1Level;
    _module1Name = app.module1Name;
    _module2Level = app.module2Level;
    _module2Name = app.module2Name;
    _addSecondModule = app.module2Name != null;
    _meetsRequirements = app.meetsMinimumRequirements;
    _existingDocumentUrl = app.documentUrl;
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedDocument = File(result.files.single.path!));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_meetsRequirements) {
      _showSnack('You must confirm that you meet the minimum requirements.', isError: true);
      return;
    }

    final profile = context.read<AuthViewModel>().currentProfile!;
    final appVM = context.read<ApplicationViewModel>();

    if (_isEditing) {
      final existingApp =
          widget.existingApplication!['application'] as ApplicationModel;
      final updates = {
        'year_of_study': _yearOfStudy,
        'module1_level': _module1Level,
        'module1_name': _module1Name,
        'module2_level': _addSecondModule ? _module2Level : null,
        'module2_name': _addSecondModule ? _module2Name : null,
        'meets_minimum_requirements': _meetsRequirements,
      };
      final success = await appVM.updateApplication(
        existingApp.id!,
        updates,
        document: _selectedDocument,
        userId: profile.id,
      );
      if (!mounted) return;
      if (success) {
        _showSnack('Application updated successfully!');
        Navigator.pop(context);
      } else {
        _showSnack(appVM.errorMessage ?? 'Update failed.', isError: true);
      }
    } else {
      final newApp = ApplicationModel(
        userId: profile.id,
        studentName: _studentNameController.text.trim(),
        studentNumber: _studentNumberController.text.trim(),
        yearOfStudy: _yearOfStudy!,
        module1Level: _module1Level!,
        module1Name: _module1Name!,
        module2Level: _addSecondModule ? _module2Level : null,
        module2Name: _addSecondModule ? _module2Name : null,
        meetsMinimumRequirements: _meetsRequirements,
      );
      final success = await appVM.submitApplication(newApp, document: _selectedDocument);
      if (!mounted) return;
      if (success) {
        _showSnack('Application submitted successfully!');
        Navigator.pop(context);
      } else {
        _showSnack(appVM.errorMessage ?? 'Submission failed.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appVM = context.watch<ApplicationViewModel>();
    final isLoading = appVM.state == AppViewState.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Application' : 'Apply for SA Position'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'Personal Information'),
              const SizedBox(height: 12),

              // Student Name (read-only prefilled)
              TextFormField(
                controller: _studentNameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _studentNumberController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Student number is required' : null,
              ),
              const SizedBox(height: 12),

              // Year of study dropdown
              DropdownButtonFormField<int>(
                value: _yearOfStudy,
                decoration: const InputDecoration(
                  labelText: 'Current Year of Study',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: [1, 2, 3]
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('Year $y'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _yearOfStudy = val),
                validator: (v) => v == null ? 'Select your year of study' : null,
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: 'Module 1 (Required)'),
              const SizedBox(height: 12),

              // Module 1 Level
              DropdownButtonFormField<String>(
                value: _module1Level,
                decoration: const InputDecoration(
                  labelText: 'Academic Level',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: modulesByLevel.keys
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _module1Level = val;
                  _module1Name = null; // reset module when level changes
                }),
                validator: (v) => v == null ? 'Select an academic level' : null,
              ),
              const SizedBox(height: 12),

              // Module 1 Name
              DropdownButtonFormField<String>(
                value: _module1Name,
                decoration: const InputDecoration(
                  labelText: 'Module',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: (_module1Level != null
                        ? modulesByLevel[_module1Level!]!
                        : <String>[])
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _module1Name = val),
                validator: (v) => v == null ? 'Select a module' : null,
              ),

              const SizedBox(height: 24),

              // Second module toggle
              SwitchListTile(
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                title: const Text('Apply for a second module (optional)'),
                value: _addSecondModule,
                onChanged: (val) => setState(() {
                  _addSecondModule = val;
                  if (!val) {
                    _module2Level = null;
                    _module2Name = null;
                  }
                }),
              ),

              if (_addSecondModule) ...[
                const _SectionHeader(title: 'Module 2 (Optional)'),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _module2Level,
                  decoration: const InputDecoration(
                    labelText: 'Academic Level',
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                  items: modulesByLevel.keys
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _module2Level = val;
                    _module2Name = null;
                  }),
                  validator: (v) => _addSecondModule && v == null
                      ? 'Select an academic level for Module 2'
                      : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _module2Name,
                  decoration: const InputDecoration(
                    labelText: 'Module',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  items: (_module2Level != null
                          ? modulesByLevel[_module2Level!]!
                          : <String>[])
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) => setState(() => _module2Name = val),
                  validator: (v) => _addSecondModule && v == null
                      ? 'Select a module for Module 2'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 24),
              const _SectionHeader(title: 'Eligibility & Supporting Documents'),
              const SizedBox(height: 12),

              // Eligibility checkbox
              CheckboxListTile(
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'I confirm that I meet the minimum eligibility requirements for the Student Assistant position.',
                    style: TextStyle(fontSize: 14)),
                value: _meetsRequirements,
                onChanged: (val) => setState(() => _meetsRequirements = val!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),

              // Document upload
              InkWell(
                onTap: _pickDocument,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _selectedDocument != null
                            ? AppTheme.successColor
                            : const Color(0xFFDCDFE4)),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedDocument != null
                            ? Icons.check_circle
                            : Icons.upload_file_outlined,
                        color: _selectedDocument != null
                            ? AppTheme.successColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDocument != null
                              ? _selectedDocument!.path.split('/').last
                              : _existingDocumentUrl != null
                                  ? 'Document already uploaded (tap to replace)'
                                  : 'Upload Supporting Document (PDF)',
                          style: TextStyle(
                            color: _selectedDocument != null
                                ? AppTheme.successColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? 'Update Application' : 'Submit Application'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        const Divider(),
      ],
    );
  }
}

