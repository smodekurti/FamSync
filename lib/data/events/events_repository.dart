import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fam_sync/domain/models/event.dart';

class EventsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Firebase connection
  Future<bool> testConnection() async {
    try {
      print('🔌 Testing Firebase connection...');
      await _firestore.collection('test').limit(1).get();
      print('✅ Firebase connection successful');
      return true;
    } catch (e) {
      print('❌ Firebase connection failed: $e');
      return false;
    }
  }

  // Get events for a family within a date range
  Stream<List<Event>> getEventsStream(String familyId, DateTime start, DateTime end) {
    try {
      print('🔍 Fetching events for family: $familyId, from: $start to: $end');
      print('🔍 Query: familyId == "$familyId" AND startTime >= $start AND startTime < $end');
      
      return _firestore
          .collection('events')
          .where('familyId', isEqualTo: familyId)
          .snapshots()
          .handleError((error) {
            print('❌ Error fetching events: $error');
            throw Exception('Failed to fetch events: $error');
          })
          .map((snapshot) {
            print('📊 Found ${snapshot.docs.length} events in snapshot');
            if (snapshot.docs.isNotEmpty) {
              print('📊 First document data: ${snapshot.docs.first.data()}');
            }
            
            // Parse all events first
            final allEvents = snapshot.docs.map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                print('📄 Processing event document: ${doc.id} - ${data['title']} on ${data['startTime']}');
                return Event.fromJson({...data, 'id': doc.id});
              } catch (parseError) {
                print('❌ Error parsing event document ${doc.id}: $parseError');
                print('📄 Document data: ${doc.data()}');
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
            
            print('📊 Processed ${allEvents.length} total events, filtered to ${filteredEvents.length} events in range');
            return filteredEvents;
          });
    } catch (e) {
      print('❌ Error in getEventsStream: $e');
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
      print('💾 Creating event: ${event.title}');
      print('💾 Event familyId: ${event.familyId}');
      print('💾 Event startTime: ${event.startTime}');
      print('💾 Event endTime: ${event.endTime}');
      
      final docRef = _firestore.collection('events').doc();
      final eventData = event.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toJson();
      
      print('💾 Saving to document: ${docRef.id}');
      print('💾 Event data: $eventData');
      
      await docRef.set(eventData);
      
      print('✅ Event saved successfully to Firestore');
    } catch (e) {
      print('❌ Error creating event: $e');
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
      print('📅 Fetching month events for family: $familyId, year: $year, month: $month');
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);
      
      return getEventsStream(familyId, startOfMonth, endOfMonth);
    } catch (e) {
      print('❌ Error in getMonthEventsStream: $e');
      rethrow;
    }
  }
}
