import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final TextEditingController _searchController = TextEditingController();

  // Placeholder wishlist data
  final List<Map<String, String>> _wishlistItems = [
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G-', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
    {'name': 'Course Name', 'trainer': 'Trainer G.', 'price': 'FREE'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF2B2B2F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your Wishlist',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Course Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = _wishlistItems[index];
                  return _WishlistCard(
                    name: item['name']!,
                    trainer: item['trainer']!,
                    price: item['price']!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final String name;
  final String trainer;
  final String price;

  const _WishlistCard({
    required this.name,
    required this.trainer,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Purple placeholder image
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B58E6), Color(0xFF8B7AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2B2F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          trainer,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B58E6),
          ),
        ),
      ],
    );
  }
}
