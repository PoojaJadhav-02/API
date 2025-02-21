import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class GetAllProduct extends StatefulWidget {
  const GetAllProduct({super.key});

  @override
  State<GetAllProduct> createState() => _GetAllProductState();
}

class _GetAllProductState extends State<GetAllProduct> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    getProductList();
  }

  void getProductList() async {
    Uri url = Uri.parse("https://dummyjson.com/products");
    http.Response res = await http.get(url);

    if (res.statusCode == 200) {
      final jsondata = json.decode(res.body);
      log(jsondata.toString());

      setState(() {
        products = jsondata['products'] ?? [];
      });
    } else {
      log("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Soft background color
      appBar: AppBar(
        title: Text(
          "All Products",
          style: GoogleFonts.k2d(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                products = [];
              });
              getProductList();
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];

                      // Handle null values with defaults
                      String title = product['title'] ?? "No Title";
                      String brand = product['brand'] ?? "Unknown Brand";
                      String category =
                          product['category'] ?? "Unknown Category";
                      String description =
                          product['description'] ?? "No description available.";
                      String price = product['price'] != null
                          ? "\$${product['price']}"
                          : "Price not available";
                      String stock = product['stock'] != null
                          ? "Stock: ${product['stock']}"
                          : "Stock unavailable";
                      double rating = product['rating'] != null
                          ? product['rating'].toDouble()
                          : 0.0;
                      String imageUrl = product['thumbnail'] ??
                          "https://via.placeholder.com/150"; // Default image

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🖼 Product Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      "https://via.placeholder.com/150",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 📌 Product Title
                                  Text(
                                    title,
                                    style: GoogleFonts.k2d(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // 🔹 Brand & Category
                                  Text(
                                    "$brand - $category",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // 📝 Description
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // 💰 Price & Stock
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        price,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        stock,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: product['stock'] != null &&
                                                  product['stock'] > 0
                                              ? Colors.blue
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  // ⭐ Rating with Stars
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 18),
                                      Text(
                                        " ${rating.toStringAsFixed(1)}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
