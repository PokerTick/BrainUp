import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:brainup/services/api_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
      _avatarUrl = prefs.getString('userAvatar');
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _isSaving = true);

    final newAvatarUrl = await ApiService.uploadAvatar(pickedFile.path);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (newAvatarUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile picture')),
      );
      return;
    }

    setState(() {
      _avatarUrl = newAvatarUrl;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAvatar', newAvatarUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated successfully')),
    );
  }

  Future<void> _saveUserData() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await ApiService.updateUserProfile(name: name, email: email);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile on server')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    if (!mounted) return;

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Color(0xFF2B2B2F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: const Color(0xFF6B58E6),
            ),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Avatar
            GestureDetector(
              onTap: (_isEditing && !_isSaving) ? _pickAndUploadAvatar : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF6B58E6),
                    child: ClipOval(
                      child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? Image.network(
                              _avatarUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'lib/assets/Takeshi.png',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'lib/assets/Takeshi.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B58E6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2B2B2F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.white : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isEditing
                                ? const Color(0xFF6B58E6)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: const Color(0xFF6B58E6)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2B2B2F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.white : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isEditing
                                ? const Color(0xFF6B58E6)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: const Color(0xFF6B58E6)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button (visible only in editing mode)
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B58E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
