import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerAuthScreen extends StatelessWidget {
  const BuyerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      body: Column(
        children: [
          /// 🌾 TOP GRADIENT HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 70),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B5D1E),
                  Color(0xFF1E8E3E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: const [
                Icon(Icons.shopping_cart, size: 70, color: Colors.white),
                SizedBox(height: 15),
                Text(
                  "Buyer Portal",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Purchase Millets Directly from Farmers",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          /// 🌿 AUTH CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Welcome Buyer",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B5D1E),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/buyer-register");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B5D1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/buyer-login");
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF0B5D1E), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.login, color: Color(0xFF0B5D1E)),
                      label: const Text(
                        "Login",
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF0B5D1E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
