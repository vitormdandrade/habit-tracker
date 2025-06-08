import 'package:flutter/material.dart';
import '../habit_model.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(HabitTracker, String) onOnboardingComplete;

  const OnboardingScreen({
    Key? key,
    required this.onOnboardingComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  String _userName = '';
  final List<String> _selectedHabits = [];
  
  // Typing animation controllers
  late AnimationController _typingController1;
  late AnimationController _typingController2;
  late AnimationController _typingController3;
  
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Initialize typing controllers
    _typingController1 = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingController2 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _typingController3 = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _fadeController.forward();
    
    // Start typing animations for the first page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTypingAnimationsForPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _typingController1.dispose();
    _typingController2.dispose();
    _typingController3.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Start typing animations for the new page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTypingAnimationsForPage(_currentPage);
      });
    } else {
      _completeOnboarding();
    }
  }

  void _startTypingAnimationsForPage(int page) {
    _typingController1.reset();
    _typingController2.reset();
    _typingController3.reset();
    
    _typingController1.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _typingController2.forward();
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _typingController3.forward();
    });
  }

  void _completeOnboarding() {
    final tracker = HabitTracker(
      habits: _selectedHabits.map((name) => Habit(id: name, name: name, history: [])).toList(),
    );
    tracker.startDate = DateTime.now();
    widget.onOnboardingComplete(tracker, _userName);
  }

  Widget _buildStyledEmoji(String emoji, {double fontSize = 16}) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0.96,
        0.2126, 0.7152, 0.0722, 0, 0.96,
        0.2126, 0.7152, 0.0722, 0, 0.96,
        0,      0,      0,      1, 0,
      ]),
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildTypingText({
    required String text,
    required AnimationController controller,
    required TextStyle style,
    List<String> highlightWords = const [],
    Color highlightColor = Colors.tealAccent,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final displayLength = (text.length * controller.value).round();
        final displayText = text.substring(0, displayLength);
        
        if (highlightWords.isEmpty) {
          return Text(
            displayText,
            style: style,
            textAlign: TextAlign.left,
          );
        }
        
        List<TextSpan> spans = [];
        List<String> words = displayText.split(' ');
        
        for (int i = 0; i < words.length; i++) {
          final word = words[i];
          final isHighlighted = highlightWords.any((highlight) => 
            word.toLowerCase().contains(highlight.toLowerCase()));
          
          spans.add(TextSpan(
            text: word,
            style: style.copyWith(
              color: isHighlighted ? highlightColor : style.color,
              fontWeight: isHighlighted ? FontWeight.w600 : style.fontWeight,
            ),
          ));
          
          if (i < words.length - 1) {
            spans.add(TextSpan(text: ' ', style: style));
          }
        }
        
        return RichText(
          textAlign: TextAlign.left,
          text: TextSpan(children: spans),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black87,
              BlendMode.darken,
            ),
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildWelcomeScreen(),
              _buildStreakExplanationScreen(),
              _buildNameScreen(),
              _buildHabitSelectionScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.tealAccent.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.tealAccent.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.checklist_rtl,
                    size: 30,
                    color: Colors.tealAccent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          _buildTypingText(
            text: "Hey there! 👋",
            controller: _typingController1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
            highlightWords: ['Hey', 'there'],
          ),
          
          const SizedBox(height: 24),
          
          _buildTypingText(
            text: "Ready to build some amazing habits?",
            controller: _typingController2,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            highlightWords: ['amazing', 'habits'],
          ),
          
          const Spacer(),
          
          AnimatedBuilder(
            animation: _typingController3,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController3.value,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.tealAccent.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Let\'s do this!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStreakExplanationScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          
          _buildTypingText(
            text: "Here's how it works:",
            controller: _typingController1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
            highlightWords: ['how', 'works'],
          ),
          
          const SizedBox(height: 32),
          
          _buildTypingText(
            text: "Building streaks is about consistency, not perfection. You can miss one habit per day, but try not to miss the same habit two days in a row.",
            controller: _typingController2,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
            highlightWords: ['consistency', 'perfection', 'one habit', 'same habit', 'two days'],
          ),
          
          const SizedBox(height: 28),
          
          _buildTypingText(
            text: "Every 14 days of your streak, you unlock the ability to add a new habit. This keeps things manageable and sustainable.",
            controller: _typingController3,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
            highlightWords: ['14 days', 'unlock', 'new habit', 'manageable', 'sustainable'],
          ),
          
          const SizedBox(height: 28),
          
          AnimatedBuilder(
            animation: _typingController3,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController3.value > 0.7 ? 1.0 : 0.0,
                child: _buildTypingText(
                  text: "Remember: streaks can be lost, but points are yours forever. Every habit completed counts, even when life gets in the way.",
                  controller: _typingController3,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                  ),
                  highlightWords: ['points', 'forever', 'counts', 'life gets in the way'],
                  highlightColor: Colors.orangeAccent,
                ),
              );
            },
          ),
          
          const Spacer(),
          
          AnimatedBuilder(
            animation: _typingController3,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController3.value > 0.8 ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Makes sense!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }



  Widget _buildNameScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          
          _buildTypingText(
            text: "Great! What should I call you?",
            controller: _typingController1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
            highlightWords: ['call', 'you'],
          ),
          
          const SizedBox(height: 24),
          
          _buildTypingText(
            text: "I'd love to make this personal 😊",
            controller: _typingController2,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            highlightWords: ['personal'],
          ),
          
          const SizedBox(height: 40),
          
          AnimatedBuilder(
            animation: _typingController2,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController2.value > 0.5 ? 1.0 : 0.0,
                child: TextField(
                  onChanged: (value) => setState(() => _userName = value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name here...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Montserrat',
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.tealAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _userName.trim().isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _userName.trim().isNotEmpty 
                    ? Colors.tealAccent 
                    : Colors.grey[800],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _userName.trim().isNotEmpty ? 'Nice to meet you!' : 'Enter your name first',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHabitSelectionScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          
          _buildTypingText(
            text: "Perfect, ${_userName.trim().isNotEmpty ? _userName.trim() : 'friend'}! Now pick 1-3 habits to start with:",
            controller: _typingController1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
            highlightWords: [_userName.trim(), '1-3', 'habits'],
          ),
          
          const SizedBox(height: 24),
          
          _buildTypingText(
            text: "Remember, you can add more every 14 days!",
            controller: _typingController2,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            highlightWords: ['add more', '14 days'],
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _typingController2,
              builder: (context, child) {
                return Opacity(
                  opacity: _typingController2.value > 0.3 ? 1.0 : 0.0,
                  child: ListView.builder(
                    itemCount: _preMadeHabits.length,
                    itemBuilder: (context, index) {
                      final habit = _preMadeHabits[index];
                      final isSelected = _selectedHabits.contains(habit);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedHabits.remove(habit);
                              } else if (_selectedHabits.length < 3) {
                                _selectedHabits.add(habit);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.tealAccent.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.tealAccent 
                                    : Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildStyledEmoji(_habitEmojis[habit]!, fontSize: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    habit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.tealAccent : Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.tealAccent,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          Center(
            child: Text(
              '${_selectedHabits.length}/3 selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedHabits.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedHabits.isNotEmpty 
                    ? Colors.tealAccent 
                    : Colors.grey[800],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _selectedHabits.isNotEmpty 
                    ? "Let's build these habits!" 
                    : 'Pick at least one habit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} 