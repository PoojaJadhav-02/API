

import 'dart:developer';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchProductScreen createState() => _SearchProductScreen();
}

class _SearchProductScreen extends State<SearchProductScreen> {
  Dio dio = Dio();
  List products = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedSort =
      "None"; // Sorting: None, Low to High, High to Low, A-Z, Z-A
  String selectedCategory = "All"; // Category filter
  List<String> categories = [
    "All",
    "smartphones",
    "laptops",
    "fragrances",
    "skincare",
    "groceries"
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fetch Products from API
  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    try {
      String url = "https://dummyjson.com/products";

      if (searchQuery.isNotEmpty) {
        url = "https://dummyjson.com/products/search?q=$searchQuery";
      } else if (selectedCategory != "All") {
        url = "https://dummyjson.com/products/category/$selectedCategory";
      }

      final response = await dio.get(url);
      List data = response.data["products"];

      // Apply Sorting Logic
      if (selectedSort == "Low to High") {
        data.sort((a, b) => a["price"].compareTo(b["price"]));
      } else if (selectedSort == "High to Low") {
        data.sort((a, b) => b["price"].compareTo(a["price"]));
      } else if (selectedSort == "A-Z") {
        data.sort(
            (a, b) => a["title"].toString().compareTo(b["title"].toString()));
      } else if (selectedSort == "Z-A") {
        data.sort(
            (a, b) => b["title"].toString().compareTo(a["title"].toString()));
      }

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                fetchProducts();
              },
              decoration: InputDecoration(
                hintText: "Search product...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // Sorting & Filtering Dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Sorting Dropdown
                DropdownButton<String>(
                  value: selectedSort,
                  items: ["None", "Low to High", "High to Low", "A-Z", "Z-A"]
                      .map((sort) =>
                          DropdownMenuItem(value: sort, child: Text(sort)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSort = value!;
                    });
                    fetchProducts();
                  },
                ),
                const SizedBox(width: 20),
                // Filtering Dropdown (Categories)
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                    fetchProducts();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Product List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: Image.network(product["thumbnail"],
                                  width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(product["title"]),
                              subtitle: Text("\$${product["price"]}"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Navigate to product details (if needed)
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
