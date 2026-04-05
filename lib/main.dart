import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/member/member_bloc.dart';
import 'bloc/sync/sync_bloc.dart';
import 'bloc/admin/admin_bloc.dart';
import 'bloc/audit/audit_bloc.dart';
import 'bloc/women/women_member_bloc.dart';
import 'bloc/women/women_sync_bloc.dart';
import 'core/constants.dart';
import 'core/notification_service.dart';
import 'core/theme_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.init();
  } catch (e) {
    debugPrint('Init error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) => context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final ThemeProvider themeProvider = ThemeProvider();

  void toggleTheme() {
    setState(() => themeProvider.toggle());
  }

  bool get isDark => themeProvider.isDark;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => MemberBloc()),
        BlocProvider(create: (_) => SyncBloc()),
        BlocProvider(create: (_) => AdminBloc()),
        BlocProvider(create: (_) => AuditBloc()),
        BlocProvider(create: (_) => WomenMemberBloc()),
        BlocProvider(create: (_) => WomenSyncBloc()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeProvider.lightTheme,
        darkTheme: ThemeProvider.darkTheme,
        themeMode: themeProvider.mode,
        home: const SplashScreen(),
      ),
    );
  }
}
