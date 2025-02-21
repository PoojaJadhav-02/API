
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class GetSingleByIdProduct extends StatefulWidget {
  final int productId;

  const GetSingleByIdProduct({super.key, required this.productId});

  @override
  State<GetSingleByIdProduct> createState() => _GetSingleByIdProductState();
}

class _GetSingleByIdProductState extends State<GetSingleByIdProduct> {
  Map<String, dynamic>? product;

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  void getProductDetails() async {
    Uri url = Uri.parse("https://dummyjson.com/products/${widget.productId}");
    http.Response res = await http.get(url);

    if (res.statusCode == 200) {
      final jsondata = json.decode(res.body);
      log(jsondata.toString());

      setState(() {
        product = jsondata;
      });
    } else {
      log("Failed to fetch product");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light background
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: GoogleFonts.k2d(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: product == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🖼 Product Image with Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            product!['thumbnail'] ??
                                "https://via.placeholder.com/150",
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                "https://via.placeholder.com/150",
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🏷 Product Title
                      Text(
                        product!['title'] ?? "No Title",
                        style: GoogleFonts.k2d(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 5),

                      // 🔹 Brand & Category
                      Text(
                        "${product!['brand'] ?? "Unknown"} - ${product!['category'] ?? "Category"}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey[600],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 📦 Product Details (Inside a Card)
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📝 Description
                              Text(
                                "Description",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product!['description'] ??
                                    "No description available.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),

                              const SizedBox(height: 15),

                              // 💰 Price & Stock
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${product!['price'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "Stock: ${product!['stock'] ?? 'Unavailable'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: (product!['stock'] ?? 0) > 0
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ⭐ Rating
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 22),
                                  Text(
                                    " ${product!['rating']?.toStringAsFixed(1) ?? '0.0'}",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔄 Refresh Button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            product = null;
                          });
                          getProductDetails();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh Data"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
