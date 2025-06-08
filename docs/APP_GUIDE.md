# Habit Tracker App Guide

## Core Concepts

### 1. Habit Model
- Each habit has:
  - Unique ID
  - Name
  - History of daily completions
  - Individual streak count
  - Points earned

### 2. Daily Tracking
- Each day's completion is recorded as a `HabitDay` with:
  - Date
  - Completion status (true/false)

### 3. Streak System
The app implements a sophisticated streak system with the following rules:

#### Basic Streak Rules
- Streak increases when you complete enough habits for the day
- Streak resets to 0 if you don't complete enough habits
- For multiple habits:
  - You can miss at most 1 habit per day
  - You cannot miss the same habit two days in a row
- For single habit:
  - Must complete the habit to maintain streak

#### Streak Breaks and Penalties
- Tracks streak breaks before reaching 14 days
- After 3 breaks before reaching 14 days:
  - Forces removal of a habit (if you have more than 2 habits)
  - Applies a credits penalty
- Streak breaks reset when:
  - You reach 14 days
  - After a forced habit removal

### 4. Points System
- Points are earned for each completed habit
- Each habit completion = 1 point
- Points are tracked both:
  - Per individual habit
  - Overall for the tracker

### 5. Habit Management
- Initial number of habits is tracked
- New habits can be added based on credits
- Credits are earned by:
  - Reaching 14-day streaks
  - Each 14-day streak = 1 credit
  - Credits are reduced by penalties from forced removals

## Key Features

### 1. Daily Updates
- System automatically updates streaks at the end of each day
- Tracks completion status for each habit
- Updates individual and overall streaks
- Calculates points earned

### 2. Streak Protection
- Prevents streak breaks from the same habit two days in a row
- Allows flexibility with multiple habits (can miss one)
- Strict tracking for single habits

### 3. Progress Tracking
- Maintains history of all habit completions
- Tracks individual habit streaks
- Monitors overall app streak
- Records points earned

### 4. Habit Management
- Limits number of habits based on earned credits
- Implements penalty system for breaking streaks
- Allows reset of all progress if needed

## Technical Implementation

### Data Structures
1. `Habit` class:
   - Stores individual habit data
   - Tracks completion history
   - Maintains individual streak and points

2. `HabitDay` class:
   - Records daily completion status
   - Links to specific dates

3. `HabitTracker` class:
   - Manages all habits
   - Implements streak logic
   - Handles points and credits
   - Controls habit addition/removal

### Key Methods
- `updateStreak()`: Daily streak update logic
- `canAddHabit()`: Checks if new habits can be added
- `hasCompletedEnoughForStreak()`: Validates daily completion
- `reset()`: Resets all progress
- `isSameDay()`: Utility for date comparison

This app implements a sophisticated habit tracking system that balances flexibility with accountability, encouraging consistent habit formation while providing some room for occasional misses. The streak and credit system creates a gamified experience that rewards long-term consistency. 