import 'package:borsa_projesi_son/screens/main.navigation.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart'; // Login ekranı

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: const Color(0xFF1A1A1A),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedef Fiyat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFF00B050),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF2C2C2C),
          elevation: 1,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // home parametresini Auth kontrolüne bağlıyoruz:
      home: const AuthWrapper(),
    );
  }
}

// Kullanıcının oturum durumunu kontrol eden ara katman
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Durum bekleyişi (Firebase yüklenirken)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF00B050))),
          );
        }

        // Eğer kullanıcı verisi varsa (Giriş yapılmışsa) -> Ana Ekrana git
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // Giriş yapılmamışsa -> Login Ekranına git
        return const LoginScreen();
      },
    );
  }
}