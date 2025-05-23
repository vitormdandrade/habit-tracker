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
  int streakBreaks = 0; // Counts streak breaks before reaching 14
  int creditsPenalty = 0; // Tracks credits lost due to forced removals

  HabitTracker({required this.habits, this.streak = 0, this.points = 0}) : initialHabits = habits.length;

  /// Call this at the end of each day to update the streak.
  /// Returns true if forced habit removal is required.
  bool updateStreak(DateTime day) {
    if (habits.isEmpty) return false;
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

    bool streakWasBroken = false;
    bool reached14 = streak >= 14;

    // If no habits completed, streak cannot increase
    if (completedToday == 0) {
      if (!reached14) streakBreaks++;
      streak = 0;
      streakWasBroken = true;
    } else if (n == 1) {
      // If only 1 habit, must complete it
      if (missedToday.isEmpty) {
        streak++;
      } else {
        if (!reached14) streakBreaks++;
        streak = 0;
        streakWasBroken = true;
      }
    } else {
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
              if (!reached14) streakBreaks++;
              streak = 0;
              streakWasBroken = true;
            } else {
              streak++;
            }
          } else {
            streak++;
          }
        } else {
          streak++;
        }
      } else {
        if (!reached14) streakBreaks++;
        streak = 0;
        streakWasBroken = true;
      }
    }

    // Reset streakBreaks if streak reaches 14
    if (streak >= 14) {
      streakBreaks = 0;
    }

    // If 3 breaks before reaching 14 and more than 2 habits, force removal
    if (streakBreaks >= 3 && streak < 14 && habits.length > 2) {
      streakBreaks = 0; // Reset after triggering
      creditsPenalty++;
      return true;
    }
    return false;
  }

  /// Can add a new habit if current habits < initialHabits + credits
  bool canAddHabit() {
    int credits = (streak ~/ 14) - creditsPenalty;
    return habits.length < initialHabits + credits;
  }

  void reset() {
    streak = 0;
    points = 0;
    creditsPenalty = 0;
    for (final habit in habits) {
      habit.history.clear();
    }
  }

  /// Returns true if the user has completed all or all but one of their habits for the given day
  bool hasCompletedEnoughForStreak(DateTime day) {
    if (habits.isEmpty) return false;
    
    int completedCount = 0;
    for (final habit in habits) {
      final dayEntry = habit.history.where((h) => isSameDay(h.date, day)).toList();
      if (dayEntry.isNotEmpty && dayEntry.first.completed) {
        completedCount++;
      }
    }
    
    // If only 1 habit, must complete it
    if (habits.length == 1) {
      return completedCount == 1;
    }
    
    // For multiple habits, can miss at most 1
    return completedCount >= habits.length - 1;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 







