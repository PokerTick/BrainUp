import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import 'package:intl/intl.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await AdminApiService.getAllCourses();
    if (mounted) {
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _showEditDialog(Map<String, dynamic> course) {
    final titleController = TextEditingController(text: course['title']);
    final priceController = TextEditingController(text: '${course['price'] ?? 0}');
    String status = course['status'] ?? 'DRAFT';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Course'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Course Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (Rp)'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                        DropdownMenuItem(value: 'PUBLISHED', child: Text('PUBLISHED')),
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
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final success = await AdminApiService.updateCourse(
                      course['id'],
                      {
                        'title': titleController.text,
                        'price': price,
                        'status': status,
                      },
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course updated')));
                      _loadCourses();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update course')));
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
                'Course Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2B2B2F)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadCourses,
              )
            ],
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
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Course Title')),
                            DataColumn(label: Text('Trainer')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Enrollments')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _courses.map((course) {
                            return DataRow(cells: [
                              DataCell(Text('${course['id']}')),
                              DataCell(Text(course['title'] ?? '-')),
                              DataCell(Text(course['trainer']?['name'] ?? '-')),
                              DataCell(Text(course['category']?['name'] ?? '-')),
                              DataCell(Text(course['isFree'] == true ? 'Free' : _formatCurrency(course['price']))),
                              DataCell(
                                Chip(
                                  label: Text(
                                    course['status'] ?? 'UNKNOWN',
                                    style: TextStyle(
                                      color: course['status'] == 'PUBLISHED' ? Colors.green.shade700 : Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: course['status'] == 'PUBLISHED' ? Colors.green.shade50 : Colors.orange.shade50,
                                  side: BorderSide.none,
                                ),
                              ),
                              DataCell(Text('${course['enrollmentCount'] ?? 0}')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Edit Course',
                                  onPressed: () => _showEditDialog(course),
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
