import 'package:flutter/material.dart';

class TrainerSignUpPage extends StatefulWidget {
  const TrainerSignUpPage({super.key});

  @override
  State<TrainerSignUpPage> createState() => _TrainerSignUpPageState();
}

class _TrainerSignUpPageState extends State<TrainerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _expertiseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _expertiseController.dispose();
    _experienceController.dispose();
    _portfolioController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate an API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully! We will review it shortly.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
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
          'Become a Trainer',
          style: TextStyle(
            color: Color(0xFF2B2B2F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B58E6), Color(0xFF8B7AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Share your knowledge\nwith the world.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join our community of expert trainers and start earning by teaching what you love.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Application Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2F),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Expertise Field
                    _buildInputField(
                      controller: _expertiseController,
                      label: 'Area of Expertise',
                      hint: 'e.g. Flutter Development, UI/UX Design',
                      icon: Icons.work_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your area of expertise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Experience Field
                    _buildInputField(
                      controller: _experienceController,
                      label: 'Years of Experience',
                      hint: 'e.g. 5 years',
                      icon: Icons.timeline,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your experience';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Portfolio Field
                    _buildInputField(
                      controller: _portfolioController,
                      label: 'Portfolio / LinkedIn URL',
                      hint: 'https://...',
                      icon: Icons.link,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    // Bio Field
                    _buildInputField(
                      controller: _bioController,
                      label: 'Short Bio',
                      hint: 'Tell us a bit about yourself...',
                      icon: Icons.person_outline,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please tell us about yourself';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B58E6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Application',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2B2B2F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: Colors.grey.shade400)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: Icon(icon, color: Colors.grey.shade400),
                  ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B58E6), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
