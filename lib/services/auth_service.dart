import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to manage authentication state and operations
class AuthService {
  // Get the Supabase client instance
  final _supabase = Supabase.instance.client;
  
  // Stream controller to broadcast auth state changes
  final _authStateController = StreamController<AuthState>.broadcast();
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  
  // Factory constructor
  factory AuthService() {
    return _instance;
  }
  
  // Private constructor
  AuthService._internal() {
    // Initialize the auth state listener
    _initAuthStateListener();
  }
  
  // Initialize the auth state listener
  void _initAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      // Broadcast the auth state change
      _authStateController.add(
        AuthState(
          event: event,
          session: session,
          user: session?.user,
        ),
      );
      
      debugPrint('Auth state changed: $event');
    });
  }
  
  // Get the current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Get the current session
  Session? get currentSession => _supabase.auth.currentSession;
  
  // Check if the user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  // Get the auth state stream
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  // Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Class to represent the authentication state
class AuthState {
  final AuthChangeEvent event;
  final Session? session;
  final User? user;
  
  AuthState({
    required this.event,
    this.session,
    this.user,
  });
  
  bool get isAuthenticated => user != null;
}