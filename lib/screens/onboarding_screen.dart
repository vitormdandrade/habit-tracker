import 'package:flutter/material.dart';
import '../habit_model.dart';
import 'auth_screen.dart';

class ExplanationPhrase {
  final String text;
  final List<String> highlightWords;
  final Color highlightColor;
  final String? imagePath; // Optional image to display below the phrase

  const ExplanationPhrase({
    required this.text,
    required this.highlightWords,
    required this.highlightColor,
    this.imagePath,
  });
}

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
  
  // Single typing controller for sequential phrases
  late AnimationController _typingController;
  
  // Image fade controller
  late AnimationController _imageFadeController;
  late Animation<double> _imageFadeAnimation;
  
  // Explanation phrases - easily editable
  final List<ExplanationPhrase> _explanationPhrases = [
    ExplanationPhrase(
      text: "Here's how it works:",
      highlightWords: ['how', 'works'],
      highlightColor: Colors.tealAccent,
    ),
    ExplanationPhrase(
      text: "Building streaks is about consistency, not perfection.",
      highlightWords: ['consistency', 'perfection'],
      highlightColor: Colors.tealAccent,
      imagePath: 'assets/consistency_illustration.png', // Example image
    ),
    ExplanationPhrase(
      text: "You can miss one habit per day, but try not to miss the same habit two days in a row.",
      highlightWords: ['one habit', 'same habit', 'two days'],
      highlightColor: Colors.tealAccent,
    ),
    ExplanationPhrase(
      text: "Every 14 days of your streak, you unlock the ability to add a new habit.",
      highlightWords: ['14 days', 'unlock', 'new habit'],
      highlightColor: Colors.tealAccent,
      imagePath: 'assets/unlock_illustration.png', // Example image
    ),
    ExplanationPhrase(
      text: "This keeps things manageable and sustainable.",
      highlightWords: ['manageable', 'sustainable'],
      highlightColor: Colors.tealAccent,
    ),
    ExplanationPhrase(
      text: "Remember: streaks can be lost, but points are yours forever.",
      highlightWords: ['points', 'forever'],
      highlightColor: Colors.orangeAccent,
    ),
    ExplanationPhrase(
      text: "Every habit completed counts, even when life gets in the way.",
      highlightWords: ['counts', 'life gets in the way'],
      highlightColor: Colors.orangeAccent,
      imagePath: 'assets/life_illustration.png', // Example image
    ),
  ];
  
  int _currentPhraseIndex = 0;
  bool _showingNextButton = false;
  
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
    
    // Single typing controller
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Image fade controller
    _imageFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageFadeAnimation = CurvedAnimation(
      parent: _imageFadeController,
      curve: Curves.easeInOut,
    );
    
    _fadeController.forward();
    
    // Start typing animation for the first page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTypingAnimation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _typingController.dispose();
    _imageFadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
        _currentPhraseIndex = 0;
        _showingNextButton = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Start typing animation for the new page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTypingAnimation();
      });
    } else {
      _completeOnboarding();
    }
  }

  void _startTypingAnimation() {
    if (_currentPage == 1) {
      // For explanation screen, start with first phrase
      _currentPhraseIndex = 0;
      _showingNextButton = false;
      _imageFadeController.reset();
      _startNextPhrase();
    } else {
      // For other screens, just start typing
      _typingController.reset();
      _typingController.forward();
    }
  }

  void _startNextPhrase() {
    if (_currentPhraseIndex < _explanationPhrases.length) {
      _typingController.reset();
      _imageFadeController.reset();
      
      _typingController.forward().then((_) {
        // Wait a bit after typing completes, then fade in image if present
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _explanationPhrases[_currentPhraseIndex].imagePath != null) {
            _imageFadeController.forward();
          }
          
          // Show next button after a delay
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _showingNextButton = true;
              });
            }
          });
        });
      });
    }
  }

  void _nextPhrase() {
    if (_currentPhraseIndex < _explanationPhrases.length - 1) {
      setState(() {
        _currentPhraseIndex++;
        _showingNextButton = false;
      });
      _imageFadeController.reset();
      _startNextPhrase();
    } else {
      // All phrases shown, move to next page
      _nextPage();
    }
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
              _buildExplanationScreen(),
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
                  color: Colors.tealAccent.withOpacity(0.2),
                ),
                child: Image.asset(
                  'logo/gradually_logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Gradually',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Aleo',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          _buildTypingText(
            text: "Hey there! 👋",
            controller: _typingController,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Aleo',
              height: 1.4,
            ),
            highlightWords: ['Hey', 'there'],
          ),
          
          const SizedBox(height: 24),
          
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController.value > 0.5 ? 1.0 : 0.0,
                child: _buildTypingText(
                  text: "Ready to build some amazing habits?",
                  controller: _typingController,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Aleo',
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                  highlightWords: ['amazing', 'habits'],
                ),
              );
            },
          ),
          
          const Spacer(),
          
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController.value > 0.8 ? 1.0 : 0.0,
                child: Column(
                  children: [
                    SizedBox(
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
                            fontFamily: 'Aleo',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(
                              onAuthSuccess: () {
                                // Close the auth screen and return to main app
                                Navigator.of(context).pop();
                                // The main app will detect the auth state change
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Already registered? Log in',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Aleo',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildExplanationScreen() {
    final currentPhrase = _explanationPhrases[_currentPhraseIndex];
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const Spacer(),
          
          // Display current phrase with typing animation
          _buildTypingText(
            text: currentPhrase.text,
            controller: _typingController,
            style: TextStyle(
              fontSize: _currentPhraseIndex == 0 ? 28 : 22, // Increased font sizes
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Aleo',
              height: 1.4,
            ),
            highlightWords: currentPhrase.highlightWords,
            highlightColor: currentPhrase.highlightColor,
          ),
          
          // Display image if present
          if (currentPhrase.imagePath != null) ...[
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _imageFadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _imageFadeAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        currentPhrase.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image doesn't exist
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          
          const Spacer(),
          
          // Progress indicator
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_explanationPhrases.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentPhraseIndex 
                        ? Colors.tealAccent 
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Next button (only shown when phrase is complete)
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return Opacity(
                opacity: _showingNextButton ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showingNextButton ? _nextPhrase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPhraseIndex < _explanationPhrases.length - 1 
                          ? 'Next' 
                          : 'Got it!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Aleo',
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
            controller: _typingController,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Aleo',
              height: 1.4,
            ),
            highlightWords: ['call', 'you'],
          ),
          
          const SizedBox(height: 24),
          
          _buildTypingText(
            text: "I'd love to make this personal 😊",
            controller: _typingController,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Aleo',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            highlightWords: ['personal'],
          ),
          
          const SizedBox(height: 40),
          
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return Opacity(
                opacity: _typingController.value > 0.5 ? 1.0 : 0.0,
                child: TextField(
                  onChanged: (value) => setState(() => _userName = value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Aleo',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name here...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Aleo',
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
                  fontFamily: 'Aleo',
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
            controller: _typingController,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Aleo',
              height: 1.4,
            ),
            highlightWords: [_userName.trim(), '1-3', 'habits'],
          ),
          
          const SizedBox(height: 24),
          
          _buildTypingText(
            text: "Remember, you can add more every 14 days!",
            controller: _typingController,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Aleo',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            highlightWords: ['add more', '14 days'],
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return Opacity(
                  opacity: _typingController.value > 0.3 ? 1.0 : 0.0,
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
                                      fontFamily: 'Aleo',
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
                fontFamily: 'Aleo',
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
                  fontFamily: 'Aleo',
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