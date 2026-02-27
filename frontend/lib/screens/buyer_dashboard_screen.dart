import 'package:flutter/material.dart';
import 'Market_place_screen.dart';

class BuyerDashboardScreen extends StatelessWidget {
  final Map buyerData;
  final String token;

  const BuyerDashboardScreen({
    super.key,
    required this.buyerData,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyer Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${buyerData["name"]}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Browse & Buy Millets"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarketplaceScreen(token: token),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
