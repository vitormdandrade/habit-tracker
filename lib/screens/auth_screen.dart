import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;
  final bool showCloseButton;
  final bool defaultToSignUp;
  
  const AuthScreen({
    super.key,
    this.onAuthSuccess,
    this.showCloseButton = false,
    this.defaultToSignUp = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late bool _isLogin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial state based on defaultToSignUp parameter
    _isLogin = !widget.defaultToSignUp; // If defaultToSignUp is true, start with sign-up (false)
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        final userCredential = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (userCredential != null) {
          // Create user document in Firestore
          await _firestoreService.createUserDocument(
            userCredential.user!.uid,
            _emailController.text.trim(),
          );
        }
      }
      
      // Call success callback if provided (for dialog mode)
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        // Create user document if it's a new user
        await _firestoreService.createUserDocument(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
        );
        
        // Call success callback if provided (for dialog mode)
        if (widget.onAuthSuccess != null) {
          widget.onAuthSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
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
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Close button if shown as dialog
                  if (widget.showCloseButton)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  // Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]?.withOpacity(0.8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      size: 48,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Habit Tracker',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.showCloseButton 
                        ? 'Sign in to backup your progress'
                        : (_isLogin ? 'Welcome back!' : 'Start your journey'),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (!_isLogin && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              _isLogin ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle login/register
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Forgot password
                  if (_isLogin)
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.tealAccent.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.showCloseButton) {
      // Return content with dialog styling
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111217),
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      );
    }

    return Scaffold(body: content);
  }
} 