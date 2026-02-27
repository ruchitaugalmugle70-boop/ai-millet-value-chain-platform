import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EquipmentDetailScreen extends StatelessWidget {
  final String id;

  const EquipmentDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<Map<String, dynamic>> fetchEquipmentDetail() async {
    final response = await http.get(
      Uri.parse("http://192.168.0.151:5001/api/equipment/equipment/$id"),
    );

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text("Equipment Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEquipmentDetail(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    "http://192.168.1.101:5001/uploads/equipment/${data['image']}",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['equipment_name'],
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data['type'] == "rent"
                              ? "₹${data['price_per_day']} per day"
                              : "₹${data['sale_price']}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const Divider(height: 25),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF2E7D32)),
                            const SizedBox(width: 6),
                            Text(data['location']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 6),
                            Text(data['farmer_name']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 6),
                            Text(data['contact_number']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
