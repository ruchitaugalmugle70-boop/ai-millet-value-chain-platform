import 'package:flutter/material.dart';
import '../services/buyer_service.dart';

class BuyerRegisterScreen extends StatefulWidget {
  const BuyerRegisterScreen({super.key});

  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final nameController = TextEditingController();
  final regionController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final BuyerService _service = BuyerService();
  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);

    final result = await _service.register(
      nameController.text.trim(),
      regionController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result.containsKey("message")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["message"])));

      Navigator.pushReplacementNamed(context, "/buyer-login");
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["error"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buyer Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: regionController,
                decoration: const InputDecoration(labelText: "Region")),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone")),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
