import 'package:flutter_test/flutter_test.dart';
import 'package:gradually/habit_model.dart';

void main() {
  group('Streak Continuation Logic Tests', () {
    test('should show +1 when all habits completed', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      final habit2 = Habit(id: '2', name: 'Read', history: []);
      
      final today = DateTime(2024, 1, 15);
      
      // Add completed entries for today
      habit1.history.add(HabitDay(date: today, completed: true));
      habit2.history.add(HabitDay(date: today, completed: true));
      
      final tracker = HabitTracker(habits: [habit1, habit2]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), true);
    });

    test('should show +1 when one habit missed but not missed yesterday', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      final habit2 = Habit(id: '2', name: 'Read', history: []);
      
      final today = DateTime(2024, 1, 15);
      final yesterday = DateTime(2024, 1, 14);
      
      // Add completed entries for today (habit1 completed, habit2 missed)
      habit1.history.add(HabitDay(date: today, completed: true));
      habit2.history.add(HabitDay(date: today, completed: false));
      
      // Add completed entries for yesterday (habit2 was completed yesterday)
      habit1.history.add(HabitDay(date: yesterday, completed: true));
      habit2.history.add(HabitDay(date: yesterday, completed: true));
      
      final tracker = HabitTracker(habits: [habit1, habit2]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), true);
    });

    test('should NOT show +1 when same habit missed two days in a row', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      final habit2 = Habit(id: '2', name: 'Read', history: []);
      
      final today = DateTime(2024, 1, 15);
      final yesterday = DateTime(2024, 1, 14);
      
      // Add completed entries for today (habit1 completed, habit2 missed)
      habit1.history.add(HabitDay(date: today, completed: true));
      habit2.history.add(HabitDay(date: today, completed: false));
      
      // Add completed entries for yesterday (habit2 was also missed yesterday)
      habit1.history.add(HabitDay(date: yesterday, completed: true));
      habit2.history.add(HabitDay(date: yesterday, completed: false));
      
      final tracker = HabitTracker(habits: [habit1, habit2]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), false);
    });

    test('should NOT show +1 when more than one habit missed', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      final habit2 = Habit(id: '2', name: 'Read', history: []);
      final habit3 = Habit(id: '3', name: 'Meditate', history: []);
      
      final today = DateTime(2024, 1, 15);
      
      // Add completed entries for today (only habit1 completed, habit2 and habit3 missed)
      habit1.history.add(HabitDay(date: today, completed: true));
      habit2.history.add(HabitDay(date: today, completed: false));
      habit3.history.add(HabitDay(date: today, completed: false));
      
      final tracker = HabitTracker(habits: [habit1, habit2, habit3]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), false);
    });

    test('should show +1 for single habit when completed', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      
      final today = DateTime(2024, 1, 15);
      
      // Add completed entry for today
      habit1.history.add(HabitDay(date: today, completed: true));
      
      final tracker = HabitTracker(habits: [habit1]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), true);
    });

    test('should NOT show +1 for single habit when missed', () {
      final habit1 = Habit(id: '1', name: 'Exercise', history: []);
      
      final today = DateTime(2024, 1, 15);
      
      // Add missed entry for today
      habit1.history.add(HabitDay(date: today, completed: false));
      
      final tracker = HabitTracker(habits: [habit1]);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), false);
    });

    test('should handle empty habits list', () {
      final today = DateTime(2024, 1, 15);
      final tracker = HabitTracker(habits: []);
      
      expect(tracker.hasCompletedEnoughForStreakContinuation(today), false);
    });
  });
} 