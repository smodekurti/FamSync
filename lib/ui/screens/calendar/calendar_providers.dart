import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/data/events/events_repository.dart';
import 'package:fam_sync/domain/models/event.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';


// Repository provider
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository();
});

// Test Firebase connection provider
final firebaseConnectionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(eventsRepositoryProvider);
  return await repository.testConnection();
});

// Calendar view state provider
final calendarViewProvider = StateProvider<CalendarView>((ref) => CalendarView.month);

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Current month provider
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Events for current month provider
final monthEventsProvider = StreamProvider.family<List<Event>, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final currentMonth = ref.watch(currentMonthProvider);
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getMonthEventsStream(familyId, currentMonth.year, currentMonth.month);
});

// Today's events provider
final todayEventsProvider = StreamProvider.family<List<Event>, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getTodayEventsStream(familyId);
});

// Upcoming events provider (next 7 days)
final upcomingEventsProvider = StreamProvider.family<List<Event>, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getUpcomingEventsStream(familyId);
});

// User events provider
final userEventsProvider = StreamProvider.family<List<Event>, MapEntry<String, String>>((ref, entry) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final familyId = entry.key;
  final userId = entry.value;
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getUserEventsStream(familyId, userId);
});

// Calendar notifier for managing calendar state
class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier(this.ref) : super(CalendarState.initial());

  final Ref ref;

  void setView(CalendarView view) {
    state = state.copyWith(currentView: view);
  }

  void setSelectedDate(DateTime date) {
    ref.read(selectedDateProvider.notifier).state = date;
    state = state.copyWith(selectedDate: date);
  }

  void setCurrentMonth(DateTime month) {
    ref.read(currentMonthProvider.notifier).state = month;
    state = state.copyWith(currentMonth: month);
  }

  void setFamilyId(String familyId) {
    state = state.copyWith(familyId: familyId);
  }

  void nextMonth() {
    final current = state.currentMonth;
    final next = DateTime(current.year, current.month + 1, 1);
    setCurrentMonth(next);
  }

  void previousMonth() {
    final current = state.currentMonth;
    final previous = DateTime(current.year, current.month - 1, 1);
    setCurrentMonth(previous);
  }

  void goToToday() {
    final today = DateTime.now();
    setSelectedDate(today);
    setCurrentMonth(DateTime(today.year, today.month, 1));
  }

  Future<void> createEvent(Event event) async {
    final repository = ref.read(eventsRepositoryProvider);
    await repository.createEvent(event);
    
    // Invalidate the events streams to refresh the calendar
    ref.invalidate(monthEventsProvider(event.familyId));
    ref.invalidate(todayEventsProvider(event.familyId));
    ref.invalidate(upcomingEventsProvider(event.familyId));
  }

  Future<void> updateEvent(Event event) async {
    final repository = ref.read(eventsRepositoryProvider);
    await repository.updateEvent(event);
    
    // Invalidate the events streams to refresh the calendar
    ref.invalidate(monthEventsProvider(event.familyId));
    ref.invalidate(todayEventsProvider(event.familyId));
    ref.invalidate(upcomingEventsProvider(event.familyId));
  }

  Future<void> deleteEvent(String eventId) async {
    final repository = ref.read(eventsRepositoryProvider);
    await repository.deleteEvent(eventId);
    
    // Invalidate the events streams using familyId from state
    if (state.familyId != null) {
      ref.invalidate(monthEventsProvider(state.familyId!));
      ref.invalidate(todayEventsProvider(state.familyId!));
      ref.invalidate(upcomingEventsProvider(state.familyId!));
    }
  }
}

final calendarNotifierProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref);
});

// Calendar state
class CalendarState {
  final CalendarView currentView;
  final DateTime selectedDate;
  final DateTime currentMonth;
  final String? familyId;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.currentView,
    required this.selectedDate,
    required this.currentMonth,
    this.familyId,
    this.isLoading = false,
    this.error,
  });

  factory CalendarState.initial() => CalendarState(
    currentView: CalendarView.month,
    selectedDate: DateTime.now(),
    currentMonth: DateTime.now(),
    familyId: null,
  );

  CalendarState copyWith({
    CalendarView? currentView,
    DateTime? selectedDate,
    DateTime? currentMonth,
    String? familyId,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      currentView: currentView ?? this.currentView,
      selectedDate: selectedDate ?? this.selectedDate,
      currentMonth: currentMonth ?? this.currentMonth,
      familyId: familyId ?? this.familyId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Calendar view types
enum CalendarView {
  month,
  week,
  day,
  agenda,
}
