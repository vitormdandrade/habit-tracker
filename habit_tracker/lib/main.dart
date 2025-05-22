import 'package:flutter/material.dart';
import 'habit_model.dart';

void main() {
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
          background: Color(0xFF181A20),
          surface: Color(0xFF23262F),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF23262F),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
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

class _HabitHomePageState extends State<HabitHomePage> {
  HabitTracker? tracker;
  DateTime _simulatedToday = DateTime.now();
  bool _onboarding = true;
  int? _initialHabitCount;
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
  List<String> _selectedHabits = [];

  @override
  void initState() {
    super.initState();
    // Start onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
  }

  void _showInitialHabitCountDialog() async {
    int? count = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('How many habits to start?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose how many habits you want to start with (1-3):', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 3; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('Select your habits', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pick $count habits to start with:', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ..._preMadeHabits.map((habit) => CheckboxListTile(
                  value: selected.contains(habit),
                  onChanged: (val) {
                    if (val == true && selected.length < count) {
                      setStateDialog(() => selected.add(habit));
                    } else if (val == false) {
                      setStateDialog(() => selected.remove(habit));
                    }
                  },
                  title: Text(habit, style: const TextStyle(color: Colors.white)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.tealAccent,
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: selected.length == count
                    ? () => Navigator.of(context).pop()
                    : null,
                child: const Text('Start', style: TextStyle(color: Colors.tealAccent)),
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
      _onboarding = false;
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
              title: Text(habit, style: const TextStyle(color: Colors.white)),
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

  void _nextDay() {
    if (tracker == null) return;
    setState(() {
      tracker!.updateStreak(_simulatedToday);
      _simulatedToday = _simulatedToday.add(const Duration(days: 1));
    });
  }

  void _reset() {
    setState(() {
      tracker?.reset();
      _simulatedToday = DateTime.now();
      _onboarding = true;
      _initialHabitCount = null;
      _selectedHabits = [];
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialHabitCountDialog());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboarding || tracker == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A20),
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }
    final today = _simulatedToday;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.tealAccent),
            tooltip: 'Next Day',
            onPressed: _nextDay,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 4),
                          Text(
                            '${tracker!.streak}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Streak',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 4),
                          Text(
                            '${tracker!.points}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Points',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text('Date: \\${today.year}-\\${today.month.toString().padLeft(2, '0')}-\\${today.day.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: tracker!.habits.length,
                itemBuilder: (context, index) {
                  final habit = tracker!.habits[index];
                  final todayEntry = habit.history.firstWhere(
                    (h) => HabitTracker.isSameDay(h.date, today),
                    orElse: () => HabitDay(date: today, completed: false),
                  );
                  // Show last 5 days (including today), newest to oldest (today on the left)
                  final last5Days = List.generate(5, (i) => today.subtract(Duration(days: 4 - i))).reversed.toList();
                  return Card(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: todayEntry.completed,
                        onChanged: (value) => _toggleHabit(index, value),
                        activeColor: Colors.tealAccent,
                        checkColor: Colors.black,
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(habit.name, style: const TextStyle(color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🔥${habit.streak}  •  ⭐${habit.points}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: tracker!.canAddHabit() ? _addHabit : null,
        backgroundColor: tracker!.canAddHabit() ? Colors.tealAccent : Colors.grey[800],
        child: const Icon(Icons.add, color: Colors.black),
        tooltip: tracker!.canAddHabit()
            ? 'Add Habit'
            : 'Unlocks at streak multiples of 14',
      ),
    );
  }

  Widget _buildDayStatusDot(Habit habit, DateTime day) {
    final entries = habit.history.where((h) => HabitTracker.isSameDay(h.date, day));
    // All icons same size
    const double iconSize = 18;
    if (entries.isEmpty) {
      return Icon(
        Icons.radio_button_unchecked,
        color: Colors.grey,
        size: iconSize,
      );
    }
    final entry = entries.first;
    return Icon(
      entry.completed ? Icons.check_circle : Icons.cancel,
      color: entry.completed ? Colors.tealAccent : Colors.redAccent,
      size: iconSize,
    );
  }
}
