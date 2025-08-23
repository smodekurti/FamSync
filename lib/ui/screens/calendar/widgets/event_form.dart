import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_utils.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_providers.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';

class EventForm extends ConsumerStatefulWidget {
  final Event? event; // null for new event, Event for editing
  final DateTime? initialDate;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  const EventForm({
    super.key,
    this.event,
    this.initialDate,
    this.onSaved,
    this.onCancelled,
  });

  @override
  ConsumerState<EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late EventCategory _category;
  late EventPriority _priority;
  late List<String> _assignedUids;

  @override
  void initState() {
    super.initState();
    
    if (widget.event != null) {
      // Editing existing event
      final event = widget.event!;
      _titleController = TextEditingController(text: event.title);
      _descriptionController = TextEditingController(text: event.description);
      _locationController = TextEditingController(text: event.location ?? '');
      _startDate = event.startTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = event.endTime;
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _category = event.category;
      _priority = event.priority;
      _assignedUids = List.from(event.assignedUids);
    } else {
      // Creating new event
      final now = DateTime.now();
      final initialDate = widget.initialDate ?? now;
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _startDate = initialDate;
      _startTime = TimeOfDay.fromDateTime(now);
      _endDate = initialDate;
      _endTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
      _category = EventCategory.family;
      _priority = EventPriority.medium;
      _assignedUids = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'New Event'),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(spaces.md),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),
            
            SizedBox(height: spaces.md),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: spaces.md),
            
            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    controller: TextEditingController(
                      text: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                  ),
                ),
                SizedBox(width: spaces.md),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _selectTime(context, true),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _startTime.format(context),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                    controller: TextEditingController(
                      text: '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                  ),
                ),
                SizedBox(width: spaces.md),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _selectTime(context, false),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _endTime.format(context),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            
            SizedBox(height: spaces.md),
            
            // Category
            DropdownButtonFormField<EventCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: EventCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            
            SizedBox(height: spaces.md),
            
            // Priority
            DropdownButtonFormField<EventPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: EventPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: spaces.xs,
                        height: spaces.xs,
                        decoration: BoxDecoration(
                          color: CalendarUtils.getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: spaces.xs),
                      Text(priority.name.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user ID and family ID
        final userProfile = ref.read(userProfileStreamProvider).value;
        if (userProfile?.familyId == null || userProfile?.uid == null) {
          throw Exception('User not in a family or user ID missing');
        }

        // Create the event object
        final event = Event(
          id: widget.event?.id ?? '', // Will be set by repository
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          ),
          endTime: DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          ),
          category: _category,
          priority: _priority,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          assignedUids: _assignedUids,
          familyId: userProfile!.familyId!,
          createdByUid: userProfile.uid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save the event using the calendar notifier
        final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
        await calendarNotifier.createEvent(event);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Call the onSaved callback and close the form
        widget.onSaved?.call();
        Navigator.of(context).pop();
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving event: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
