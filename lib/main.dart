import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/locale/locale_bloc.dart';
import 'package:superdriver/domain/bloc/chat/chat_unread_cubit.dart';
import 'package:superdriver/domain/bloc/notification/notification_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/bloc/review/review_bloc.dart';
import 'package:superdriver/data/services/in_app_messaging_service.dart';
import 'package:superdriver/data/services/chat_service.dart';
import 'package:superdriver/data/services/push_notification_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/screens/auth/splash_screen.dart';
import 'package:superdriver/presentation/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);

  await Firebase.initializeApp();
  await inAppMessagingService.initialize();
  await pushNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create: (_) => LocaleBloc()..add(const LocaleLoadRequested()),
        ),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => OrdersBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ReviewBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => ChatUnreadCubit()),
        BlocProvider(create: (_) => CartBloc()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Badge count callbacks — navigation is handled
    // directly inside push_notification_service.dart
    pushNotificationService.onForegroundMessage = () {
      if (!mounted) return;
      if (context.read<AuthBloc>().state is! AuthAuthenticated) return;
      context.read<NotificationBloc>().add(const NotificationReceived());
    };

    pushNotificationService.onNotificationTap = (_) {
      if (!mounted) return;
      if (context.read<AuthBloc>().state is AuthAuthenticated) {
        context.read<NotificationBloc>().add(const UnreadCountLoadRequested());
      }
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!mounted) return;
      if (context.read<AuthBloc>().state is AuthAuthenticated) {
        context.read<NotificationBloc>().add(
          const UnreadCountLoadRequested(),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pushNotificationService.onForegroundMessage = null;
    pushNotificationService.onNotificationTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          inAppMessagingService.onUserSignedIn();
          pushNotificationService.registerDeviceToken();
          context.read<NotificationBloc>().add(
            const UnreadCountLoadRequested(),
          );
          context.read<ChatUnreadCubit>().startListening(state.user.id);
          context.read<HomeBloc>().add(const HomeUserLoggedIn());
        } else if (state is AuthUnauthenticated) {
          inAppMessagingService.onUserSignedOut();
          pushNotificationService.unregisterDeviceToken();
          context.read<NotificationBloc>().add(
            const NotificationResetRequested(),
          );
          context.read<ChatUnreadCubit>().reset();
          context.read<HomeBloc>().add(const HomeUserLoggedOut());
        }
      },
      child: BlocListener<LocaleBloc, LocaleState>(
        listenWhen: (prev, curr) => prev.locale != curr.locale,
        listener: (context, state) {
          // Re-register token only when user is authenticated.
          if (context.read<AuthBloc>().state is AuthAuthenticated) {
            pushNotificationService.registerDeviceToken();
            _updateChatTokenLocale(context, state.locale.languageCode);
          }
        },
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            // Sync locale with push notification service
            pushNotificationService.updateLocale(
              localeState.locale.languageCode,
            );
            return MaterialApp(
              title: 'SUPERDRIVER',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: localeState.locale,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              navigatorKey: PushNotificationService.navigatorKey,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}

void _updateChatTokenLocale(BuildContext context, String locale) {
  final authState = context.read<AuthBloc>().state;
  if (authState is! AuthAuthenticated) return;
  pushNotificationService.getFcmToken().then((token) {
    if (token == null) return;
    chatService.updateFcmTokenLocale(
      userId: authState.user.id,
      token: token,
      locale: locale,
    );
  });
}
