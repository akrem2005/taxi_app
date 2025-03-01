import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter/material.dart';

// Provider for login logic
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});

// State class for login
class LoginState {
  final bool isLoading;
  final String? errorMessage;

  LoginState({this.isLoading = false, this.errorMessage});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier for login logic
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState());

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Email and password are required!",
      );
      return;
    }

    final user = ParseUser(email, password, null);
    final response = await user.login();

    if (response.success && response.result != null) {
      final currentUser = await ParseUser.currentUser();
      final role = currentUser
          .get<String>('role'); // Ensure 'role' field exists in your database

      if (role == 'Rider') {
        Navigator.pushReplacementNamed(context, '/rider');
      } else if (role == 'Driver') {
        Navigator.pushReplacementNamed(context, '/driver');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Unknown role. Please contact support.",
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Invalid credentials. Please try again.",
      );
    }
  }
}
