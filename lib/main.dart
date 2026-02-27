import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/home/home_bloc.dart';
import 'package:superdriver/domain/bloc/locale/locale_bloc.dart';
import 'package:superdriver/domain/bloc/notification/notification_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/bloc/review/review_bloc.dart';
import 'package:superdriver/domain/services/push_notification_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/screens/auth/splash_screen.dart';
import 'package:superdriver/presentation/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
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
        BlocProvider(create: (_) => CartBloc()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          pushNotificationService.registerDeviceToken();
          context.read<NotificationBloc>().add(
            const UnreadCountLoadRequested(),
          );
        } else if (state is AuthUnauthenticated) {
          pushNotificationService.unregisterDeviceToken();
        }
      },
      child: BlocListener<LocaleBloc, LocaleState>(
        listenWhen: (prev, curr) => prev.locale != curr.locale,
        listener: (context, state) {
          // Re-register device token with new language
          // so backend sends push notifications in the correct language
          pushNotificationService.registerDeviceToken();
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
              navigatorKey: PushNotificationService.navigatorKey,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const _AppRoot(),
            );
          },
        ),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();

    // Only need this for badge count — navigation is handled
    // directly inside push_notification_service.dart
    pushNotificationService.onForegroundMessage = () {
      if (mounted) {
        context.read<NotificationBloc>().add(const NotificationReceived());
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
