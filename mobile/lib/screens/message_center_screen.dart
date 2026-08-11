import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'secure_chat_screen.dart';
import '../services/auth_service.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';
import '../theme/app_theme.dart';

class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({super.key});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  String _activeFilter = 'Toutes';
  String _searchQuery = '';
  Map<String, dynamic>? _user;
  final TextEditingController _searchController = TextEditingController();

  // Role-based conversations
  final List<Map<String, dynamic>> _clientConversations = [
    {
      'name': 'Cabinet CEO-IT',
      'message': 'Nous avons ajouté de nouveaux documents à votre dossier.',
      'time': 'il y a 2h',
      'fallbackInitials': 'CI',
      'unreadCount': 0,
      'isOnline': true,
      'type': 'cabinet',
    },
    {
      'name': 'Sarah Jlassi (Comptable senior)',
      'message': 'Merci de vérifier le calcul TVA du dossier STB.',
      'time': '09:14',
      'fallbackInitials': 'SJ',
      'unreadCount': 2,
      'isOnline': true,
      'type': 'cabinet',
    },
    {
      'name': 'Amira Bouaziz (Responsable fiscal)',
      'message': 'Votre déclaration TVA trimestrielle a été déposée avec succès.',
      'time': 'Hier',
      'fallbackInitials': 'AB',
      'unreadCount': 0,
      'isOnline': false,
      'type': 'cabinet',
    },
  ];

  final List<Map<String, dynamic>> _accountantConversations = [
    {
      'name': 'Société Tunisienne de Bâtiment (STB)',
      'message': 'Justificatif déposé pour l\'achat du 24 mai.',
      'time': '10:15 AM',
      'fallbackInitials': 'STB',
      'unreadCount': 2,
      'isOnline': true,
      'type': 'client',
    },
    {
      'name': 'Le Bon Goût Traiteur',
      'message': 'Pièce manquante — RIB à fournir avant le 20/05.',
      'time': 'Hier',
      'fallbackInitials': 'LBG',
      'unreadCount': 1,
      'isOnline': false,
      'type': 'client',
    },
    {
      'name': 'Alpha Industrie',
      'message': 'Validation du dossier en attente de signature.',
      'time': 'Lundi',
      'fallbackInitials': 'AIN',
      'unreadCount': 0,
      'isOnline': false,
      'type': 'client',
    },
    {
      'name': 'Mehdi Ktari (Comptable)',
      'message': 'Revue de clôture programmée pour demain 14h.',
      'time': 'Jul 26',
      'fallbackInitials': 'MK',
      'unreadCount': 0,
      'isOnline': true,
      'type': 'internal',
    },
  ];

  final List<Map<String, dynamic>> _adminConversations = [
    {
      'name': 'Alerte Sécurité — Kernel AI',
      'message': 'Changement de coordonnées bancaires détecté (Global Printing).',
      'time': '11:20 AM',
      'fallbackInitials': 'SEC',
      'unreadCount': 1,
      'isOnline': true,
      'type': 'security',
    },
    {
      'name': 'Sarah Jlassi (Comptable senior)',
      'message': 'Rapport mensuel de charge d\'équipe finalisé.',
      'time': '09:41 AM',
      'fallbackInitials': 'SJ',
      'unreadCount': 0,
      'isOnline': true,
      'type': 'collaborateur',
    },
    {
      'name': 'Société Générale SARL (Client)',
      'message': 'Demande de rendez-vous pour revue fiscale.',
      'time': 'Hier',
      'fallbackInitials': 'SGS',
      'unreadCount': 0,
      'isOnline': false,
      'type': 'client',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.getUserInfo();
    if (mounted) {
      setState(() {
        _user = u;
      });
    }
  }

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
            'Toutes les correspondances, messages et fichiers déposés sont protégés par un chiffrement de bout en bout conforme aux normes ISO 27001.',
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
                'Compris',
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

  List<Map<String, dynamic>> get _currentRoleConversations {
    final role = (_user?['role'] ?? 'client').toString().toLowerCase();
    if (role == 'admin') return _adminConversations;
    if (role == 'comptable' || role == 'accountant' || role == 'expert_comptable' || role == 'assistant_comptable') {
      return _accountantConversations;
    }
    return _clientConversations;
  }

  List<String> get _currentRoleFilterChips {
    final role = (_user?['role'] ?? 'client').toString().toLowerCase();
    if (role == 'admin') return ['Toutes', 'Collaborateurs', 'Clients', 'Sécurité', 'Non lus'];
    if (role == 'comptable' || role == 'accountant' || role == 'expert_comptable' || role == 'assistant_comptable') {
      return ['Toutes', 'Clients attribués', 'Équipe interne', 'Non lus'];
    }
    return ['Toutes', 'Équipe du cabinet', 'Non lus'];
  }

  List<Map<String, dynamic>> get _filteredConversations {
    List<Map<String, dynamic>> res = _currentRoleConversations;

    // Filter by Chip
    if (_activeFilter == 'Équipe du cabinet' || _activeFilter == 'Équipe interne') {
      res = res.where((c) => c['type'] == 'cabinet' || c['type'] == 'internal').toList();
    } else if (_activeFilter == 'Clients' || _activeFilter == 'Clients attribués') {
      res = res.where((c) => c['type'] == 'client').toList();
    } else if (_activeFilter == 'Sécurité') {
      res = res.where((c) => c['type'] == 'security').toList();
    } else if (_activeFilter == 'Non lus') {
      res = res.where((c) => (c['unreadCount'] as int) > 0).toList();
    }

    // Filter by search query
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
    final role = (_user?['role'] ?? 'client').toString().toLowerCase();
    final isClient = role == 'client';

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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isClient ? 'AB' : 'SJ',
                      style: GoogleFonts.fraunces(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isClient ? 'Échanges avec le cabinet' : 'Messagerie & Échanges',
                    style: GoogleFonts.fraunces(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClient
                        ? 'Vos conversations sécurisées avec vos responsables comptables'
                        : 'Gestion des messages clients et échanges internes',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
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
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une conversation...',
                          hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
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
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: _currentRoleFilterChips.map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildFilterChip(chip),
                  );
                }).toList(),
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
                            'Aucune conversation trouvée',
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
                          delay: Duration(milliseconds: index * 80),
                          child: _buildConversationItem(
                            name: conv['name'],
                            message: conv['message'],
                            time: conv['time'],
                            fallbackInitials: conv['fallbackInitials'],
                            unreadCount: conv['unreadCount'] ?? 0,
                            isOnline: conv['isOnline'] ?? false,
                            onTap: () {
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    fallbackInitials ?? name.substring(0, 2).toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

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
                            fontSize: 15,
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
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
                            color: AppTheme.accentGreen,
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
