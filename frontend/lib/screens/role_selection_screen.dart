import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // ✅ ensures full width alignment
              children: [
                const Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Color(0xFF0B5D1E),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Choose Portal",
                  textAlign: TextAlign.center, // ✅ keep heading centered
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B5D1E),
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/farmer-auth");
                    },
                    child: const Text(
                      "Farmer Portal",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/government-login");
                    },
                    child: const Text(
                      "Government Portal",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 25), // ✅ Added missing spacing

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/buyer-auth");
                    },
                    child: const Text(
                      "Buyer Portal",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
