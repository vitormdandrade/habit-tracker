class Habit {
  final String id;
  final String name;
  final List<HabitDay> history;
  int streak;
  int points;
  int solidLevel; // 0 = normal, 1+ = solid level
  int consecutiveMisses; // Track consecutive misses for solid habits

  // Atomic Habits framework properties
  String? whereAndWhen; // Where and when to execute the habit
  String? bareMinimum; // The bare minimum level
  String? desirableLevel; // The desirable level
  String? makeEasyAndObvious; // How to make the habit easy and obvious

  Habit({
    required this.id, 
    required this.name, 
    required this.history, 
    this.streak = 0, 
    this.points = 0,
    this.solidLevel = 0,
    this.consecutiveMisses = 0,
    this.whereAndWhen,
    this.bareMinimum,
    this.desirableLevel,
    this.makeEasyAndObvious,
  });

  bool get isSolid => solidLevel > 0;
  
  // Get the number of consecutive misses allowed before losing solid status
  int get allowedMisses => solidLevel * 3;
  
  // Check if all Atomic Habits properties are filled
  bool get hasCompleteAtomicHabitsPlan => 
    whereAndWhen != null && 
    whereAndWhen!.isNotEmpty &&
    bareMinimum != null && 
    bareMinimum!.isNotEmpty &&
    desirableLevel != null && 
    desirableLevel!.isNotEmpty &&
    makeEasyAndObvious != null && 
    makeEasyAndObvious!.isNotEmpty;
}

class HabitDay {
  final DateTime date;
  final bool completed;

  HabitDay({required this.date, required this.completed});
}

class DayStats {
  final DateTime date;
  final int streak;
  final int points;

  DayStats({required this.date, required this.streak, required this.points});
}

// Move Achievement to top level
class Achievement {
  final String id;
  final String title;
  final String description;
  final bool achieved;
  Achievement({required this.id, required this.title, required this.description, required this.achieved});
}

class HabitTracker {
  final List<Habit> habits;
  int streak;
  int initialHabits;
  int points;
  int streakBreaks = 0; // Counts streak breaks before reaching 14
  int creditsPenalty = 0; // Tracks credits lost due to forced removals
  DateTime? startDate; // When the user started using the app
  int maxStreak = 0; // Maximum streak ever reached
  List<DayStats> dailyStats = []; // Historical stats for each day

  HabitTracker({required this.habits, this.streak = 0, this.points = 0}) : initialHabits = habits.length {
    startDate ??= DateTime.now();
  }

  /// Check if a habit has been active for the last 50 days
  bool _isHabitActiveForLast50Days(Habit habit, DateTime currentDay) {
    final fiftyDaysAgo = currentDay.subtract(const Duration(days: 50));
    
    for (int i = 0; i < 50; i++) {
      final day = currentDay.subtract(Duration(days: i));
      final dayEntry = habit.history.where((h) => isSameDay(h.date, day)).toList();
      
      // If no entry for this day, habit wasn't active
      if (dayEntry.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  /// Update solid levels when streak reaches multiples of 50
  void _updateSolidLevels(DateTime currentDay) {
    if (streak % 50 != 0) return; // Only update at multiples of 50
    
    for (final habit in habits) {
      if (_isHabitActiveForLast50Days(habit, currentDay)) {
        if (habit.solidLevel == 0) {
          // Normal habit becomes Solid Level 1
          habit.solidLevel = 1;
          habit.consecutiveMisses = 0;
        } else {
          // Solid habit goes up one level
          habit.solidLevel++;
          habit.consecutiveMisses = 0;
        }
      }
    }
  }

  /// Update consecutive misses for solid habits
  void _updateSolidHabitMisses(Habit habit, bool wasCompletedToday) {
    if (habit.isSolid) {
      if (wasCompletedToday) {
        habit.consecutiveMisses = 0;
      } else {
        habit.consecutiveMisses++;
        
        // Check if habit should lose solid status
        if (habit.consecutiveMisses >= habit.allowedMisses) {
          habit.solidLevel = 0;
          habit.consecutiveMisses = 0;
        }
      }
    }
  }

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
    int nonSolidCompletedToday = 0;

    for (final habit in habits) {
      final todayEntry = habit.history.where((h) => isSameDay(h.date, today)).toList();
      final yesterdayEntry = habit.history.where((h) => isSameDay(h.date, yesterday)).toList();

      final isCompletedToday = todayEntry.isNotEmpty ? todayEntry.first.completed : false;
      final isCompletedYesterday = yesterdayEntry.isNotEmpty ? yesterdayEntry.first.completed : false;

      if (!isCompletedToday) missedToday.add(habit);
      if (!isCompletedYesterday) missedYesterday.add(habit);
      if (isCompletedToday) {
        completedToday++;
        if (!habit.isSolid) {
          nonSolidCompletedToday++;
        }
      }

      // Update per-habit streak and points
      if (isCompletedToday) {
        habit.streak = (yesterdayEntry.isNotEmpty ? (isCompletedYesterday ? habit.streak : 0) : habit.streak) + 1;
        habit.points++;
      } else {
        habit.streak = 0;
      }

      // Update solid habit misses
      _updateSolidHabitMisses(habit, isCompletedToday);
    }

    // Add points for each completed habit today
    points += completedToday;

    bool streakWasBroken = false;
    bool reached14 = streak >= 14;

    // Check if we have enough completed habits for streak continuation
    // Solid habits don't count against the streak
    List<Habit> nonSolidMissedToday = missedToday.where((h) => !h.isSolid).toList();

    // If no non-solid habits completed, streak cannot increase
    if (nonSolidCompletedToday == 0) {
      if (!reached14) streakBreaks++;
      streak = 0;
      streakWasBroken = true;
    } else if (n == 1) {
      // If only 1 habit, must complete it (unless it's solid)
      if (missedToday.isEmpty || (missedToday.length == 1 && missedToday.first.isSolid)) {
        streak++;
      } else {
        if (!reached14) streakBreaks++;
        streak = 0;
        streakWasBroken = true;
      }
    } else {
      // If more than 1 habit, can miss at most 1 non-solid habit, but not the same habit two days in a row
      if (nonSolidMissedToday.length == 0 || nonSolidMissedToday.length == 1) {
        if (nonSolidMissedToday.length == 1) {
          final missedHabit = nonSolidMissedToday.first;
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

    // Update solid levels when streak reaches multiples of 50
    _updateSolidLevels(today);

    // Update max streak
    if (streak > maxStreak) {
      maxStreak = streak;
    }

    // Record daily stats
    dailyStats.add(DayStats(
      date: day,
      streak: streak,
      points: points,
    ));

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
    maxStreak = 0;
    dailyStats.clear();
    startDate = DateTime.now();
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

  /// Returns true if the user has completed enough habits for the streak to continue
  /// This considers the rule that the same habit cannot be missed two days in a row
  /// Solid habits don't count against the streak
  bool hasCompletedEnoughForStreakContinuation(DateTime day) {
    if (habits.isEmpty) return false;
    
    final today = day;
    final yesterday = today.subtract(const Duration(days: 1));
    
    int completedCount = 0;
    List<Habit> missedToday = [];
    List<Habit> nonSolidMissedToday = [];
    
    for (final habit in habits) {
      final todayEntry = habit.history.where((h) => isSameDay(h.date, today)).toList();
      final isCompletedToday = todayEntry.isNotEmpty ? todayEntry.first.completed : false;
      
      if (isCompletedToday) {
        completedCount++;
      } else {
        missedToday.add(habit);
        if (!habit.isSolid) {
          nonSolidMissedToday.add(habit);
        }
      }
    }
    
    // If no non-solid habits completed, streak cannot continue
    if (completedCount == 0) {
      return false;
    }
    
    // If only 1 habit, must complete it (unless it's solid)
    if (habits.length == 1) {
      return completedCount == 1 || (missedToday.length == 1 && missedToday.first.isSolid);
    }
    
    // For multiple habits, can miss at most 1 non-solid habit, but not the same habit two days in a row
    if (nonSolidMissedToday.length == 0) {
      return true; // All non-solid habits completed
    } else if (nonSolidMissedToday.length == 1) {
      final missedHabit = nonSolidMissedToday.first;
      // Check if the missed habit was also missed yesterday
      final anyHistoryYesterday = habits.any((habit) => habit.history.any((h) => isSameDay(h.date, yesterday)));
      
      if (anyHistoryYesterday) {
        final yesterdayEntry = missedHabit.history.where((h) => isSameDay(h.date, yesterday)).toList();
        final wasMissedYesterday = yesterdayEntry.isEmpty || !yesterdayEntry.first.completed;
        
        // If the habit was missed yesterday too, streak cannot continue
        if (wasMissedYesterday) {
          return false;
        }
      }
      return true; // Can miss this habit today since it wasn't missed yesterday
    } else {
      // Missing more than 1 non-solid habit, streak cannot continue
      return false;
    }
  }

  /// Returns the number of habits completed on a specific day
  int getCompletedHabitsForDay(DateTime day) {
    int completedCount = 0;
    for (final habit in habits) {
      final dayEntry = habit.history.where((h) => isSameDay(h.date, day)).toList();
      if (dayEntry.isNotEmpty && dayEntry.first.completed) {
        completedCount++;
      }
    }
    return completedCount;
  }

  /// Returns the number of habits completed yesterday
  int getCompletedHabitsYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return getCompletedHabitsForDay(yesterday);
  }

  /// Returns the number of habits completed on the day before the given date
  int getCompletedHabitsForDayBefore(DateTime date) {
    final dayBefore = date.subtract(const Duration(days: 1));
    return getCompletedHabitsForDay(dayBefore);
  }

  // Tier calculation
  int get tierPoints {
    int points = this.points;
    int streakPoints = (maxStreak > streak ? maxStreak : streak) * 3;
    int solidPoints = habits.where((h) => h.isSolid).length * 50;
    return points + streakPoints + solidPoints;
  }

  String get tierName {
    final tp = tierPoints;
    if (tp < 30) return 'Newbie';
    if (tp < 90) return 'Novice';
    if (tp < 200) return 'Challenger';
    if (tp < 500) return 'Pro';
    if (tp < 1000) return 'Expert';
    if (tp < 2000) return 'Master';
    if (tp < 5000) return 'Grand Master';
    return 'Hall of Fame';
  }

  int get tierMin {
    final tp = tierPoints;
    if (tp < 30) return 0;
    if (tp < 90) return 30;
    if (tp < 200) return 90;
    if (tp < 500) return 200;
    if (tp < 1000) return 500;
    if (tp < 2000) return 1000;
    if (tp < 5000) return 2000;
    return 5000;
  }

  int get tierMax {
    final tp = tierPoints;
    if (tp < 30) return 30;
    if (tp < 90) return 90;
    if (tp < 200) return 200;
    if (tp < 500) return 500;
    if (tp < 1000) return 1000;
    if (tp < 2000) return 2000;
    if (tp < 5000) return 5000;
    return 999999;
  }

  double get tierProgress => (tierPoints - tierMin) / (tierMax - tierMin);

  // Achievements
  List<Achievement> get achievements {
    final List<Achievement> all = [
      Achievement(
        id: 'streak7',
        title: '7 Day Streak',
        description: 'Reach a 7 day streak',
        achieved: maxStreak >= 7,
      ),
      Achievement(
        id: 'streak30',
        title: '30 Day Streak',
        description: 'Reach a 30 day streak',
        achieved: maxStreak >= 30,
      ),
      Achievement(
        id: 'streak100',
        title: '100 Day Streak',
        description: 'Reach a 100 day streak',
        achieved: maxStreak >= 100,
      ),
      Achievement(
        id: 'points7',
        title: '7 Points',
        description: 'Reach 7 points',
        achieved: points >= 7,
      ),
      Achievement(
        id: 'points30',
        title: '30 Points',
        description: 'Reach 30 points',
        achieved: points >= 30,
      ),
      Achievement(
        id: 'points100',
        title: '100 Points',
        description: 'Reach 100 points',
        achieved: points >= 100,
      ),
      Achievement(
        id: 'solid1',
        title: 'Solid Habit',
        description: 'Get 1 solid habit',
        achieved: habits.where((h) => h.isSolid).length >= 1,
      ),
      Achievement(
        id: 'solid2',
        title: '2 Solid Habits',
        description: 'Get 2 solid habits',
        achieved: habits.where((h) => h.isSolid).length >= 2,
      ),
      Achievement(
        id: 'solid5',
        title: '5 Solid Habits',
        description: 'Get 5 solid habits',
        achieved: habits.where((h) => h.isSolid).length >= 5,
      ),
    ];
    return all;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 







