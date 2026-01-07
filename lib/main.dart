import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/note_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/reflection_provider.dart';
import 'providers/quote_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'services/sample_data_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service
  await NotificationService().initialize();
  runApp(const XPlannerApp());
}

class XPlannerApp extends StatelessWidget {
  const XPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ReflectionProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: const XPlannerAppWithTheme(),
    );
  }
}

class XPlannerAppWithTheme extends StatefulWidget {
  const XPlannerAppWithTheme({super.key});

  @override
  State<XPlannerAppWithTheme> createState() => _XPlannerAppWithThemeState();
}

class _XPlannerAppWithThemeState extends State<XPlannerAppWithTheme> {
  @override
  void initState() {
    super.initState();
    // Defer sample data population until after the first frame and providers have loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait a bit longer to ensure providers have finished loading their data
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await SampleDataService.populateData(context);
        // Initialize rotating quote (picked once per app start / refresh)
        await Provider.of<QuoteProvider>(context, listen: false).initQuote();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XPlanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
