import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/help_support_screen.dart';
import 'screens/settings/notifications_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  await NotificationService.initialize();
  
  runApp(const PoultryFarmApp());
}

class PoultryFarmApp extends StatelessWidget {
  const PoultryFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Poultry Farm Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/help': (context) => const HelpSupportScreen(),
          '/about': (context) => const AboutScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/otp') {
            final phoneNumber = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (context) => OTPScreen(phoneNumber: phoneNumber),
            );
          }
          return null;
        },
      ),
    );
  }
}
