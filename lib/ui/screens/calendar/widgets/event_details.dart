import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/widgets/event_form.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';

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
    final spaces = context.spaces;
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
        padding: EdgeInsets.all(spaces.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header with color indicator
            Container(
              padding: EdgeInsets.all(spaces.md),
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(spaces.sm),
                border: Border.all(
                  color: eventColor,
                  width: spaces.xs / 2,
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
                  
                  SizedBox(height: spaces.xs),
                  
                  // Category and Priority
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: spaces.xs, vertical: spaces.xs / 2),
                        decoration: BoxDecoration(
                          color: eventColor,
                          borderRadius: BorderRadius.circular(spaces.sm),
                        ),
                        child: Text(
                          event.category.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: spaces.xs,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: spaces.xs),
                                              Container(
                          padding: EdgeInsets.symmetric(horizontal: spaces.xs, vertical: spaces.xs / 2),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            borderRadius: BorderRadius.circular(spaces.sm),
                          ),
                          child: Text(
                            event.priority.name.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: spaces.xs,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: spaces.lg),
            
            // Time and Date
            _buildInfoSection(
              context,
              spaces,
              title: 'Time & Date',
              icon: Icons.schedule,
              children: [
                _buildInfoRow(
                  context,
                  spaces,
                  label: 'Start',
                  value: CalendarUtils.formatDateRange(event.startTime, event.startTime),
                  icon: Icons.play_arrow,
                ),
                _buildInfoRow(
                  context,
                  spaces,
                  label: 'End',
                  value: CalendarUtils.formatDateRange(event.endTime, event.endTime),
                  icon: Icons.stop,
                ),
                _buildInfoRow(
                  context,
                  spaces,
                  label: 'Duration',
                  value: CalendarUtils.getDuration(event.startTime, event.endTime),
                  icon: Icons.timer,
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            // Location
            if (event.location != null && event.location!.isNotEmpty)
              _buildInfoSection(
                context,
                spaces,
                title: 'Location',
                icon: Icons.location_on,
                children: [
                  _buildInfoRow(
                    context,
                    spaces,
                    label: 'Address',
                    value: event.location!,
                    icon: Icons.place,
                  ),
                ],
              ),
            
            SizedBox(height: spaces.md),
            
            // Description
            if (event.description.isNotEmpty)
              _buildInfoSection(
                context,
                spaces,
                title: 'Description',
                icon: Icons.description,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: spaces.md),
                    child: Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: spaces.md),
            
            // Participants
            if (event.assignedUids.isNotEmpty)
              _buildInfoSection(
                context,
                spaces,
                title: 'Participants',
                icon: Icons.people,
                children: [
                  // TODO: Show actual participant names from user profiles
                  Padding(
                    padding: EdgeInsets.only(left: spaces.md),
                    child: Text(
                      '${event.assignedUids.length} participant(s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: spaces.md),
            
            // Notes
            if (event.notes != null && event.notes!.isNotEmpty)
              _buildInfoSection(
                context,
                spaces,
                title: 'Notes',
                icon: Icons.note,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: spaces.md),
                    child: Text(
                      event.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: spaces.lg),
            
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
                SizedBox(width: spaces.md),
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
    BuildContext context,
    AppSpacing spaces, {
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
              size: spaces.md,
            ),
            SizedBox(width: spaces.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: spaces.xs),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    AppSpacing spaces, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(left: spaces.md, bottom: spaces.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.onSurfaceVariant,
            size: spaces.md,
          ),
          SizedBox(width: spaces.xs),
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
