import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../ui/bottomnavigation.dart';

// ─── Page ────────────────────────────────────────────────────────────────────

class NewCoursePage extends StatefulWidget {
  const NewCoursePage({super.key});

  @override
  State<NewCoursePage> createState() => _NewCoursePageState();
}

class _NewCoursePageState extends State<NewCoursePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Design';
  final List<String> _curriculumItems = [
    'Introduction to Design Systems',
    'Typography and Color Theory',
  ];

  static const _categories = [
    'Design',
    'Development',
    'Business',
    'Marketing',
    'Data Science',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildImageUpload(),
                  const SizedBox(height: 24),
                  _buildField(
                    label: 'Course Title',
                    hint: 'e.g. Advanced UI Design Mastery',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryAndPrice(),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Description',
                    hint:
                        'Briefly describe what students will learn...',
                    controller: _descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  _buildCurriculum(),
                  const SizedBox(height: 32),
                  _buildCreateButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7A5CFF), Color(0xFF9B82FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'lib/assets/BackgroundLogSign.svg',
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 24, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_circle_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'New Course',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D8FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7A5CFF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Color(0xFF7A5CFF), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fill in the information below to start your new learning journey.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A5CFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image picker
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0D8FF),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A5CFF).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  color: Color(0xFF7A5CFF), size: 28),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload Course Image',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A5CFF),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PNG, JPG up to 5MB',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9C9AA5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1B2E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7A5CFF).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB0AEBF),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8E6F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF7A5CFF), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndPrice() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1B2E),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E6F0)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF7A5CFF).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF7A5CFF)),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E1B2E),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(
            label: 'Price (Rp)',
            hint: '1,200,000',
            controller: _priceController,
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Curriculum',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B2E),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _curriculumItems.add('New Module');
                });
              },
              child: const Text(
                '+ Add Module',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A5CFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_curriculumItems.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E6F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A5CFF).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: const Color(0xFF7A5CFF).withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _curriculumItems[index],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E1B2E),
                    ),
                  ),
                ),
                Icon(
                  Icons.more_vert_rounded,
                  color: const Color(0xFF9C9AA5).withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement course creation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Course creation coming soon!'),
              backgroundColor: const Color(0xFF7A5CFF),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A5CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 22),
            SizedBox(width: 8),
            Text(
              'Create Course',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
