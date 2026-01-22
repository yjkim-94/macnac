import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/profile_screen.dart';
import 'models/news_article_model.dart';

void main() {
  runApp(const MacnacApp());
}

class MacnacApp extends StatelessWidget {
  const MacnacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'MACNAC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Detail 화면은 arguments를 받아야 하므로 onGenerateRoute 사용
          if (settings.name == '/detail') {
            final article = settings.arguments as NewsArticleModel;
            return MaterialPageRoute(
              builder: (context) => NewsDetailScreen(article: article),
            );
          }
          return null;
        },
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
