// lib/presentation/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/main_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

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
    if (!_animationCompleted) return;
    if (state is AuthInitial) return;
    if (_isNavigating || !mounted) return;

    // Both authenticated and unauthenticated → go to MainScreen
    // Guests can browse; auth-required features are guarded in MainScreen
    if (state is AuthAuthenticated || state is AuthUnauthenticated) {
      _isNavigating = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
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
        backgroundColor: ColorsCustom.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo/Character
                  Image.asset(
                    'assets/icons/splash_tagline.png',
                    width: 600,
                    height: 600,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // English Text
                  const TextCustom(
                    text: 'ALWAYS AT YOUR SERVICE',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ColorsCustom.textPrimary,
                    textAlign: TextAlign.center,
                    letterSpacing: 1.2,
                  ),
                  const SizedBox(height: 8),

                  // Arabic Text
                  const TextCustom(
                    text: 'دائماً في الخدمة',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ColorsCustom.textPrimary,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              color: ColorsCustom.primary,
                              backgroundColor: ColorsCustom.border,
                              minHeight: 5,
                            ),
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
