import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/presentation/screens/main/main_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

const _kBackgroundAsset = 'assets/icons/splash_screen_background.png';
const _kEnglishLine = _SloganConfig(
  prefix: 'ALWAYS AT YOUR ',
  highlight: 'SERVICE',
  textDirection: TextDirection.ltr,
  letterSpacing: 1.2,
);
const _kArabicLine = _SloganConfig(
  prefix: 'دائماً في ',
  highlight: 'الخدمة',
  textDirection: TextDirection.rtl,
  letterSpacing: 0,
);

const _kTotalDuration = Duration(milliseconds: 3400);
const _kContentDuration = Duration(milliseconds: 1800);
const _kPulseDuration = Duration(milliseconds: 900);
const _kContentDelay = Duration(milliseconds: 350);
const _kPulseDelay = Duration(milliseconds: 1400);

const _kProgressHeight = 5.0;
const _kProgressRadius = 6.0;
const _kPulseScaleEnd = 1.04;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _contentController;
  late final AnimationController _pulseController;

  late final Animation<double> _lineOpacity;
  late final Animation<Offset> _lineSlide;
  late final Animation<double> _highlightOpacity;
  late final Animation<double> _highlightScale;

  late final Animation<double> _progressOpacity;
  late final Animation<double> _pulseScale;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _scheduleDelayed(_kContentDelay, () => _contentController.forward());
    _scheduleDelayed(
      _kPulseDelay,
      () => _pulseController.repeat(reverse: true),
    );
    _requestAuthCheck();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initControllers() {
    _mainController =
        AnimationController(vsync: this, duration: _kTotalDuration)
          ..addStatusListener(_onMainControllerStatus)
          ..forward();

    _contentController = AnimationController(
      vsync: this,
      duration: _kContentDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: _kPulseDuration,
    );
  }

  void _initAnimations() {
    CurvedAnimation interval(double begin, double end, Curve curve) {
      return CurvedAnimation(
        parent: _contentController,
        curve: Interval(begin, end, curve: curve),
      );
    }

    final slideUpTween = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    );

    _lineOpacity = interval(0.00, 0.40, Curves.easeOut);
    _lineSlide = slideUpTween.animate(
      interval(0.00, 0.45, Curves.easeOutCubic),
    );
    _highlightOpacity = interval(0.20, 0.55, Curves.easeOut);
    _highlightScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(interval(0.20, 0.60, Curves.easeOutBack));

    _progressOpacity = interval(0.55, 0.80, Curves.easeOut);

    _pulseScale = Tween<double>(begin: 1.0, end: _kPulseScaleEnd).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _requestAuthCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthCheckStatus());
    });
  }

  void _onMainControllerStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _handleNavigation(context.read<AuthBloc>().state);
    }
  }

  void _handleNavigation(AuthState state) {
    if (_mainController.status != AnimationStatus.completed) return;
    if (state is AuthInitial || _isNavigating || !mounted) return;

    if (state is AuthAuthenticated || state is AuthUnauthenticated) {
      _isNavigating = true;
      Navigator.of(context).pushReplacement(_instantRoute(const MainScreen()));
    }
  }

  void _scheduleDelayed(Duration delay, VoidCallback fn) {
    Future.delayed(delay, () {
      if (mounted) fn();
    });
  }

  Route<T> _instantRoute<T>(Widget page) => PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated || current is AuthUnauthenticated,
      listener: (_, state) => _handleNavigation(state),
      child: Scaffold(
        backgroundColor: ColorsCustom.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = _SplashMetrics(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(_kBackgroundAsset, fit: BoxFit.cover),
                _BottomContent(
                  metrics: metrics,
                  lineOpacity: _lineOpacity,
                  lineSlide: _lineSlide,
                  highlightOpacity: _highlightOpacity,
                  highlightScale: _highlightScale,
                  progressOpacity: _progressOpacity,
                  pulseScale: _pulseScale,
                  mainController: _mainController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomContent extends StatelessWidget {
  const _BottomContent({
    required this.metrics,
    required this.lineOpacity,
    required this.lineSlide,
    required this.highlightOpacity,
    required this.highlightScale,
    required this.progressOpacity,
    required this.pulseScale,
    required this.mainController,
  });

  final _SplashMetrics metrics;
  final Animation<double> lineOpacity;
  final Animation<Offset> lineSlide;
  final Animation<double> highlightOpacity;
  final Animation<double> highlightScale;
  final Animation<double> progressOpacity;
  final Animation<double> pulseScale;
  final AnimationController mainController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: metrics.hPadding),
        child: Column(
          children: [
            const Spacer(),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.only(bottom: metrics.bottomPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SloganLine(
                      config: _kEnglishLine,
                      opacity: lineOpacity,
                      slide: lineSlide,
                      highlightOpacity: highlightOpacity,
                      highlightScale: highlightScale,
                      pulseScale: pulseScale,
                      fontSize: metrics.fontSize,
                    ),
                    SizedBox(height: metrics.spacingSmall),
                    _SloganLine(
                      config: _kArabicLine,
                      opacity: lineOpacity,
                      slide: lineSlide,
                      highlightOpacity: highlightOpacity,
                      highlightScale: highlightScale,
                      pulseScale: pulseScale,
                      fontSize: metrics.fontSize,
                    ),
                    SizedBox(height: metrics.spacingLarge),
                    _ProgressBar(
                      opacity: progressOpacity,
                      controller: mainController,
                      width: metrics.progressWidth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SloganConfig {
  final String prefix;
  final String highlight;
  final TextDirection textDirection;
  final double letterSpacing;

  const _SloganConfig({
    required this.prefix,
    required this.highlight,
    required this.textDirection,
    required this.letterSpacing,
  });
}

class _SloganLine extends StatelessWidget {
  const _SloganLine({
    required this.config,
    required this.opacity,
    required this.slide,
    required this.highlightOpacity,
    required this.highlightScale,
    required this.pulseScale,
    required this.fontSize,
  });

  final _SloganConfig config;
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> highlightOpacity;
  final Animation<double> highlightScale;
  final Animation<double> pulseScale;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: Directionality(
          textDirection: config.textDirection,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                config.prefix,
                style: _sloganStyle(
                  fontSize,
                  letterSpacing: config.letterSpacing,
                ),
              ),
              _HighlightWord(
                text: config.highlight,
                fontSize: fontSize,
                letterSpacing: config.letterSpacing,
                opacity: highlightOpacity,
                scale: highlightScale,
                pulseScale: pulseScale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightWord extends StatelessWidget {
  const _HighlightWord({
    required this.text,
    required this.fontSize,
    required this.letterSpacing,
    required this.opacity,
    required this.scale,
    required this.pulseScale,
  });

  final String text;
  final double fontSize;
  final double letterSpacing;
  final Animation<double> opacity;
  final Animation<double> scale;
  final Animation<double> pulseScale;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedBuilder(
          animation: pulseScale,
          builder: (_, child) =>
              Transform.scale(scale: pulseScale.value, child: child),
          child: Text(
            text,
            style: _sloganStyle(
              fontSize,
              color: ColorsCustom.primary,
              letterSpacing: letterSpacing,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.opacity,
    required this.controller,
    required this.width,
  });

  final Animation<double> opacity;
  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) => SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kProgressRadius),
              child: LinearProgressIndicator(
                value: controller.value,
                color: ColorsCustom.primary,
                backgroundColor: Colors.white.withAlpha(70),
                minHeight: _kProgressHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _sloganStyle(
  double fontSize, {
  Color color = Colors.black,
  double letterSpacing = 0,
}) => TextStyle(
  fontSize: fontSize,
  fontWeight: FontWeight.w800,
  color: color,
  letterSpacing: letterSpacing,
);

class _SplashMetrics {
  _SplashMetrics(double width, double height)
    : hPadding = (min(width, height) * 0.07).clamp(16.0, 48.0),
      fontSize = (min(width, height) * 0.055).clamp(16.0, 32.0),
      progressWidth = (min(width, height) * 0.56).clamp(160.0, 380.0),
      contentMaxWidth = (min(width, height) * 0.88).clamp(260.0, 620.0),
      spacingSmall = (max(width, height) * 0.008).clamp(4.0, 14.0),
      spacingLarge = (max(width, height) * 0.025).clamp(14.0, 36.0),
      bottomPadding = (max(width, height) * 0.03).clamp(16.0, 48.0);

  final double hPadding;
  final double fontSize;
  final double progressWidth;
  final double contentMaxWidth;
  final double spacingSmall;
  final double spacingLarge;
  final double bottomPadding;
}
