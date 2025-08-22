import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';

class ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onMarkSkipped;
  final VoidCallback? onEdit;
  final bool showActions;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onMarkTaken,
    this.onMarkSkipped,
    this.onEdit,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_liquid,
                    color: _getCategoryColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicine,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reminder.dose} • ${reminder.category}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  reminder.patientName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(reminder.nextSchedule),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (showActions &&
                (onMarkTaken != null || onMarkSkipped != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onMarkTaken != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMarkTaken,
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Mark Taken',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (onMarkTaken != null && onMarkSkipped != null)
                    const SizedBox(width: 12),
                  if (onMarkSkipped != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onMarkSkipped,
                        icon: Icon(
                          Icons.skip_next_outlined,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        label: Text(
                          'Skip',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    final categoryColors = {
      'Heart': Colors.red.shade600,
      'Diabetes': Colors.blue.shade600,
      'Blood Pressure': Colors.purple.shade600,
      'Cholesterol': Colors.orange.shade600,
      'Pain Relief': Colors.green.shade600,
      'Vitamin': Colors.amber.shade600,
      'Antibiotic': Colors.teal.shade600,
      'Mental Health': Colors.indigo.shade600,
    };

    return categoryColors[reminder.category] ?? Colors.grey.shade600;
  }
}
