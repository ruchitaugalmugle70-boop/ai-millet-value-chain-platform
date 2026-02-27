import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ListEquipmentScreen extends StatefulWidget {
  const ListEquipmentScreen({Key? key}) : super(key: key);

  @override
  State<ListEquipmentScreen> createState() => _ListEquipmentScreenState();
}

class _ListEquipmentScreenState extends State<ListEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String equipmentName = "";
  String type = "rent";
  String location = "";
  String farmerName = "";
  String pricePerDay = "";
  String salePrice = "";
  String contact = "";

  File? imageFile;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future submitForm() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.0.151:5001/api/equipment/add-equipment"),
    );

    request.fields['equipment_name'] = equipmentName;
    request.fields['type'] = type;
    request.fields['location'] = location;
    request.fields['farmer_name'] = farmerName;
    request.fields['price_per_day'] = pricePerDay;
    request.fields['sale_price'] = salePrice;
    request.fields['contact_number'] = contact;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Equipment Added")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light earthy background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Deep green
        title: const Text("List Equipment"),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// Equipment Name
                      TextFormField(
                        decoration: _inputDecoration("Equipment Name"),
                        onChanged: (val) => equipmentName = val,
                      ),
                      const SizedBox(height: 15),

                      /// Type Dropdown
                      DropdownButtonFormField(
                        value: type,
                        decoration: _inputDecoration("Type"),
                        items: const [
                          DropdownMenuItem(value: "rent", child: Text("Rent")),
                          DropdownMenuItem(value: "sale", child: Text("Sale")),
                        ],
                        onChanged: (val) => setState(() => type = val!),
                      ),
                      const SizedBox(height: 15),

                      /// Location
                      TextFormField(
                        decoration: _inputDecoration("Location"),
                        onChanged: (val) => location = val,
                      ),
                      const SizedBox(height: 15),

                      /// Farmer Name
                      TextFormField(
                        decoration: _inputDecoration("Farmer Name"),
                        onChanged: (val) => farmerName = val,
                      ),
                      const SizedBox(height: 15),

                      /// Price Per Day
                      TextFormField(
                        decoration: _inputDecoration("Price Per Day"),
                        onChanged: (val) => pricePerDay = val,
                      ),
                      const SizedBox(height: 15),

                      /// Sale Price
                      TextFormField(
                        decoration: _inputDecoration("Sale Price"),
                        onChanged: (val) => salePrice = val,
                      ),
                      const SizedBox(height: 15),

                      /// Contact Number
                      TextFormField(
                        decoration: _inputDecoration("Contact Number"),
                        onChanged: (val) => contact = val,
                      ),
                      const SizedBox(height: 20),

                      /// Image Preview
                      if (imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 15),

                      /// Pick Image Button
                      ElevatedButton.icon(
                        style: _buttonStyle(),
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Pick Image"),
                      ),

                      const SizedBox(height: 15),

                      /// Submit Button
                      ElevatedButton.icon(
                        style: _buttonStyle(),
                        onPressed: submitForm,
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌿 Input Decoration (Agriculture Style)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
  }

  /// 🌿 Button Style
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
