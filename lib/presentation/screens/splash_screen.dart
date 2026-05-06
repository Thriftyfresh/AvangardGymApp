import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String role = 'admin';
        try {
          final doc = await FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .get(const GetOptions(source: Source.cache))
              .timeout(const Duration(seconds: 3), onTimeout: () =>
                  FirebaseFirestore.instance.collection('admins').doc(user.uid).get());
          if (doc.exists && doc.data() != null) {
            role = (doc.data()!['role'] ?? 'admin').toString();
          }
        } catch (_) {}
        
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen(role: role)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/logo.jpg', width: 180, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              const Text(
                'AVANGARD GYM',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
              const SizedBox(height: 8),
              Text(
                'Management System',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, letterSpacing: 1),
              ),
              const Spacer(flex: 3),
              Text(
                'Powered By Fahad Hussain',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
