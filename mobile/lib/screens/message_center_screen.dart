import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'secure_chat_screen.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';
import '../theme/app_theme.dart';

class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({super.key});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  String _activeFilter = 'All Messages';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allConversations = [
    {
      'name': 'Sarah Jenkins (CFO)',
      'message': 'IBAN mismatch resolved for Q3 invoice.',
      'time': '09:41 AM',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB2P0mz9vcw675nfMW7uxtpn9RvUlVSOx2pldqTVWpy3HRpjS2EThKBcRqvGuh3xScWKuC4XJXwS5l5SmDANo9hiwMIeRqDN2z0Rsfs38PHAO7FWKbkvqSVGZht0ZGQL_BlUJIJ4eFY3v8REB1vgBVIfbnzCuZtTqxRXmFzpS7UJvydIsXQNsg_g0x6qyy8o0hExNP53bKpygkk7TCuczpiq1LR-9I1mORqz7rEYmLVwibztzmIVJ8lc83K6RKdY01PLYrvOO1WHil0',
      'unreadCount': 2,
      'isOnline': true,
      'type': 'internal',
    },
    {
      'name': 'Acme Corp Billing',
      'message': 'The monthly report is ready for your review.',
      'time': 'Yesterday',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7sxzwPFaovqzlZS-lunBcbpV_mgihz4rnYpqvhLTzZkBZFO1nmhKuHEHnMulvdQ0cg_OdY47u3rjLSrMaAnF6MNwEdVvhJtJN-oy4C_wPYlJANY4pGQ-zmdk1pDvKUpLzZmwMJ2hoYlh-NGw-OSukGQsAk4Mpg7WZ160RBUG6pPiyiBme3v2l_lfZKfF63EcbbxvC6BlLhGlj156llP40_4q9sjOg09PdRytXKQ128WmlZRAbdJ9_OFxZUfLLKJvoWyuLw-zEEStL',
      'unreadCount': 0,
      'isOnline': false,
      'type': 'client',
    },
    {
      'name': 'Michael Ross (Legal)',
      'message': 'Contracts have been uploaded to the vault.',
      'time': 'Tue',
      'fallbackInitials': 'MR',
      'unreadCount': 0,
      'isOnline': false,
      'type': 'internal',
    },
    {
      'name': 'Emma Watson (Accountant)',
      'message': 'Please approve the pending wire transfer.',
      'time': 'Jul 12',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCAm-_ET7BeCjf2I3WP-DjiXn8IivggT98x6To9A_aYrewLHtx8nTpQTMkG2QDhaefzxHdSfN4yivrq1cse2yDGSxPVoEfMlJKX8GF0F5Dyd-QOV_wdxZCD55GT9cBudeYACPISPDId_UaZS9qfNMDGkU6R6aDEy9Kn9EUzcfYEwHGanPMPtajzn6ZN5m5BabP9qLK2fBOPAM0aQkMtl9ERHIsleuwgwb_2M5MEYLS6L1O5yqI2rJC3n8RsScTWnlwCMRNHj9Npv2TJ',
      'unreadCount': 0,
      'isOnline': true,
      'type': 'internal',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSecurityDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.security, color: AppTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'End-to-End Encryption',
                style: GoogleFonts.fraunces(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          content: Text(
            'All correspondence, messages, and uploaded files are protected under cryptographic end-to-end encryption. Only authenticated members of your company and designated accountants have keys to decrypt files.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredConversations {
    // 1. Filter by active tab/chip
    List<Map<String, dynamic>> res = _allConversations;
    if (_activeFilter == 'Internal Team') {
      res = res.where((c) => c['type'] == 'internal').toList();
    } else if (_activeFilter == 'Clients') {
      res = res.where((c) => c['type'] == 'client').toList();
    } else if (_activeFilter == 'Unread') {
      res = res.where((c) => (c['unreadCount'] as int) > 0).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.isNotEmpty) {
      res = res.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final message = (c['message'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || message.contains(query);
      }).toList();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredConversations;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceCreamDark,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHer2fd8fIdpC7E46qINZ7zGThzIJaI_HHIoWRrwKb9mGbEVG7bnHZZU4qIyS_pLKUljhePnYl1ZIFKxoMhK8hBZ2wK7Mri3ihQSzwdXd_izZVcZv2xS5HYzRa-Tr6LYvJNLrlQXHeP2_CWJFqvTgZ_vS7G8yh1skVS9UB5NCUY1gQMPzakPlHiWNd4lHHjGY_3aDgl12LM6km7KBp7kFATPw8HcJVUTQ4LEt836cLEfloxfLyixvigsDLRjYmJUbdTDT1kPBdGxFE',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CEO-IT',
                    style: GoogleFonts.fraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  HeavenlyInteraction(
                    onTap: _showSecurityDetails,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.security, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Messages Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Messages',
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search conversation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCreamDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip('All Messages'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Internal Team'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Clients'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations found',
                            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(
                        indent: 24,
                        endIndent: 24,
                        color: AppTheme.cardBorder,
                      ),
                      itemBuilder: (context, index) {
                        final conv = list[index];
                        return FadeInSlide(
                          delay: Duration(milliseconds: index * 100),
                          child: _buildConversationItem(
                            name: conv['name'],
                            message: conv['message'],
                            time: conv['time'],
                            imageUrl: conv['imageUrl'],
                            fallbackInitials: conv['fallbackInitials'],
                            unreadCount: conv['unreadCount'] ?? 0,
                            isOnline: conv['isOnline'] ?? false,
                            onTap: () {
                              // Reset unread count locally when entering the chat
                              setState(() {
                                conv['unreadCount'] = 0;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SecureChatScreen()),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return HeavenlyInteraction(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surfaceCreamDark,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppTheme.cardBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem({
    required String name,
    required String message,
    required String time,
    String? imageUrl,
    String? fallbackInitials,
    int unreadCount = 0,
    bool isOnline = false,
    required VoidCallback onTap,
  }) {
    final isUnread = unreadCount > 0;
    return HeavenlyInteraction(
      onTap: onTap,
      scaleDown: 0.98,
      hoverScale: 1.01,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: imageUrl == null ? AppTheme.surfaceCreamDark : Colors.transparent,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Center(
                          child: Text(
                            fallbackInitials ?? '',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Title, subtitle & badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isUnread ? AppTheme.primary : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            color: isUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadCount.toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
