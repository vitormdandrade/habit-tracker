import 'package:flutter/material.dart';
import 'habit_model.dart';

class StreakNotification extends StatefulWidget {
  final bool isStreakIncreased;
  final int currentStreak;
  final int previousStreak;
  final int completedHabitsYesterday;
  final int totalHabits;
  final int totalPoints;
  final DateTime currentDate;
  final HabitTracker tracker;
  final VoidCallback onDismiss;

  const StreakNotification({
    super.key,
    required this.isStreakIncreased,
    required this.currentStreak,
    required this.previousStreak,
    required this.completedHabitsYesterday,
    required this.totalHabits,
    required this.totalPoints,
    required this.currentDate,
    required this.tracker,
    required this.onDismiss,
  });

  @override
  State<StreakNotification> createState() => _StreakNotificationState();
}

class _StreakNotificationState extends State<StreakNotification> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _textController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  int _currentTextIndex = 0;
  final List<String> _texts = [];
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    // Prepare text content
    _prepareTexts();
    
    // Start animations
    _slideController.forward();
    _startTextSequence();
  }

  void _prepareTexts() {
    final dayNumber = _calculateDayNumber();
    
    _texts.addAll([
      "Welcome to day $dayNumber",
      _getStreakStatusText(),
      _getStreakComment(),
      "${widget.completedHabitsYesterday}/${widget.totalHabits} habits completed yesterday",
      "${widget.totalPoints} total points accumulated",
    ]);
    
    // Add solid habit information if any habits became solid
    final solidHabits = widget.tracker.habits.where((h) => h.isSolid).toList();
    if (solidHabits.isNotEmpty) {
      _texts.add("🎯 ${solidHabits.length} habit${solidHabits.length > 1 ? 's' : ''} achieved Solid status!");
    }
  }

  int _calculateDayNumber() {
    // Calculate days since the user started using the tracker's start date
    final startDate = widget.tracker.startDate ?? DateTime.now();
    final currentDate = widget.currentDate;
    
    // Calculate the difference in days
    final difference = currentDate.difference(startDate).inDays;
    
    // Return day 1 for the first day, day 2 for the second day, etc.
    return difference + 1;
  }

  String _getStreakStatusText() {
    if (widget.isStreakIncreased) {
      return "🔥 Your streak increased to ${widget.currentStreak}!";
    } else {
      return "💔 Your streak was lost";
    }
  }

  String _getStreakComment() {
    if (widget.isStreakIncreased) {
      if (widget.currentStreak == 1) {
        return "Great start! Keep it going!";
      } else if (widget.currentStreak < 7) {
        return "You're building momentum!";
      } else if (widget.currentStreak < 14) {
        return "You're on fire! Consistency is key!";
      } else if (widget.currentStreak < 30) {
        return "Incredible! You're unstoppable!";
      } else {
        return "Legendary! You're a habit master!";
      }
    } else {
      if (widget.previousStreak > 0) {
        return "Don't worry, every setback is a setup for a comeback!";
      } else {
        return "Today is a new beginning!";
      }
    }
  }

  void _startTextSequence() async {
    for (int i = 0; i < _texts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentTextIndex = i;
        });
        _textController.forward(from: 0.0);
      }
    }
    
    // Show continue button after all text is displayed
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _showContinueButton = true;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: const DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Main content area
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome text
                      if (_currentTextIndex >= 0)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _texts[0],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontFamily: 'Aleo',
                              letterSpacing: 0.2,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 40),
                      
                      // Streak status
                      if (_currentTextIndex >= 1)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _texts[1],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.tealAccent,
                              fontFamily: 'Aleo',
                              letterSpacing: 0.2,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // Streak comment
                      if (_currentTextIndex >= 2)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _texts[2],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: Colors.white60,
                              fontFamily: 'Aleo',
                              letterSpacing: 0.1,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 40),
                      
                      // Habits completed
                      if (_currentTextIndex >= 3)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _texts[3],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontFamily: 'Aleo',
                                letterSpacing: 0.2,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Total points
                      if (_currentTextIndex >= 4)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.tealAccent.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _texts[4],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.tealAccent,
                                fontFamily: 'Aleo',
                                letterSpacing: 0.2,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Solid habits information
                      if (_currentTextIndex >= 5 && _texts.length > 5)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.teal,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _texts[5],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal,
                                fontFamily: 'Aleo',
                                letterSpacing: 0.2,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Continue button
                if (_showContinueButton)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Aleo',
                            letterSpacing: 0.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 