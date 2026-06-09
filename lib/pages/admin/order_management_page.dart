import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import 'package:intl/intl.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await AdminApiService.getAllOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _showEditDialog(Map<String, dynamic> order) {
    String status = order['status'] ?? 'PENDING';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Order #${order['id']}'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                        DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                        DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => status = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await AdminApiService.updateOrderStatus(order['id'], status);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order status updated')));
                      _loadOrders();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update order')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B58E6)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order & Revenue Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2B2B2F)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadOrders,
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Revenue calculation based on Business Flow: Net Revenue = Price - Coupon. Trainer gets 80% of Net, Platform gets 20%. Plus Rp 10.000 flat Service Fee for platform.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B58E6)))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Order ID')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Course')),
                            DataColumn(label: Text('Course Price')),
                            DataColumn(label: Text('Coupon')),
                            DataColumn(label: Text('Net Revenue')),
                            DataColumn(label: Text('Trainer (80%)')),
                            DataColumn(label: Text('Platform (20%)')),
                            DataColumn(label: Text('Service Fee')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _orders.map((order) {
                            final date = DateTime.tryParse(order['createdAt'] ?? '');
                            final dateStr = date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

                            return DataRow(cells: [
                              DataCell(Text('#${order['id']}')),
                              DataCell(Text(dateStr)),
                              DataCell(Text(order['user']?['name'] ?? '-')),
                              DataCell(Text(order['course']?['title'] ?? '-')),
                              DataCell(Text(_formatCurrency(order['coursePrice']))),
                              DataCell(Text('${order['couponDiscount']}%', style: const TextStyle(color: Colors.red))),
                              DataCell(Text(_formatCurrency(order['netRevenue']), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(_formatCurrency(order['trainerShare']), style: TextStyle(color: Colors.orange.shade700))),
                              DataCell(Text(_formatCurrency(order['platformShare']), style: TextStyle(color: Colors.green.shade700))),
                              DataCell(Text(_formatCurrency(order['serviceFee']), style: TextStyle(color: Colors.teal.shade700))),
                              DataCell(
                                Chip(
                                  label: Text(
                                    order['status'] ?? 'UNKNOWN',
                                    style: TextStyle(
                                      color: order['status'] == 'COMPLETED' ? Colors.green.shade700 : Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: order['status'] == 'COMPLETED' ? Colors.green.shade50 : Colors.orange.shade50,
                                  side: BorderSide.none,
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Edit Order Status',
                                  onPressed: () => _showEditDialog(order),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
