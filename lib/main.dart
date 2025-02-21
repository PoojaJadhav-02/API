
import 'package:flutter/material.dart';
import 'package:time_company/screens/home_screen.dart';
import 'package:time_company/screens/login_screen.dart';
import 'package:time_company/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  bool isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? ProfileScreen() : LoginScreen(),
    );
    // home: GetSingleProduct());
  }
}
