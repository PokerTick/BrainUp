import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../ui/bottomnavigation.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Message {
  final String senderName;
  final String preview;
  final String time;
  final Color avatarColor;
  final bool isGroup;
  final bool unread;

  const _Message({
    required this.senderName,
    required this.preview,
    required this.time,
    required this.avatarColor,
    this.isGroup = false,
    this.unread = false,
  });
}

// ─── Page ────────────────────────────────────────────────────────────────────

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  static const _tabs = ['All', 'Groups', 'Archived'];

  static const _messages = [
    _Message(
      senderName: 'Sarah Jenkins',
      preview: 'Can you explain the React Hook...',
      time: '2:45 PM',
      avatarColor: Color(0xFFFFB6D9),
      unread: true,
    ),
    _Message(
      senderName: 'Alex Rivera',
      preview: 'I\'ve submitted the advanced cl...',
      time: '1:30 PM',
      avatarColor: Color(0xFF82B1FF),
    ),
    _Message(
      senderName: 'Mei Lin',
      preview: 'Hi! My students are working pretty well. Thanks!',
      time: 'Yesterday',
      avatarColor: Color(0xFFA5D6A7),
    ),
    _Message(
      senderName: 'David Kim',
      preview: 'Is there a weekend session for this...',
      time: '09:34',
      avatarColor: Color(0xFFFFCC80),
    ),
    _Message(
      senderName: 'Fullstack Group B',
      preview: 'Jordan: Just joined the class!',
      time: '05:23',
      avatarColor: Color(0xFFCE93D8),
      isGroup: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      bottomNavigationBar: const AppBottomNavigationBar(initialIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF7A5CFF),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildFilterTabs(),
                  const SizedBox(height: 20),
                  ..._messages.map((m) => _buildMessageCard(m)),
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
                      child: const Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Messages',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '5 unread messages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A5CFF).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students or messages...',
          hintStyle: const TextStyle(
            color: Color(0xFFB0AEBF),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF7A5CFF), size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final isActive = index == _selectedTab;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF7A5CFF) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF7A5CFF)
                      : const Color(0xFFE8E6F0),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF9C9AA5),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMessageCard(_Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: message.unread
            ? const Color(0xFFF5F2FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: message.avatarColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: message.isGroup
                  ? Icon(Icons.group_rounded,
                      color: message.avatarColor, size: 22)
                  : Text(
                      message.senderName[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: message.avatarColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: message.unread
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: const Color(0xFF1E1B2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: message.unread
                            ? const Color(0xFF7A5CFF)
                            : const Color(0xFF9C9AA5),
                        fontWeight: message.unread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.preview,
                  style: TextStyle(
                    fontSize: 13,
                    color: message.unread
                        ? const Color(0xFF5A5869)
                        : const Color(0xFF9C9AA5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (message.unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF7A5CFF),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
