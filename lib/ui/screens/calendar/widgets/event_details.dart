import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';

class EventDetails extends ConsumerWidget {
  final Event event;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdited;

  const EventDetails({
    super.key,
    required this.event,
    this.onDeleted,
    this.onEdited,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final eventColor = CalendarUtils.getEventColor(event.category);
    final priorityColor = CalendarUtils.getPriorityColor(event.priority);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            onPressed: () => _editEvent(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Event',
          ),
          IconButton(
            onPressed: () => _deleteEvent(context, ref),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Event',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header with color indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: eventColor,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category and Priority
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: eventColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.priority.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time and Date
            _buildInfoSection(
              context,
              title: 'Time & Date',
              icon: Icons.schedule,
              children: [
                _buildInfoRow(
                  context,
                  label: 'Start',
                  value: CalendarUtils.formatDateRange(event.startTime, event.startTime),
                  icon: Icons.play_arrow,
                ),
                _buildInfoRow(
                  context,
                  label: 'End',
                  value: CalendarUtils.formatDateRange(event.endTime, event.endTime),
                  icon: Icons.stop,
                ),
                _buildInfoRow(
                  context,
                  label: 'Duration',
                  value: CalendarUtils.getDuration(event.startTime, event.endTime),
                  icon: Icons.timer,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Location
            if (event.location != null && event.location!.isNotEmpty)
              _buildInfoSection(
                context,
                title: 'Location',
                icon: Icons.location_on,
                children: [
                  _buildInfoRow(
                    context,
                    label: 'Address',
                    value: event.location!,
                    icon: Icons.place,
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Description
            if (event.description.isNotEmpty)
              _buildInfoSection(
                context,
                title: 'Description',
                icon: Icons.description,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Participants
            if (event.assignedUids.isNotEmpty)
              _buildInfoSection(
                context,
                title: 'Participants',
                icon: Icons.people,
                children: [
                  // TODO: Show actual participant names from user profiles
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${event.assignedUids.length} participant(s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Notes
            if (event.notes != null && event.notes!.isNotEmpty)
              _buildInfoSection(
                context,
                title: 'Notes',
                icon: Icons.note,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      event.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editEvent(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Event'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _markAsCompleted(context, ref),
                    icon: const Icon(Icons.check),
                    label: const Text('Mark Complete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent(BuildContext context) {
    Navigator.of(context).push<EventForm>(
      MaterialPageRoute<EventForm>(
        builder: (context) => EventForm(
          event: event,
          onSaved: () {
            onEdited?.call();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _deleteEvent(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.of(context).pop();
              onDeleted?.call();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context, WidgetRef ref) {
    // TODO: Implement mark as completed functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event marked as completed!')),
    );
  }
}
