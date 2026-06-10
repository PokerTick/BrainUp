import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _selectedRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await AdminApiService.getAllUsers(
      roleFilter: _selectedRoleFilter == 'ALL' ? null : _selectedRoleFilter,
    );
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRole(int userId, String newRole) async {
    final errorMsg = await AdminApiService.updateUserRole(userId, newRole);
    if (errorMsg == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
        _loadUsers();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _updateAvatar(int userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _isLoading = true);
      final success = await AdminApiService.updateUserAvatar(userId, bytes, pickedFile.name);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update avatar')),
          );
        }
        _loadUsers();
      }
    }
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
                'User Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2B2B2F)),
              ),
              DropdownButton<String>(
                value: _selectedRoleFilter,
                items: ['ALL', 'USER', 'TRAINER', 'ADMIN']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRoleFilter = val);
                    _loadUsers();
                  }
                },
              ),
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
                            DataColumn(label: Text('Avatar')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Registered')),
                            DataColumn(label: Text('Role')),
                          ],
                          rows: _users.map((user) {
                            final date = DateTime.tryParse(user['createdAt'] ?? '');
                            final dateStr = date != null ? DateFormat('dd MMM yyyy, HH:mm').format(date) : '-';

                            return DataRow(cells: [
                              DataCell(Text('${user['id']}')),
                              DataCell(
                                GestureDetector(
                                  onTap: () => _updateAvatar(user['id']),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFF0EDFF),
                                    backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                                    child: user['avatar'] == null ? const Icon(Icons.person, size: 20, color: Color(0xFF6B58E6)) : null,
                                  ),
                                ),
                              ),
                              DataCell(Text(user['name'] ?? '-')),
                              DataCell(Text(user['email'] ?? '-')),
                              DataCell(Text(dateStr)),
                              DataCell(
                                DropdownButton<String>(
                                  value: user['role'],
                                  items: ['USER', 'TRAINER', 'ADMIN']
                                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                      .toList(),
                                  onChanged: (newRole) {
                                    if (newRole != null && newRole != user['role']) {
                                      _updateRole(user['id'], newRole);
                                    }
                                  },
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
