import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter/material.dart';

// Provider for registration logic
final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier();
});

// State class for registration
class RegisterState {
  final bool isLoading;
  final String? errorMessage;

  RegisterState({this.isLoading = false, this.errorMessage});

  RegisterState copyWith({bool? isLoading, String? errorMessage}) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier for registration logic
class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(RegisterState());

  Future<void> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String role,
    String? plateNumber,
    required BuildContext context,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match!");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final user = ParseUser(email, password, email);
    user.set("phone", phone);
    user.set("role", role);

    if (role == "Driver") {
      user.set("plateNumber", plateNumber);
    }

    var response = await user.signUp();

    state = state.copyWith(isLoading: false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      state = state.copyWith(errorMessage: response.error!.message);
    }
  }
}
