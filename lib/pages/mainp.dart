import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/providers.dart'; // Import the providers file

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 30, 30, 31),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              "Let's get started!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/illustration.png',
                height: 250,
              ),
            ),
            SizedBox(height: 40),
            Transform.translate(
              offset: Offset(0, -50),
              child: Center(
                child: Text(
                  "Use this app for sharing rides. The best in Ethiopia, just order.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "Log In",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
