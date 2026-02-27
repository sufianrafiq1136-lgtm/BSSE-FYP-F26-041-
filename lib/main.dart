import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const PoultryFarmApp());
}

class PoultryFarmApp extends StatelessWidget {
  const PoultryFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poultry Farm Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
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
    );
  }
}
