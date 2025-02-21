import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class GetSingleProduct extends StatefulWidget {
  const GetSingleProduct({super.key});

  @override
  State<GetSingleProduct> createState() => _GetSingleProductState();
}

class _GetSingleProductState extends State<GetSingleProduct> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  Future<void> getProductDetails() async {
    try {
      Uri url = Uri.parse("https://dummyjson.com/products/1");
      http.Response res = await http.get(url);

      if (res.statusCode == 200) {
        final jsondata = json.decode(res.body);
        setState(() {
          product = jsondata;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch product");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProductDetails(Map<String, dynamic> updatedData) async {
    try {
      Uri url = Uri.parse("https://dummyjson.com/products/1");
      http.Response res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (res.statusCode == 200) {
        final jsondata = json.decode(res.body);
        setState(() {
          product = jsondata;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully!")),
        );
      } else {
        throw Exception("Failed to update product");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating product")),
      );
    }
  }

  Future<void> deleteProduct() async {
    try {
      Uri url = Uri.parse("https://dummyjson.com/products/1");
      http.Response res = await http.delete(url);

      if (res.statusCode == 200) {
        setState(() {
          isDeleted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deleted successfully!")),
        );
      } else {
        throw Exception("Failed to delete product");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting product")),
      );
    }
  }

  void showEditDialog() {
    TextEditingController titleController =
        TextEditingController(text: product?['title']);
    TextEditingController descController =
        TextEditingController(text: product?['description']);
    TextEditingController priceController =
        TextEditingController(text: product?['price'].toString());
    TextEditingController stockController =
        TextEditingController(text: product?['stock'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title")),
              TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description")),
              TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: "Stock"),
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> updatedData = {
                "title": titleController.text,
                "description": descController.text,
                "price":
                    double.tryParse(priceController.text) ?? product?['price'],
                "stock":
                    int.tryParse(stockController.text) ?? product?['stock'],
              };
              updateProductDetails(updatedData);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this product? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteProduct();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Product Details", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: showEditDialog, icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: showDeleteConfirmation,
              icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
      body: isDeleted
          ? const Center(child: Text("Product has been deleted."))
          : isLoading
              ? _buildShimmerEffect()
              : product == null
                  ? const Center(child: Text("Failed to load product"))
                  : _buildProductDetails(),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
                height: 200, width: double.infinity, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 20, width: 200, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product!['thumbnail'] ?? "https://via.placeholder.com/150",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
          const SizedBox(height: 15),
          Text(product!['title'] ?? "No Title",
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
              "${product!['brand'] ?? "Unknown"} - ${product!['category'] ?? "Category"}",
              style:
                  GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 10),
          Text(product!['description'] ?? "No description available.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
