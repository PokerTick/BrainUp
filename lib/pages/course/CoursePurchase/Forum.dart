import 'package:brainup/ui/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedFilter = 2; // 0=Top, 1=Latest, 2=Oldest

  // Sample forum data
  final List<_CommentData> _comments = [
    _CommentData(
      authorName: 'Takeshi Mushimura',
      avatarPath: 'lib/assets/Takeshi.png',
      text: 'I eat python, I play python, I create Python, I #### python',
      replies: [
        _CommentData(
          authorName: 'Takeshi Mushimura',
          avatarPath: 'lib/assets/Takeshi.png',
          text: "I'm a father of python",
          replies: [],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──
            _buildHeroImage(context),

            // ── Forum Body ──
            Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildTitle(),
                      const SizedBox(height: 16),

                      // Instructor + Category
                      _buildInstructorRow(),
                      const SizedBox(height: 24),

                      // Comment input
                      _buildCommentInput(),
                      const SizedBox(height: 12),

                      // Upload button
                      _buildUploadButton(),
                      const SizedBox(height: 20),

                      // Divider
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                      ),
                      const SizedBox(height: 16),

                      // Filter tabs
                      _buildFilterTabs(),
                      const SizedBox(height: 20),

                      // Comments list
                      ..._comments.map((c) => _buildCommentThread(c, 0)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 2),
    );
  }

  /// Hero image with back button
  Widget _buildHeroImage(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/Coding.png',
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Basic Python for Beginner Level',
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
        height: 1.3,
      ),
    );
  }

  Widget _buildInstructorRow() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6B58E6).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'lib/assets/Takeshi.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Takeshi Mushimura',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A3A4A),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6B58E6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'Basic Programming',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B58E6),
            ),
          ),
        ),
      ],
    );
  }

  /// Comment text field
  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B58E6).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/Takeshi.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 2,
              minLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF3A3A4A),
              ),
              decoration: InputDecoration(
                hintText: 'Write a comment',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Upload button aligned right
  Widget _buildUploadButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Handle comment upload
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B58E6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF6B58E6).withValues(alpha: 0.3),
        ),
        child: Text(
          'Upload',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Top / Latest / Oldest filter tabs
  Widget _buildFilterTabs() {
    final filters = ['Top', 'Latest', 'Oldest'];
    return Row(
      children: List.generate(filters.length, (index) {
        final isActive = _selectedFilter == index;
        return Padding(
          padding: EdgeInsets.only(right: index < filters.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF6B58E6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF6B58E6)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF3A3A4A),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Recursively builds a comment and its replies with indent
  Widget _buildCommentThread(_CommentData comment, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment bubble
          _buildCommentBubble(comment, depth),
          const SizedBox(height: 12),
          // Replies
          ...comment.replies.map((r) => _buildCommentThread(r, depth + 1)),
        ],
      ),
    );
  }

  Widget _buildCommentBubble(_CommentData comment, int depth) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: depth == 0 ? const Color(0xFFF7F7F9) : const Color(0xFFF0EEFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: depth == 0
              ? Colors.grey.shade200
              : const Color(0xFF6B58E6).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6B58E6).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    comment.avatarPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.authorName,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3A3A4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Comment text
          Text(
            comment.text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5A5A6A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Reply button
          GestureDetector(
            onTap: () {
              // TODO: Handle reply
            },
            child: Text(
              'Reply ^',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B58E6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for a comment
class _CommentData {
  final String authorName;
  final String avatarPath;
  final String text;
  final List<_CommentData> replies;

  const _CommentData({
    required this.authorName,
    required this.avatarPath,
    required this.text,
    required this.replies,
  });
}