import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

// ─── Dummy Data Model ────────────────────────────────────────────────────────

class Voucher {
  final int id;
  final String title;
  final String code;
  final String discount;
  final String expiryDate;
  final bool isUsed;

  const Voucher({
    required this.id,
    required this.title,
    required this.code,
    required this.discount,
    required this.expiryDate,
    this.isUsed = false,
  });
}

// ─── Page ────────────────────────────────────────────────────────────────────

class VoucherListPage extends StatefulWidget {
  const VoucherListPage({super.key});

  @override
  State<VoucherListPage> createState() => _VoucherListPageState();
}

class _VoucherListPageState extends State<VoucherListPage> {
  List<Voucher> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final data = await ApiService.getVouchers();
    if (mounted) {
      setState(() {
        _vouchers = data.map((v) {
          final dateStr = v['expiryDate'] as String?;
          final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
          final formattedDate = date != null ? 'Valid until ${DateFormat('dd MMM yyyy').format(date)}' : 'No Expiry';
          
          return Voucher(
            id: v['id'] as int? ?? 0,
            title: v['title'] as String? ?? 'Voucher',
            code: v['code'] as String? ?? 'CODE',
            discount: v['discount']?.toString() ?? 'Discount',
            expiryDate: formattedDate,
            isUsed: v['isUsed'] as bool? ?? false,
          );
        }).toList();
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
          'My Vouchers',
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
                  : _vouchers.isEmpty
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
      itemCount: _vouchers.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index < _vouchers.length) {
          final voucher = _vouchers[index];
          final isFirst = index == 0;
          final isLast = index == _vouchers.length - 1;
          return _VoucherCard(
            voucher: voucher,
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
            Icons.card_giftcard_outlined,
            size: 64,
            color: const Color(0xFF5E4AB3).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No vouchers available',
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

// ─── Voucher Card ────────────────────────────────────────────────────────────

class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final bool isFirst;
  final bool isLast;

  const _VoucherCard({
    required this.voucher,
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
                // Ticket Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: voucher.isUsed
                        ? Colors.grey.shade200
                        : const Color(0xFFE8E0F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_activity_outlined,
                      color: voucher.isUsed
                          ? Colors.grey.shade400
                          : const Color(0xFF5E4AB3),
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
                        voucher.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: voucher.isUsed
                              ? Colors.grey.shade400
                              : const Color(0xFF2B2B2F),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.expiryDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Discount Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      voucher.discount,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: voucher.isUsed
                            ? Colors.grey.shade400
                            : const Color(0xFFE84D8A), // Pink highlight for discount
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: voucher.isUsed
                            ? Colors.grey.shade200
                            : const Color(0xFFF0EDFF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: voucher.isUsed
                              ? Colors.grey.shade500
                              : const Color(0xFF5E4AB3),
                          letterSpacing: 0.5,
                        ),
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
