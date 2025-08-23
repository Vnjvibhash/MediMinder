import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';
import 'package:mediminder/widgets/custom_text_field.dart';
import 'package:mediminder/widgets/custom_button.dart';

class AddOrEditPatientModal extends StatefulWidget {
  final Patient? patient;

  const AddOrEditPatientModal({super.key, this.patient});

  @override
  State<AddOrEditPatientModal> createState() => _AddOrEditPatientModalState();
}

class _AddOrEditPatientModalState extends State<AddOrEditPatientModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late String _selectedGender;
  late final bool _isEditing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.patient != null;
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _ageController = TextEditingController(
      text: widget.patient?.age.toString() ?? '',
    );
    _selectedGender = widget.patient?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _isEditing ? 'Edit Patient' : 'Add Patient',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Name field
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Age field
          CustomTextField(
            controller: _ageController,
            label: 'Age',
            prefixIcon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Gender dropdown
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(
                Icons.people_outline,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: ['Male', 'Female', 'Other']
                .map(
                  (gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _selectedGender = value ?? 'Male');
            },
          ),
          const SizedBox(height: 24),

          // Save/Update button
          CustomButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditing ? 'Update Patient' : 'Add Patient'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }
    // Validate age similarly...

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        final updatedPatient = widget.patient!.copyWith(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: _selectedGender,
        );
        await context.read<MedicineProvider>().updatePatient(updatedPatient);
      } else {
        final newPatient = Patient(
          id: '',
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: _selectedGender,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await context.read<MedicineProvider>().addPatient(newPatient);
      }

      if (context.mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Patient updated successfully'
                  : 'Patient added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
