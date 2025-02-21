import 'package:flutter/material.dart';
import 'package:time_company/screens/post_screen.dart';
import '../model/get_all_product.dart';
import '../model/get_product_by_id.dart';
import '../model/single_product.dart';
import '../services/auth_service.dart';
import 'SearchProductScreen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userData = await _authService.fetchUserProfile();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  void _logout() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      await _authService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 118, 61, 215),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("Failed to load profile"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(_userData!['image']),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${_userData!['firstName']} ${_userData!['lastName']}",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("ID: ${_userData!['id']}",
                                      style: const TextStyle(fontSize: 16)),
                                  Text("Email: ${_userData!['email']}",
                                      style: const TextStyle(fontSize: 18)),
                                  Text("Age: ${_userData!['age']}",
                                      style: const TextStyle(fontSize: 16)),
                                  Text("Gender: ${_userData!['gender']}",
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Product Actions",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: isLargeScreen ? 3 : 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3,
                                children: [
                                  _buildActionButton("Get All Products",
                                      Icons.list, const GetAllProduct()),
                                  _buildActionButton("Post Product",
                                      Icons.add_box, const PostProductScreen()),
                                  _buildActionButton(
                                      "Search Product",
                                      Icons.search,
                                      const SearchProductScreen()), // NEW BUTTON
                                  _buildActionButton(
                                      "Get First Product",
                                      Icons.shopping_bag,
                                      const GetSingleProduct()),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Get Product By ID",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: TextField(
                              controller: _idController,
                              decoration: InputDecoration(
                                labelText: "Enter Product ID",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => GetSingleByIdProduct(
                                        productId:
                                            int.parse(_idController.text),
                                      )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              minimumSize: Size(
                                  isLargeScreen ? 400 : double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Fetch Product",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(226, 127, 73, 222),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
