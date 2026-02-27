import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterMilletScreen extends StatefulWidget {
  final String token;

  const RegisterMilletScreen({super.key, required this.token});

  @override
  State<RegisterMilletScreen> createState() => _RegisterMilletScreenState();
}

class _RegisterMilletScreenState extends State<RegisterMilletScreen> {
  final nameController = TextEditingController();
  final varietyController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  String storageMethod = "Traditional";
  bool hardwareVerified = false;
  bool isLoading = false;

  File? hardwareReportImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        hardwareReportImage = File(picked.path);
      });
    }
  }

  Future<void> registerMillet() async {
    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (storageMethod == "Fumigation" && hardwareReportImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload report image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.1.101:5001/api/crop/add-millet"),
      );

      request.headers["Authorization"] = "Bearer ${widget.token}";

      request.fields["millet_name"] = nameController.text.trim();
      request.fields["millet_variety"] = varietyController.text.trim();
      request.fields["quantity"] = quantityController.text.trim();
      request.fields["price_per_kg"] = priceController.text.trim();
      request.fields["storage_method"] = storageMethod;
      request.fields["hardware_verified"] = hardwareVerified.toString();

      if (storageMethod == "Fumigation") {
        request.files.add(
          await http.MultipartFile.fromPath(
            "hardware_report",
            hardwareReportImage!.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Error")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Millet")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Millet Name")),
            TextField(
                controller: varietyController,
                decoration: const InputDecoration(labelText: "Variety")),
            TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity")),
            TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price")),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: storageMethod,
              items: const [
                DropdownMenuItem(
                    value: "Traditional", child: Text("Traditional")),
                DropdownMenuItem(
                    value: "Fumigation", child: Text("Fumigation")),
              ],
              onChanged: (val) {
                setState(() {
                  storageMethod = val!;
                });
              },
            ),
            if (storageMethod == "Fumigation") ...[
              CheckboxListTile(
                title: const Text("Hardware Verified"),
                value: hardwareVerified,
                onChanged: (val) {
                  setState(() {
                    hardwareVerified = val!;
                  });
                },
              ),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Upload Report Image"),
              ),
              if (hardwareReportImage != null)
                Image.file(
                  hardwareReportImage!,
                  height: 150,
                ),
            ],
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerMillet,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
