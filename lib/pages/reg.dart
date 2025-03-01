import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/registerProvider.dart';

class RegisterPage extends ConsumerWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  String selectedRole = 'Rider';

  RegisterPage({super.key}); // Default role

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerProvider);
    final registerNotifier = ref.read(registerProvider.notifier);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 19, 19, 20),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 38, 38, 39),
        title: Text(
          "Register",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Create an Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: Color.fromARGB(255, 47, 47, 48),
                style: TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Select Role",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber)),
                ),
                items: ['Driver', 'Rider'].map((role) {
                  return DropdownMenuItem(
                      value: role,
                      child: Text(role, style: TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (value) => selectedRole = value!,
              ),
              SizedBox(height: 10),
              _buildTextField("Phone Number", phoneController),
              if (selectedRole == 'Driver')
                _buildTextField("Plate No", plateNumberController),
              _buildTextField("Email", emailController),
              _buildTextField("Password", passwordController, isPassword: true),
              _buildTextField("Confirm Password", confirmPasswordController,
                  isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: registerState.isLoading
                    ? null
                    : () async {
                        await registerNotifier.registerUser(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          confirmPassword:
                              confirmPasswordController.text.trim(),
                          phone: phoneController.text.trim(),
                          role: selectedRole,
                          plateNumber: selectedRole == 'Driver'
                              ? plateNumberController.text.trim()
                              : null,
                          context: context,
                        );
                      },
                child: registerState.isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text('Register',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: Text("Taxi App © All rights reserved",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        ),
      ),
    );
  }
}
