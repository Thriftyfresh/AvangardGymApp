import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Fetch role from admins collection
      String role = 'admin';
      final uid = result.user?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          role = (doc.data()!['role'] ?? 'admin').toString();
        }
      }

      emit(AuthAuthenticated(role: role));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }
}
