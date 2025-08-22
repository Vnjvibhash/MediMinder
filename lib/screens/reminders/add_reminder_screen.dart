import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';
import 'package:mediminder/widgets/custom_button.dart';
import 'package:mediminder/widgets/custom_text_field.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _medicineController = TextEditingController();
  final _doseController = TextEditingController();
  final _categoryController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();

  final List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _isOtherCategorySelected = false;

  final List<String> _selectedDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<String> _commonCategories = [
    'Heart',
    'Diabetes',
    'Blood Pressure',
    'Cholesterol',
    'Pain Relief',
    'Vitamin',
    'Antibiotic',
    'Mental Health',
    'Allergy',
    'Digestive',
    'Other',
  ];

  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _medicineController.dispose();
    _doseController.dispose();
    _categoryController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Patient Information', Icons.person),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('Medicine Details', Icons.medication_liquid),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _medicineController,
                label: 'Medicine Name',
                prefixIcon: Icons.medication_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _doseController,
                label: 'Dose (e.g., 500mg, 2 tablets)',
                prefixIcon: Icons.local_pharmacy,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dose information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              if (_isOtherCategorySelected)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomTextField(
                    controller: _otherCategoryController,
                    label: 'Enter category',
                    prefixIcon: Icons.edit,
                    validator: (value) {
                      if (_isOtherCategorySelected &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter a category';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 32),

              _buildSectionHeader('Schedule', Icons.schedule),
              const SizedBox(height: 16),
              _buildTimesSection(),
              const SizedBox(height: 24),
              _buildDaysSection(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 40),

              CustomButton(
                onPressed: _isLoading ? null : _saveReminder,
                isLoading: _isLoading,
                child: const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final theme = Theme.of(context);
    final dropdownValue = _commonCategories.contains(_categoryController.text)
        ? _categoryController.text
        : 'Other';

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(
        labelText: 'Category/Condition',
        prefixIcon: Icon(
          Icons.category_outlined,
          color: theme.colorScheme.onSurface.withAlpha(60),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withAlpha(30),
          ),
        ),
      ),
      items: _commonCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category, style: const TextStyle(fontSize: 18)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _categoryController.text = value ?? '';
          _isOtherCategorySelected = value == 'Other';
          if (!_isOtherCategorySelected) {
            _otherCategoryController.clear();
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        if (value == 'Other' && _otherCategoryController.text.isEmpty) {
          return 'Please enter a category';
        }
        return null;
      },
    );
  }

  Widget _buildTimesSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Times',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Time'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return Chip(
              label: Text(time.format(context)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: _selectedTimes.length > 1
                  ? () => _removeTime(index)
                  : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaysSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected = _selectedDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateTile(
                'Start Date',
                _startDate,
                () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTile(
                'End Date',
                _endDate,
                () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTimes.add(time);
        _selectedTimes.sort((a, b) => a.hour.compareTo(b.hour));
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
    });
  }

  void _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one time')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final times = _selectedTimes
          .map(
            (t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
          )
          .toList();
      final nextSchedule = _calculateNextSchedule();

      final reminder = MedicineReminder(
        id: '',
        patientId: '',
        patientName: _patientNameController.text.trim(),
        medicine: _medicineController.text.trim(),
        dose: _doseController.text.trim(),
        category: _categoryController.text,
        times: times,
        days: _selectedDays,
        startDate: _startDate,
        endDate: _endDate,
        active: true,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        nextSchedule: nextSchedule,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<MedicineProvider>().addReminder(reminder);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _calculateNextSchedule() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    // Find the next scheduled time today
    for (final time in _selectedTimes) {
      if (time.hour > currentTime.hour ||
          (time.hour == currentTime.hour && time.minute > currentTime.minute)) {
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      }
    }

    // If no more times today, schedule for first time tomorrow
    final firstTime = _selectedTimes.first;
    final tomorrow = now.add(const Duration(days: 1));

    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      firstTime.hour,
      firstTime.minute,
    );
  }
}
