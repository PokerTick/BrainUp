import 'package:flutter/material.dart';
import '../../services/trainer_api_service.dart';

class ManageCoursePage extends StatefulWidget {
  final Map<String, dynamic> course;

  const ManageCoursePage({super.key, required this.course});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late int _courseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseId = widget.course['id'] ?? 0;
    _titleController = TextEditingController(text: widget.course['title'] ?? '');
    _descController = TextEditingController(text: widget.course['description'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    setState(() => _isLoading = true);
    final data = {
      "title": _titleController.text,
      "description": _descController.text,
    };
    
    final result = await TrainerApiService.updateCourse(_courseId, data);
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update course')));
      }
    }
  }

  Future<void> _addSection() async {
    final titleController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Section Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final res = await TrainerApiService.createSection(_courseId, {
                  "title": titleController.text,
                  "order": 1
                });
                Navigator.pop(context, res != null);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Manage Course', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7A5CFF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF7A5CFF)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Course Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5CFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Details'),
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addSection,
                      icon: const Icon(Icons.add, color: Color(0xFF7A5CFF)),
                      label: const Text('Add Section', style: TextStyle(color: Color(0xFF7A5CFF))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Note: APIs for Sections & Lessons are available, but fetching them requires the Course Details API which will be implemented soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                
                // Thumbnail Upload
                const Text('Thumbnail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thumbnail upload API available (PATCH /api/courses/:id/thumbnail)')));
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Thumbnail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7A5CFF),
                    side: const BorderSide(color: Color(0xFF7A5CFF)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
