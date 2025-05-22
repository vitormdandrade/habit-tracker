import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final List<HabitDay> history;
  int streak;
  int points;

  Habit({required this.id, required this.name, required this.history, this.streak = 0, this.points = 0});
}

class HabitDay {
  final DateTime date;
  final bool completed;

  HabitDay({required this.date, required this.completed});
}

class HabitTracker {
  final List<Habit> habits;
  int streak;
  int initialHabits;
  int points;

  HabitTracker({required this.habits, this.streak = 0, this.points = 0}) : initialHabits = habits.length;

  /// Call this at the end of each day to update the streak.
  void updateStreak(DateTime day) {
    if (habits.isEmpty) return;
    final today = day;
    final yesterday = today.subtract(const Duration(days: 1));

    int n = habits.length;
    List<Habit> missedToday = [];
    List<Habit> missedYesterday = [];
    int completedToday = 0;

    for (final habit in habits) {
      final todayEntry = habit.history.where((h) => isSameDay(h.date, today)).toList();
      final yesterdayEntry = habit.history.where((h) => isSameDay(h.date, yesterday)).toList();

      final isCompletedToday = todayEntry.isNotEmpty ? todayEntry.first.completed : false;
      final isCompletedYesterday = yesterdayEntry.isNotEmpty ? yesterdayEntry.first.completed : false;

      if (!isCompletedToday) missedToday.add(habit);
      if (!isCompletedYesterday) missedYesterday.add(habit);
      if (isCompletedToday) completedToday++;

      // Update per-habit streak and points
      if (isCompletedToday) {
        habit.streak = (yesterdayEntry.isNotEmpty ? (isCompletedYesterday ? habit.streak : 0) : habit.streak) + 1;
        habit.points++;
      } else {
        habit.streak = 0;
      }
    }

    // Add points for each completed habit today
    points += completedToday;

    // If no habits completed, streak cannot increase
    if (completedToday == 0) {
      streak = 0;
      return;
    }

    // If only 1 habit, must complete it
    if (n == 1) {
      if (missedToday.isEmpty) {
        streak++;
      } else {
        streak = 0;
      }
      return;
    }

    // If more than 1 habit, can miss at most 1, but not the same habit two days in a row
    if (missedToday.length == 0 || missedToday.length == 1) {
      if (missedToday.length == 1) {
        final missedHabit = missedToday.first;
        // Only apply the missed-yesterday check if any habit has a history for yesterday
        final anyHistoryYesterday = habits.any((habit) => habit.history.any((h) => isSameDay(h.date, yesterday)));
        if (anyHistoryYesterday) {
          final yesterdayEntry = missedHabit.history.where((h) => isSameDay(h.date, yesterday)).toList();
          final wasMissedYesterday = yesterdayEntry.isEmpty || !yesterdayEntry.first.completed;
          if (wasMissedYesterday) {
            streak = 0;
            return;
          }
        }
      }
      streak++;
    } else {
      streak = 0;
    }
  }

  /// Can add a new habit if current habits < initialHabits + credits
  bool canAddHabit() {
    int credits = streak ~/ 14;
    return habits.length < initialHabits + credits;
  }

  void reset() {
    streak = 0;
    points = 0;
    for (final habit in habits) {
      habit.history.clear();
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 







