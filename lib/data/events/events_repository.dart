import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fam_sync/domain/models/event.dart';

class EventsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Firebase connection
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get events for a family within a date range
  Stream<List<Event>> getEventsStream(String familyId, DateTime start, DateTime end) {
    try {
      return _firestore
        .collection('events')
          .where('familyId', isEqualTo: familyId)
          .snapshots()
          .handleError((error) {
            throw Exception('Failed to fetch events: $error');
          })
          .map((snapshot) {
            // Parse all events first
            final allEvents = snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return Event.fromJson({...data, 'id': doc.id});
              } catch (parseError) {
                throw parseError;
              }
            }).toList();
            
            // Filter by date range in memory
            final filteredEvents = allEvents.where((event) {
              final eventDate = event.startTime;
              return eventDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
                     eventDate.isBefore(end);
            }).toList();
            
            // Sort by start time
            filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
            
            return filteredEvents;
          });
    } catch (e) {
      rethrow;
    }
  }

  // Get all events for a family
  Stream<List<Event>> getAllEventsStream(String familyId) {
    return _firestore
        .collection('events')
        .where('familyId', isEqualTo: familyId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
            .toList());
  }

  // Get events for a specific user
  Stream<List<Event>> getUserEventsStream(String familyId, String userId) {
    return _firestore
        .collection('events')
        .where('familyId', isEqualTo: familyId)
        .where('assignedUids', arrayContains: userId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson({...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
            .toList());
  }

  // Create a new event
  Future<void> createEvent(Event event) async {
    try {
      final docRef = _firestore.collection('events').doc();
      final eventData = event.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toJson();
      
      await docRef.set(eventData);
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    final eventData = event.copyWith(
      updatedAt: DateTime.now(),
    ).toJson();
    
    await _firestore
        .collection('events')
        .doc(event.id)
        .update(eventData);
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .delete();
  }

  // Get events for today
  Stream<List<Event>> getTodayEventsStream(String familyId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getEventsStream(familyId, startOfDay, endOfDay);
  }

  // Get upcoming events (next 7 days)
  Stream<List<Event>> getUpcomingEventsStream(String familyId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfWeek = startOfDay.add(const Duration(days: 7));
    
    return getEventsStream(familyId, startOfDay, endOfWeek);
  }

  // Get events for a specific month
  Stream<List<Event>> getMonthEventsStream(String familyId, int year, int month) {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);
      
      return getEventsStream(familyId, startOfMonth, endOfMonth);
    } catch (e) {
      rethrow;
    }
  }
}
