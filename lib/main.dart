import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'habit_model.dart';
import 'streak_notification.dart';
import 'stats_screen.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.deepPurpleAccent,
          background: Color(0xFF111217),
          surface: Color(0xFF181A20),
        ),
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFF111217),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181A20),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontFamily: 'Montserrat', letterSpacing: 0.2, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white60, fontFamily: 'Montserrat', fontWeight: FontWeight.w300, letterSpacing: 0.1, fontSize: 13),
        ),
      ),
      home: const HabitHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> with SingleTickerProviderStateMixin {
  HabitTracker? tracker;
  DateTime _simulatedToday = DateTime.now();
  bool _onboarding = true;
  int? _initialHabitCount;
  int _currentIndex = 0;
  bool _devMode = false;
  int _devModeTapCount = 0;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoadingData = true;
  final List<String> _preMadeHabits = [
    'Running',
    'Reading',
    'Meditation',
    'Studying',
    'Dieting',
    'Training',
    'Journaling',
    'Waking Up Early',
  ];
  final Map<String, String> _habitEmojis = {
    'Running': '🏃',
    'Reading': '📚',
    'Meditation': '🧘',
    'Studying': '📝',
    'Dieting': '🥗',
    'Training': '🏋️',
    'Journaling': '📓',
    'Waking Up Early': '⏰',
  };
  List<String> _selectedHabits = [];
  bool _prevCanAddHabit = false;
  late AnimationController _animationController;
  late DateTime _lastOpenedDate;
  int? _previousStreak;
  bool _isShowingStreakNotification = false;

  @override
  void initState() {
    super.initState();
    _lastOpenedDate = _simulatedToday;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Check if user is authenticated and try to load their data
    final user = _authService.currentUser;
    
    if (user != null) {
      try {
        final loadedTracker = await _firestoreService.getHabitTracker();
        
        if (loadedTracker != null) {
          setState(() {
            tracker = loadedTracker;
            _onboarding = false;
            _isLoadingData = false;
          });
          _animationController.forward();
          return;
        }
      } catch (e) {
        print('Error loading user data: $e');
        // Continue to local onboarding
      }
    }
    
    // No authenticated user or no data - start local onboarding
    setState(() {
      _isLoadingData = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
  }

  Future<void> _saveData() async {
    if (tracker != null) {
      try {
        await _firestoreService.saveHabitTracker(tracker!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAndAnimateNewDay() {
    if (!HabitTracker.isSameDay(_lastOpenedDate, _simulatedToday)) {
      _animationController.forward(from: 0.0);
      _lastOpenedDate = _simulatedToday;
    }
  }

  void _showInitialHabitCountDialog() async {
    int? count = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'How many habits to start?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            fontFamily: 'Montserrat',
            letterSpacing: 0.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose how many habits you want to start with (1-3):',
              style: TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w300,
                fontSize: 12,
                fontFamily: 'Montserrat',
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Login link for existing users
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close onboarding dialog
                _showExistingUserLogin();
              },
              child: const Text(
                'Already a user? Click here to log in',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 3; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.withOpacity(0.85),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(38, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(i),
                    child: Text('$i'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (count != null) {
      setState(() {
        _initialHabitCount = count;
      });
      _showHabitSelectionDialog(count);
    }
  }

  void _showHabitSelectionDialog(int count) async {
    List<String> selected = [];
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              'Select your habits',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                fontFamily: 'Montserrat',
                letterSpacing: 0.2,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pick $count habits to start with:',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ..._preMadeHabits.map((habit) => CheckboxListTile(
                  value: selected.contains(habit),
                  onChanged: (val) {
                    if (val == true && selected.length < count) {
                      setStateDialog(() => selected.add(habit));
                    } else if (val == false) {
                      setStateDialog(() => selected.remove(habit));
                    }
                  },
                  title: Text('${_habitEmojis[habit] ?? ''} $habit', style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.2,
                  )),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.tealAccent,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: selected.length == count
                    ? () => Navigator.of(context).pop()
                    : null,
                child: const Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {
      _selectedHabits = selected;
      tracker = HabitTracker(
        habits: selected.map((name) => Habit(id: name, name: name, history: [])).toList(),
      );
      // Set the start date when tracker is first created
      tracker!.startDate = DateTime.now();
      _onboarding = false;
      // Save initial data to Firebase
      _saveData();
      // Trigger animation after onboarding is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward(from: 0.0);
      });
    });
  }

  void _toggleHabit(int index, bool? value) {
    if (tracker == null) return;
    final habit = tracker!.habits[index];
    final todayEntry = habit.history.indexWhere((h) => HabitTracker.isSameDay(h.date, _simulatedToday));
    setState(() {
      if (todayEntry >= 0) {
        habit.history[todayEntry] = HabitDay(date: _simulatedToday, completed: value ?? false);
      } else {
        habit.history.add(HabitDay(date: _simulatedToday, completed: value ?? false));
      }
    });
    _saveData();
  }

  void _addHabit() {
    if (tracker == null) return;
    // Only allow adding from pre-made habits not already selected
    final available = _preMadeHabits.where((h) => !tracker!.habits.any((habit) => habit.name == h)).toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Add Habit', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a new habit to add:', style: TextStyle(color: Colors.white70)),
            ...available.map((habit) => ListTile(
              title: Text('${_habitEmojis[habit] ?? ''} $habit', style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  tracker!.habits.add(Habit(id: habit, name: habit, history: []));
                });
                Navigator.of(context).pop();
              },
            )),
            if (available.isEmpty)
              const Text('No more habits to add.', style: TextStyle(color: Colors.white54)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  void _nextDay() async {
    if (tracker == null) return;
    bool mustRemove = false;
    bool prevCanAdd = tracker!.canAddHabit();
    int previousStreak = tracker!.streak;
    setState(() {
      mustRemove = tracker!.updateStreak(_simulatedToday);
      _simulatedToday = _simulatedToday.add(const Duration(days: 1));
    });

    // Wait for the open-up transition to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    if (previousStreak != tracker!.streak) {
      setState(() {
        _isShowingStreakNotification = true;
      });
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StreakNotification(
          isStreakIncreased: tracker!.streak > previousStreak,
          onDismiss: () {
            setState(() {
              _isShowingStreakNotification = false;
            });
            Navigator.of(context).pop();
          },
        ),
      );
    }

    // After setState, check if canAddHabit changed from false to true
    if (!prevCanAdd && tracker!.canAddHabit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Congratulations! You earned a new habit slot. You can now add a new habit.'),
          backgroundColor: Colors.tealAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
    if (mustRemove) {
      await _showForceRemoveHabitDialog();
    }
  }

  Future<void> _showForceRemoveHabitDialog() async {
    if (tracker == null || tracker!.habits.length <= 2) return;
    String? toRemove = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? selected;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('Remove a Habit', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You broke your streak 3 times before reaching 14. Please choose a habit to remove:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ...tracker!.habits.map((habit) => RadioListTile<String>(
                  value: habit.id,
                  groupValue: selected,
                  onChanged: (val) => setStateDialog(() => selected = val),
                  title: Text(habit.name, style: const TextStyle(color: Colors.white)),
                  activeColor: Colors.redAccent,
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: selected != null
                    ? () => Navigator.of(context).pop(selected)
                    : null,
                child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
    if (toRemove != null) {
      setState(() {
        tracker!.habits.removeWhere((h) => h.id == toRemove);
      });
    }
  }

  void _reset() {
    setState(() {
      tracker?.reset();
      _simulatedToday = DateTime.now();
      _onboarding = true;
      _initialHabitCount = null;
      _selectedHabits = [];
      _prevCanAddHabit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
    });
  }

  void _handleDevModeTap() {
    _devModeTapCount++;
    if (_devModeTapCount >= 7) {
      setState(() {
        _devMode = true;
        _devModeTapCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 Developer Mode Activated! You can now access testing features.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // Reset tap count after 3 seconds of inactivity
    Future.delayed(const Duration(seconds: 3), () {
      if (_devModeTapCount < 7) {
        _devModeTapCount = 0;
      }
    });
  }

  void _toggleDevMode() {
    setState(() {
      _devMode = !_devMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_devMode 
          ? '🔧 Developer Mode Enabled' 
          : '👤 Developer Mode Disabled'),
        backgroundColor: _devMode ? Colors.orange : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      setState(() {
        // Refresh the UI to show save progress button again
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSaveProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: AuthScreen(
            onAuthSuccess: _onAuthSuccess,
            showCloseButton: true,
            defaultToSignUp: true, // Default to sign-up for new users saving progress
          ),
        ),
      ),
    );
  }

  void _showExistingUserLogin() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: AuthScreen(
            onAuthSuccess: _onExistingUserAuthSuccess,
            showCloseButton: true,
            defaultToSignUp: false, // Default to sign-in for existing users
          ),
        ),
      ),
    );
  }

  Future<void> _onAuthSuccess() async {
    Navigator.of(context).pop(); // Close the dialog
    
    // Show loading while syncing local data to Firebase
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF181A20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.tealAccent),
            SizedBox(height: 16),
            Text(
              'Syncing your progress...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Save current local data to Firebase
      if (tracker != null) {
        await _firestoreService.saveHabitTracker(tracker!);
      }
      
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Progress saved! Your data is now backed up to the cloud.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      setState(() {
        // Refresh the UI to show sign out button
      });
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync progress: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onExistingUserAuthSuccess() async {
    Navigator.of(context).pop(); // Close the dialog
    
    // Show loading while loading user's saved data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF181A20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.tealAccent),
            SizedBox(height: 16),
            Text(
              'Loading your saved progress...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Load user's saved data from Firebase
      final loadedTracker = await _firestoreService.getHabitTracker();
      
      Navigator.of(context).pop(); // Close loading dialog
      
      if (loadedTracker != null) {
        setState(() {
          tracker = loadedTracker;
          _onboarding = false;
        });
        _animationController.forward();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Welcome back! Your progress has been loaded.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // No saved data found, start onboarding
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No saved progress found. Let\'s start fresh!'),
            backgroundColor: Colors.orange,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
      }
      
      setState(() {
        // Refresh the UI to show sign out button
      });
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load progress: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Fallback to onboarding
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData || (_onboarding && tracker == null)) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A20),
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }
    
    return Scaffold(
      body: _currentIndex == 0 ? _buildHabitsScreen(context) : StatsScreen(tracker: tracker!),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsScreen(BuildContext context) {
    final today = _simulatedToday;
    _checkAndAnimateNewDay();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleDevModeTap,
          child: const Text('Habit Tracker', style: TextStyle(color: Colors.white)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        actions: [
          if (_devMode) ...[
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.redAccent),
              tooltip: 'Reset (Dev Mode)',
              onPressed: _reset,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.tealAccent),
              tooltip: 'Next Day (Dev Mode)',
              onPressed: _nextDay,
            ),
            IconButton(
              icon: const Icon(Icons.developer_mode, color: Colors.orange),
              tooltip: 'Dev Mode Active',
              onPressed: _toggleDevMode,
            ),
          ],
          // Show sign up button if not authenticated, sign out if authenticated
          if (_authService.currentUser == null)
            IconButton(
              icon: const Icon(Icons.cloud_upload, color: Colors.tealAccent),
              tooltip: 'Save Progress',
              onPressed: _showSaveProgressDialog,
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: 'Sign Out',
              onPressed: _signOut,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80), // Add space for the app bar
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - Curves.easeOutCubic.transform(_animationController.value))),
                    child: Opacity(
                      opacity: Curves.easeOutCubic.transform(_animationController.value),
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[900]?.withOpacity(0.5),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 8),
                                Text(
                                  '${tracker!.streak}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  opacity: tracker!.hasCompletedEnoughForStreak(today) ? 1.0 : 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '+1',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.7),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Streak',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Row(
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 2),
                              Text(
                                '${tracker!.points}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Points',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final delayedValue = Curves.easeOutCubic.transform(
                    (_animationController.value - 0.2).clamp(0.0, 1.0) / 0.8
                  );
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - delayedValue)),
                    child: Opacity(
                      opacity: delayedValue,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Date: ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delayedValue = Curves.easeOutCubic.transform(
                      (_animationController.value - 0.4).clamp(0.0, 1.0) / 0.6
                    );
                    return Transform.translate(
                      offset: Offset(0, 40 * (1 - delayedValue)),
                      child: Opacity(
                        opacity: delayedValue,
                        child: child,
                      ),
                    );
                  },
                  child: ListView.builder(
                    itemCount: tracker!.habits.length,
                    itemBuilder: (context, index) {
                      final habit = tracker!.habits[index];
                      final todayEntry = habit.history.firstWhere(
                        (h) => HabitTracker.isSameDay(h.date, today),
                        orElse: () => HabitDay(date: today, completed: false),
                      );
                      final last5Days = List.generate(5, (i) => today.subtract(Duration(days: 4 - i))).reversed.toList();
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: todayEntry.completed,
                            onChanged: (value) => _toggleHabit(index, value),
                            activeColor: Colors.tealAccent,
                            checkColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  '${_habitEmojis[habit.name] ?? ''} ${habit.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '🔥${habit.streak}  •  ⭐${habit.points}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    for (final d in last5Days)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                        child: _buildDayStatusDot(habit, d),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final delayedValue = Curves.easeOutCubic.transform(
            (_animationController.value - 0.6).clamp(0.0, 1.0) / 0.4
          );
          return Transform.translate(
            offset: Offset(0, 40 * (1 - delayedValue)),
            child: Opacity(
              opacity: delayedValue,
              child: child,
            ),
          );
        },
        child: FloatingActionButton(
          onPressed: tracker!.canAddHabit() ? _addHabit : null,
          backgroundColor: tracker!.canAddHabit() ? Colors.tealAccent : Colors.grey[800],
          child: const Icon(Icons.add, color: Colors.black),
          tooltip: tracker!.canAddHabit()
              ? 'Add Habit'
              : 'Unlocks at streak multiples of 14',
        ),
      ),
    );
  }

  Widget _buildDayStatusDot(Habit habit, DateTime day) {
    final entries = habit.history.where((h) => HabitTracker.isSameDay(h.date, day));
    // All icons same size
    const double iconSize = 13;
    if (entries.isEmpty || !entries.first.completed) {
      return Icon(
        Icons.radio_button_unchecked,
        color: Colors.grey,
        size: iconSize,
      );
    }
    // Only show check if completed
    return Icon(
      Icons.check_circle,
      color: Colors.tealAccent,
      size: iconSize,
    );
  }
}
