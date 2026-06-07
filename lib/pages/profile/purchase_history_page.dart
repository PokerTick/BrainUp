import 'package:flutter/material.dart';

// ─── Dummy Data Model ────────────────────────────────────────────────────────

class PurchaseRecord {
  final int id;
  final String title;
  final String date;
  final String amount;
  final bool isSuccess;

  const PurchaseRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isSuccess,
  });
}

final _mockPurchases = [
  const PurchaseRecord(
    id: 1,
    title: 'Generative AI for Beginners',
    date: '12 Oct 2023',
    amount: '\$49.99',
    isSuccess: true,
  ),
  const PurchaseRecord(
    id: 2,
    title: 'How to train ur monkey',
    date: '08 Oct 2023',
    amount: '\$29.99',
    isSuccess: true,
  ),
  const PurchaseRecord(
    id: 3,
    title: 'Grabbing the axolotl',
    date: '01 Oct 2023',
    amount: '\$15.00',
    isSuccess: false,
  ),
];

// ─── Page ────────────────────────────────────────────────────────────────────

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  List<PurchaseRecord> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _purchases = _mockPurchases;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Purchase History',
          style: TextStyle(
            color: Color(0xFF2B2B2F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5E4AB3),
                      ),
                    )
                  : _purchases.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _purchases.length + 1, // +1 for "that's all ~" footer
      itemBuilder: (context, index) {
        if (index < _purchases.length) {
          final purchase = _purchases[index];
          final isFirst = index == 0;
          final isLast = index == _purchases.length - 1;
          return _PurchaseCard(
            purchase: purchase,
            isFirst: isFirst,
            isLast: isLast,
          );
        }
        return const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 8),
          child: Center(
            child: Text(
              "that's all ~",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB0A0D0),
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: const Color(0xFF5E4AB3).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No purchase history',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB0A0D0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Purchase Card ───────────────────────────────────────────────────────────

class _PurchaseCard extends StatelessWidget {
  final PurchaseRecord purchase;
  final bool isFirst;
  final bool isLast;

  const _PurchaseCard({
    required this.purchase,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
      topRight: isFirst ? const Radius.circular(16) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon placeholder (replaces thumbnail)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E0F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book_outlined,
                      color: Color(0xFF5E4AB3),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2B2F),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        purchase.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      purchase.amount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2B2F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      purchase.isSuccess ? 'Success' : 'Failed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: purchase.isSuccess
                            ? const Color(0xFFB5E048)
                            : Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          if (!isLast)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF0EBF8),
            ),
        ],
      ),
    );
  }
}
