// lib/presentation/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  bool _animationCompleted = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    // Trigger auth check immediately after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckStatus());
      }
    });
  }

  void _initAnimation() {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _animationCompleted = true;
          });
          // Check current auth state when animation completes
          _tryNavigateWithCurrentState();
        }
      }
    });

    _progressController.forward();
  }

  void _tryNavigateWithCurrentState() {
    if (!mounted) return;
    final currentState = context.read<AuthBloc>().state;
    _handleNavigation(currentState);
  }

  void _handleNavigation(AuthState state) {
    // Only navigate when animation is completed
    if (!_animationCompleted) return;

    // Skip initial state
    if (state is AuthInitial) return;

    // Prevent multiple navigation calls
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    if (state is AuthAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (state is AuthUnauthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _handleNavigation(state);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo/Character
                  Image.asset(
                    'assets/icons/body.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),

                  // English Text
                  const TextCustom(
                    text: 'ALWAYS AT YOUR SERVICE',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                    letterSpacing: 1.2,
                  ),
                  const SizedBox(height: 12),

                  // Arabic Text
                  const TextCustom(
                    text: 'دائماً في الخدمة',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Progress Indicator
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            color: Colors.black,
                            backgroundColor: const Color(0xFFE0E0E0),
                            minHeight: 5,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
