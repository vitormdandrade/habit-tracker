import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../habit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Get user's habit tracker data
  Future<HabitTracker?> getHabitTracker() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      
      // Convert habits from Firestore format
      final List<Habit> habits = [];
      if (data['habits'] != null) {
        for (var habitData in data['habits']) {
          final List<HabitDay> history = [];
          if (habitData['history'] != null) {
            for (var dayData in habitData['history']) {
              history.add(HabitDay(
                date: (dayData['date'] as Timestamp).toDate(),
                completed: dayData['completed'] ?? false,
              ));
            }
          }

          habits.add(Habit(
            id: habitData['id'] ?? '',
            name: habitData['name'] ?? '',
            history: history,
            streak: habitData['streak'] ?? 0,
            points: habitData['points'] ?? 0,
            solidLevel: habitData['solidLevel'] ?? 0,
            consecutiveMisses: habitData['consecutiveMisses'] ?? 0,
          ));
        }
      }

      // Convert daily stats from Firestore format
      final List<DayStats> dailyStats = [];
      if (data['dailyStats'] != null) {
        for (var statsData in data['dailyStats']) {
          dailyStats.add(DayStats(
            date: (statsData['date'] as Timestamp).toDate(),
            streak: statsData['streak'] ?? 0,
            points: statsData['points'] ?? 0,
          ));
        }
      }

      final tracker = HabitTracker(habits: habits);
      tracker.streak = data['streak'] ?? 0;
      tracker.points = data['points'] ?? 0;
      tracker.streakBreaks = data['streakBreaks'] ?? 0;
      tracker.creditsPenalty = data['creditsPenalty'] ?? 0;
      tracker.maxStreak = data['maxStreak'] ?? 0;
      tracker.startDate = data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now();
      tracker.dailyStats = dailyStats;

      return tracker;
    } catch (e) {
      print('Error loading habit tracker: $e');
      return null;
    }
  }

  // Save user's habit tracker data
  Future<void> saveHabitTracker(HabitTracker tracker) async {
    if (_userId == null) return;

    try {
      // Convert habits to Firestore format
      final List<Map<String, dynamic>> habitsData = [];
      for (var habit in tracker.habits) {
        final List<Map<String, dynamic>> historyData = [];
        for (var day in habit.history) {
          historyData.add({
            'date': Timestamp.fromDate(day.date),
            'completed': day.completed,
          });
        }

        habitsData.add({
          'id': habit.id,
          'name': habit.name,
          'history': historyData,
          'streak': habit.streak,
          'points': habit.points,
          'solidLevel': habit.solidLevel,
          'consecutiveMisses': habit.consecutiveMisses,
        });
      }

      // Convert daily stats to Firestore format
      final List<Map<String, dynamic>> dailyStatsData = [];
      for (var stats in tracker.dailyStats) {
        dailyStatsData.add({
          'date': Timestamp.fromDate(stats.date),
          'streak': stats.streak,
          'points': stats.points,
        });
      }

      final data = {
        'habits': habitsData,
        'streak': tracker.streak,
        'points': tracker.points,
        'streakBreaks': tracker.streakBreaks,
        'creditsPenalty': tracker.creditsPenalty,
        'maxStreak': tracker.maxStreak,
        'startDate': tracker.startDate != null 
            ? Timestamp.fromDate(tracker.startDate!)
            : Timestamp.fromDate(DateTime.now()),
        'dailyStats': dailyStatsData,
        'lastUpdated': Timestamp.now(),
      };

      await _firestore.collection('users').doc(_userId).set(data);
    } catch (e) {
      print('Error saving habit tracker: $e');
      throw 'Failed to save data. Please try again.';
    }
  }

  // Create initial user document
  Future<void> createUserDocument(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'createdAt': Timestamp.now(),
        'habits': [],
        'streak': 0,
        'points': 0,
        'streakBreaks': 0,
        'creditsPenalty': 0,
        'maxStreak': 0,
        'startDate': Timestamp.now(),
        'dailyStats': [],
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Delete user data
  Future<void> deleteUserData() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      throw 'Failed to delete user data. Please try again.';
    }
  }

  // Stream for real-time updates
  Stream<HabitTracker?> habitTrackerStream() {
    if (_userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      
      // Convert habits from Firestore format
      final List<Habit> habits = [];
      if (data['habits'] != null) {
        for (var habitData in data['habits']) {
          final List<HabitDay> history = [];
          if (habitData['history'] != null) {
            for (var dayData in habitData['history']) {
              history.add(HabitDay(
                date: (dayData['date'] as Timestamp).toDate(),
                completed: dayData['completed'] ?? false,
              ));
            }
          }

          habits.add(Habit(
            id: habitData['id'] ?? '',
            name: habitData['name'] ?? '',
            history: history,
            streak: habitData['streak'] ?? 0,
            points: habitData['points'] ?? 0,
            solidLevel: habitData['solidLevel'] ?? 0,
            consecutiveMisses: habitData['consecutiveMisses'] ?? 0,
          ));
        }
      }

      // Convert daily stats from Firestore format
      final List<DayStats> dailyStats = [];
      if (data['dailyStats'] != null) {
        for (var statsData in data['dailyStats']) {
          dailyStats.add(DayStats(
            date: (statsData['date'] as Timestamp).toDate(),
            streak: statsData['streak'] ?? 0,
            points: statsData['points'] ?? 0,
          ));
        }
      }

      final tracker = HabitTracker(habits: habits);
      tracker.streak = data['streak'] ?? 0;
      tracker.points = data['points'] ?? 0;
      tracker.streakBreaks = data['streakBreaks'] ?? 0;
      tracker.creditsPenalty = data['creditsPenalty'] ?? 0;
      tracker.maxStreak = data['maxStreak'] ?? 0;
      tracker.startDate = data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now();
      tracker.dailyStats = dailyStats;

      return tracker;
    });
  }
} 