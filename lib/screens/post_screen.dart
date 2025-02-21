import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PostProductScreen extends StatefulWidget {
  const PostProductScreen({super.key});

  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();

  bool _isLoading = false;

  // Function to add a product
  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Uri url = Uri.parse("https://dummyjson.com/products/add");

    Map<String, dynamic> productData = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "brand": _brandController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category": _categoryController.text.trim(),
      "stock": int.tryParse(_stockController.text) ?? 0,
      "rating": double.tryParse(_ratingController.text) ?? 0.0,
      "thumbnail": _thumbnailController.text.trim(),
    };

    http.Response res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );

    setState(() {
      _isLoading = false;
    });

    if (res.statusCode == 200 || res.statusCode == 201) {
      final jsonResponse = json.decode(res.body);
      log("Product Added: $jsonResponse");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product added successfully!")),
      );

      _clearForm();
    } else {
      log("Failed to add product");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to add product")),
      );
    }
  }

  // Function to clear form fields
  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _brandController.clear();
    _priceController.clear();
    _categoryController.clear();
    _stockController.clear();
    _ratingController.clear();
    _thumbnailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Add Product", style: GoogleFonts.k2d(fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_titleController, "Title", Icons.title,
                        required: true),
                    _buildTextField(
                        _descController, "Description", Icons.description),
                    _buildTextField(
                        _brandController, "Brand", Icons.branding_watermark),
                    _buildTextField(
                        _priceController, "Price", Icons.attach_money,
                        required: true, isNumber: true),
                    _buildTextField(
                        _categoryController, "Category", Icons.category),
                    _buildTextField(_stockController, "Stock", Icons.inventory,
                        required: true, isNumber: true),
                    _buildTextField(_ratingController, "Rating", Icons.star,
                        isNumber: true),
                    _buildTextField(
                        _thumbnailController, "Image URL", Icons.image),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Product"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to build TextFields with Icons
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool required = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "$label is required!";
                }
                return null;
              }
            : null,
      ),
    );
  }
}
