import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/risk_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/journal_editor_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/doctor_screen.dart';
import 'providers/insights_provider.dart';
import 'screens/routine_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/quiz_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/badge_provider.dart';
import 'screens/stories_screen.dart';
import 'screens/badge_screen.dart';
import 'screens/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => RiskProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
      ],
      child: const MentalHealthApp(),
    ),
  );
}

class MentalHealthApp extends StatelessWidget {
  const MentalHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MonBondhu',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.tealAccent,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/journal': (context) => const JournalScreen(),
        '/journal_editor': (context) => const JournalEditorScreen(),
        '/mood': (context) => const MoodScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/doctor': (context) => const DoctorScreen(),
        '/routine': (context) => const RoutineScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/exercise': (context) => const ExerciseScreen(),
        '/learning': (context) => const LearningScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/badges': (context) => const BadgeScreen(),
        '/profile': (context) => const ProfileScreen(),

      },
    );
  }
}
