import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';
import 'package:mediminder/widgets/custom_button.dart';
import 'package:mediminder/widgets/custom_text_field.dart';

class EditReminderScreen extends StatefulWidget {
  final MedicineReminder reminder;

  const EditReminderScreen({super.key, required this.reminder});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patientNameController;
  late final TextEditingController _medicineController;
  late final TextEditingController _doseController;
  late final TextEditingController _categoryController;
  late final TextEditingController _otherCategoryController;
  bool _isOtherCategorySelected = false;
  bool _isLoading = false;

  List<TimeOfDay> _selectedTimes = [];
  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _selectedDays = [];

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
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _patientNameController = TextEditingController(
      text: widget.reminder.patientName,
    );
    _medicineController = TextEditingController(text: widget.reminder.medicine);
    _doseController = TextEditingController(text: widget.reminder.dose);
    _categoryController = TextEditingController();
    _otherCategoryController = TextEditingController();

    _selectedTimes = widget.reminder.times.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    _startDate = widget.reminder.startDate;
    _endDate = widget.reminder.endDate;
    _selectedDays = List.from(widget.reminder.days);

    if (_commonCategories.contains(widget.reminder.category)) {
      if (widget.reminder.category == 'Other') {
        _isOtherCategorySelected = true;
      } else {
        _isOtherCategorySelected = false;
      }
      _categoryController.text = widget.reminder.category;
    } else {
      _isOtherCategorySelected = true;
      _otherCategoryController.text = widget.reminder.category;
    }
  }

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
        title: const Text('Edit Reminder'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
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

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _updateReminder,
                      isLoading: _isLoading,
                      child: const Text('Update Reminder'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: _showDeleteDialog,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      child: const Text('Delete'),
                    ),
                  ),
                ],
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

    final dropdownValue =
        !_isOtherCategorySelected &&
            _commonCategories.contains(_categoryController.text)
        ? _categoryController.text
        : (_isOtherCategorySelected ? 'Other' : null);

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
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _isOtherCategorySelected = value == 'Other';
          if (_isOtherCategorySelected) {
            _categoryController.clear();
            // Keep existing value in Other field if user is editing
            if (_otherCategoryController.text.isEmpty) {
              _otherCategoryController.text = '';
            }
          } else {
            _categoryController.text = value ?? '';
            _otherCategoryController.clear();
          }
        });
      },
      validator: (value) {
        if ((value == null || value.isEmpty) && !_isOtherCategorySelected) {
          return 'Please select a category';
        }
        if (_isOtherCategorySelected &&
            (_otherCategoryController.text.isEmpty)) {
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

  Future<void> _updateReminder() async {
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

      final reminderCategory = _isOtherCategorySelected
          ? _otherCategoryController.text.trim()
          : _categoryController.text.trim();

      final updatedReminder = widget.reminder.copyWith(
        patientName: _patientNameController.text.trim(),
        medicine: _medicineController.text.trim(),
        dose: _doseController.text.trim(),
        category: reminderCategory,
        times: times,
        days: _selectedDays,
        startDate: _startDate,
        endDate: _endDate,
        nextSchedule: nextSchedule,
      );

      await context.read<MedicineProvider>().updateReminder(updatedReminder);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder updated successfully'),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete the reminder for ${widget.reminder.medicine}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<MedicineProvider>().deleteReminder(
                  widget.reminder.id,
                );
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder deleted successfully'),
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
