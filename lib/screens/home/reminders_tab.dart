import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediminder/providers/medicine_provider.dart';
import 'package:mediminder/widgets/reminder_card.dart';
import 'package:mediminder/screens/reminders/add_reminder_screen.dart';
import 'package:mediminder/screens/reminders/edit_reminder_screen.dart';

class RemindersTab extends StatelessWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Medicine Reminders',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  FloatingActionButton.small(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddReminderScreen(),
                        ),
                      );
                      if (result == true && context.mounted) {
                        context.read<MedicineProvider>().loadReminders();
                      }
                    },
                    backgroundColor: theme.colorScheme.onPrimaryContainer,
                    foregroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<MedicineProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => provider.loadReminders(),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.reminders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Reminders Yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first medicine reminder to get started.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddReminderScreen(),
                                ),
                              );
                              if (result == true && context.mounted) {
                                provider.loadReminders();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Reminder'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.loadReminders();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = provider.reminders[index];
                        return ReminderCard(
                          reminder: reminder,
                          showActions: false,
                          onEdit: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditReminderScreen(reminder: reminder),
                              ),
                            );
                            if (result == true && context.mounted) {
                              provider.loadReminders();
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
