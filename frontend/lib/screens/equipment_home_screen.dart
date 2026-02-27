import 'package:flutter/material.dart';
import 'browse_equipment_screen.dart';
import 'list_equipment_screen.dart';

class EquipmentHomeScreen extends StatelessWidget {
  const EquipmentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light earthy background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Deep green
        title: const Text("Equipment Hub"),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🌾 Header Icon
            const Icon(
              Icons.agriculture,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 20),

            const Text(
              "Manage Your Farm Equipment",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 40),

            /// 🌿 Browse Equipment Card
            _buildOptionCard(
              context,
              icon: Icons.search,
              title: "Browse Equipment",
              subtitle: "Explore available farm tools for rent or sale",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrowseEquipmentScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🌿 List Equipment Card
            _buildOptionCard(
              context,
              icon: Icons.add_circle_outline,
              title: "List Equipment",
              subtitle: "Add your equipment for rent or sale",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListEquipmentScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🌿 Reusable Agriculture Themed Card
  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFA5D6A7),
                child: Icon(
                  icon,
                  size: 28,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF2E7D32),
              )
            ],
          ),
        ),
      ),
    );
  }
}
