import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final TextEditingController _districtController = TextEditingController();
  Future<List<dynamic>>? _futureWarehouses;

  Future<List<dynamic>> fetchWarehouses(String district) async {
    final uri = Uri.http(
      "192.168.0.151:5001",
      "/api/warehouses",
      {"district": district},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load warehouses");
    }
  }

  void searchWarehouses() {
    String district = _districtController.text.trim();
    if (district.isEmpty) return;

    setState(() {
      _futureWarehouses = fetchWarehouses(district);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏬 Find Warehouses"),
        backgroundColor: const Color(0xFF0B5D1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _districtController,
              decoration: InputDecoration(
                labelText: "Enter District",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchWarehouses,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5D1E),
              ),
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _futureWarehouses == null
                  ? const Center(
                      child: Text("Enter district to search warehouses"))
                  : FutureBuilder<List<dynamic>>(
                      future: _futureWarehouses,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading warehouses"));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No Warehouses Found"));
                        }

                        final warehouses = snapshot.data!;

                        return ListView.builder(
                          itemCount: warehouses.length,
                          itemBuilder: (context, index) {
                            final w = warehouses[index];

                            double utilization = 0;
                            if (w["capacity_total"] != 0) {
                              utilization = (w["capacity_total"] -
                                      w["capacity_available"]) /
                                  w["capacity_total"];
                            }

                            return Card(
                              margin: const EdgeInsets.all(12),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "🏬 ${w["name"]}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),

                                    Text("📍 ${w["district"]}"),
                                    const SizedBox(height: 6),

                                    Text(
                                      "📦 ${w["capacity_available"]}/${w["capacity_total"]} tons available",
                                    ),
                                    const SizedBox(height: 6),

                                    Text(
                                      "💰 ₹${w["storage_cost_per_ton"]}/ton",
                                    ),
                                    const SizedBox(height: 6),

                                    // ✅ CONTACT NUMBER ADDED
                                    Text(
                                      "📞 ${w["contact_number"] ?? "Not Available"}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text("📊 Utilization"),
                                    const SizedBox(height: 4),

                                    LinearProgressIndicator(
                                      value: utilization,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[300],
                                      color: const Color(0xFF0B5D1E),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
