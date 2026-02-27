import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/government_service.dart';
import '../config/api_config.dart';

class GovernmentScreen extends StatefulWidget {
  const GovernmentScreen({super.key});

  @override
  State<GovernmentScreen> createState() => _GovernmentScreenState();
}

class _GovernmentScreenState extends State<GovernmentScreen>
    with SingleTickerProviderStateMixin {
  final GovernmentService _service = GovernmentService();

  List farmers = [];
  Map stats = {};
  bool isLoading = true;
  String searchDistrict = "";

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadData();
  }

  void loadData() async {
    final farmerData = await _service.getFarmers();
    final statData = await _service.getStats();

    setState(() {
      farmers = farmerData;
      stats = statData;
      isLoading = false;
    });
  }

  void search() async {
    final data = await _service.getFarmers(district: searchDistrict);
    setState(() => farmers = data);
  }

  void approve(String id) async {
    await _service.approveFarmer(id);
    loadData();
  }

  void reject(String id) async {
    await _service.rejectFarmer(id);
    loadData();
  }

  Future<void> openFile(String path) async {
    if (path.isEmpty) return;

    final base = ApiConfig.baseUrl.replaceAll('/api', '');
    final url = "$base/$path";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget statCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildApprovalTab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Row(
                children: [
                  statCard("Total", stats["total_farmers"]?.toString() ?? "0",
                      Colors.blue),
                  statCard(
                      "Approved",
                      stats["approved_farmers"]?.toString() ?? "0",
                      Colors.green),
                  statCard(
                      "Pending",
                      stats["pending_farmers"]?.toString() ?? "0",
                      Colors.orange),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: "Search by District"),
                        onChanged: (value) => searchDistrict = value,
                      ),
                    ),
                    IconButton(
                      onPressed: search,
                      icon: const Icon(Icons.search),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = farmers[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer["name"],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text("District: ${farmer["district"]}"),
                            Text("Mobile: ${farmer["mobile"]}"),
                            Text("Land: ${farmer["area"]} acres"),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              children: [
                                TextButton(
                                    onPressed: () =>
                                        openFile(farmer["aadhar_path"]),
                                    child: const Text("Aadhar")),
                                TextButton(
                                    onPressed: () =>
                                        openFile(farmer["land_record_path"]),
                                    child: const Text("Land Record")),
                                TextButton(
                                    onPressed: () =>
                                        openFile(farmer["crop_photo_path"]),
                                    child: const Text("Farm photo")),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (farmer["approved"] == true)
                                  const Chip(
                                    label: Text("Approved"),
                                    backgroundColor: Colors.green,
                                  )
                                else ...[
                                  ElevatedButton(
                                    onPressed: () => approve(farmer["_id"]),
                                    child: const Text("Approve"),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () => reject(farmer["_id"]),
                                    child: const Text("Reject"),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget buildCropTab() {
    return const Center(
      child: Text(
        "All Registered Crops Will Appear Here",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget buildSuggestionTab() {
    return const Center(
      child: Text(
        "AI Farm Suggestion Monitoring Panel",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Approvals"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildApprovalTab(),
          buildCropTab(),
          buildSuggestionTab(),
        ],
      ),
    );
  }
}
