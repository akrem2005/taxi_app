import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/loginProvider.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 21, 21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (loginState.errorMessage != null)
                  Text(
                    loginState.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: loginState.isLoading
                      ? null
                      : () async {
                          await loginNotifier.loginUser(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            context,
                          );
                        },
                  child: loginState.isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'Log In',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Taxi App © All rights reserved",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
