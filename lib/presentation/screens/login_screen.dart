import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen(role: state.role)),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a1a), Color(0xFF2d1206), Color(0xFF1a1a1a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset('assets/logo.jpg', width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('AVANGARD GYM',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
                        const SizedBox(height: 4),
                        Text('Management System',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5), letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Sign in to your account', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                            const SizedBox(height: 28),
                            _buildField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),
                            const SizedBox(height: 28),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                                }
                                return SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6D00), Color(0xFFDD2C00)],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      onPressed: () {
                                        final email = _emailController.text.trim();
                                        final password = _passwordController.text.trim();
                                        if (email.isEmpty || password.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please enter email and password')),
                                          );
                                          return;
                                        }
                                        context.read<AuthBloc>().add(LoginRequested(email: email, password: password));
                                      },
                                      child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text('Powered by Fahad Hussain',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.25))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? _obscure : false,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.deepOrange.withOpacity(0.8), size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white38, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
