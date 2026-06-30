import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/trainer_api_service.dart';
import '../../services/api_service.dart';

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
  String _currentStatus = 'DRAFT';
  bool _isLoading = false;
  List<dynamic> _sections = [];

  @override
  void initState() {
    super.initState();
    _courseId = widget.course['id'] ?? 0;
    _currentStatus = widget.course['status'] ?? 'DRAFT';
    _titleController = TextEditingController(text: widget.course['title'] ?? '');
    _descController = TextEditingController(text: widget.course['description'] ?? '');
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getCourseById(_courseId);
    final sections = await TrainerApiService.getCourseSections(_courseId);
    if (mounted) {
      setState(() {
        if (data != null) {
          _currentStatus = data['status'] ?? _currentStatus;
        }
        if (sections != null) {
          _sections = sections;
        } else if (data != null && data['sections'] != null) {
          _sections = data['sections'] as List<dynamic>;
        }
        _isLoading = false;
      });
    }
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Section Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                setState(() => _isLoading = true);
                final res = await TrainerApiService.createSection(_courseId, {
                  "title": titleController.text,
                  "order": _sections.length + 1
                });
                Navigator.pop(context, res);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section added')));
      setState(() {
        _sections.add(result);
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addLesson(int sectionId, int currentLessonsCount) async {
    final titleController = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Lesson Title'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                setState(() => _isLoading = true);
                final res = await TrainerApiService.createLesson(sectionId, {
                  "title": titleController.text,
                  "order": currentLessonsCount + 1,
                  "content": "",
                  "videoUrl": "",
                  "duration": 0
                });
                Navigator.pop(context, res);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson added')));
      setState(() {
        // Find the section and append the lesson
        for (var section in _sections) {
          if (section['id'] == sectionId) {
            final lessons = List<dynamic>.from(section['lessons'] ?? []);
            lessons.add(result);
            section['lessons'] = lessons;
            break;
          }
        }
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCurriculumList() {
    if (_sections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text('No sections yet. Click "Add Section" to begin building your curriculum.', 
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        final section = _sections[index];
        final sectionId = section['id'];
        final sectionTitle = section['title'] ?? 'Untitled Section';
        final lessons = section['lessons'] as List<dynamic>? ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                sectionTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              children: [
                if (lessons.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, lIndex) {
                      final lesson = lessons[lIndex];
                      final lessonTitle = lesson['title'] ?? 'Untitled Lesson';
                      return ListTile(
                        leading: const Icon(Icons.play_circle_outline, color: Color(0xFF7A5CFF)),
                        title: Text(lessonTitle, style: const TextStyle(fontSize: 14)),
                        dense: true,
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _addLesson(sectionId, lessons.length),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Lesson'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7A5CFF),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePublishStatus(bool isPublishing) async {
    setState(() => _isLoading = true);
    final newStatus = isPublishing ? 'PUBLISHED' : 'DRAFT';
    
    final result = await TrainerApiService.updateCourse(_courseId, {"status": newStatus});
    
    if (mounted) {
      if (result != null) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isPublishing ? 'Course is now Live!' : 'Course unpublished.'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = _currentStatus == 'PUBLISHED' || _currentStatus == 'Live';
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
                // Publish Toggle
                Container(
                  decoration: BoxDecoration(
                    color: isLive ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLive ? const Color(0xFF4CAF50) : Colors.grey.shade300),
                  ),
                  child: SwitchListTile(
                    title: const Text('Publish Course', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isLive ? 'Live in Marketplace' : 'Hidden as Draft', 
                      style: TextStyle(color: isLive ? const Color(0xFF4CAF50) : Colors.grey),
                    ),
                    value: isLive,
                    activeColor: const Color(0xFF4CAF50),
                    onChanged: _togglePublishStatus,
                  ),
                ),
                const SizedBox(height: 24),
                
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
                _buildCurriculumList(),
                const SizedBox(height: 32),
                
                // Thumbnail Upload
                const Text('Thumbnail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() => _isLoading = true);
                      final success = await TrainerApiService.uploadCourseThumbnail(_courseId, pickedFile.path);
                      setState(() => _isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success ? 'Thumbnail uploaded successfully' : 'Failed to upload thumbnail'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                      }
                    }
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
