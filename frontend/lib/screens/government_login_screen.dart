import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'government_screen.dart';

class GovernmentLoginScreen extends StatefulWidget {
  const GovernmentLoginScreen({super.key});

  @override
  State<GovernmentLoginScreen> createState() => _GovernmentLoginScreenState();
}

class _GovernmentLoginScreenState extends State<GovernmentLoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/government/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GovernmentScreen()),
        );
      } else {
        String errorMessage = "Login Failed";

        // Try parsing JSON safely
        try {
          final data = jsonDecode(response.body);
          errorMessage = data["error"] ?? errorMessage;
        } catch (e) {
          errorMessage = "Server Error";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Connection Error. Check backend server.")),
      );

      print("Login Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 25),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      child: const Text("Login"),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
