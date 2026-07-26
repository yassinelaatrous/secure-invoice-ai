import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../notification_screen.dart';
import '../invoice_detail_modal.dart';
import '../secure_chat_screen.dart';
import '../../models/invoice.dart';
import '../../widgets/fade_in_slide.dart';
import '../../widgets/heavenly_interaction.dart';

class AccountantWorkspace extends StatefulWidget {
  const AccountantWorkspace({super.key});

  @override
  State<AccountantWorkspace> createState() => _AccountantWorkspaceState();
}

class _AccountantWorkspaceState extends State<AccountantWorkspace> {
  // --- Controllers ---
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // --- State ---
  String _searchQuery = '';

  // Validation queue item statuses (index → badge info)
  final List<Map<String, dynamic>> _queueItems = [
    {
      'id': 'INV-2026-089',
      'subtitle': 'TechFlow Solutions Inc. • Uploaded 2h ago',
      'icon': Icons.description,
      'badgeText': 'Missing Info',
      'badgeBgColor': const Color(0xFFFFDAD6),
      'badgeTextColor': const Color(0xFFA4161A),
      'isApproveBtn': false,
      'supplier': 'TechFlow Solutions',
    },
    {
      'id': 'EXP-004-JUL',
      'subtitle': 'Acme Corp • Uploaded 4h ago',
      'icon': Icons.receipt_long,
      'badgeText': 'Pending AI Match',
      'badgeBgColor': const Color(0xFFEAE8E5),
      'badgeTextColor': const Color(0xFF414844),
      'isApproveBtn': false,
      'supplier': 'Acme Corp',
    },
    {
      'id': 'INV-2026-090',
      'subtitle': 'Global Logistics • Uploaded 5h ago',
      'icon': Icons.description,
      'badgeText': 'Ready for Approval',
      'badgeBgColor': Color(0xFFB7E4C7).withValues(alpha: 0.3),
      'badgeTextColor': const Color(0xFF0E6C4A),
      'isApproveBtn': true,
      'supplier': 'Global Logistics',
    },
  ];

  // Assigned clients
  final List<Map<String, dynamic>> _allClients = [
    {
      'initial': 'A',
      'name': 'Acme Corp',
      'foldersText': '12 Active Folders',
      'badgeText': 'Action Required',
      'badgeBgColor': const Color(0xFFFFDAD6),
      'badgeTextColor': const Color(0xFFA4161A),
      'avatarBgColor': const Color(0xFF1B4332),
    },
    {
      'initial': 'T',
      'name': 'TechFlow Solutions',
      'foldersText': '5 Active Folders',
      'badgeText': 'Up to date',
      'badgeBgColor': const Color(0xFFEAE8E5),
      'badgeTextColor': const Color(0xFF414844),
      'avatarBgColor': const Color(0xFF0E6C4A),
    },
  ];

  // Collaboration notes
  final List<Map<String, dynamic>> _collaborationNotes = [];

  List<Map<String, dynamic>> get _filteredClients {
    if (_searchQuery.isEmpty) return _allClients;
    return _allClients
        .where((c) => (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- Mock Invoice factory ---
  Invoice _mockInvoice({String? numero, String? fournisseur, double? montant}) {
    return Invoice(
      id: 1,
      numero: numero ?? 'INV-2026-089',
      fournisseur: fournisseur ?? 'TechFlow Solutions',
      dateFacture: DateTime.now(),
      dateReception: DateTime.now(),
      devise: 'EUR',
      montantHt: (montant ?? 2450.00) * 0.8,
      tva: (montant ?? 2450.00) * 0.2,
      montantTtc: montant ?? 2450.00,
      iban: 'FR76 3000 6000 0112 3456 7890 189',
      statut: 'pending',
      fraudScore: 25.0,
      confidenceScore: 0.95,
    );
  }

  // --- Actions ---
  void _showViewAllSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E2DF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Queue Items',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF012D1D),
                    ),
                  ),
                  HeavenlyInteraction(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Color(0xFF414844)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E2DF)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: _queueItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E2DF)),
                itemBuilder: (_, i) => _buildQueueItem(i, inSheet: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInvoiceDetail(int queueIndex) {
    final item = _queueItems[queueIndex];
    InvoiceDetailModal.show(
      context,
      _mockInvoice(
        numero: item['id'] as String,
        fournisseur: item['supplier'] as String,
      ),
    );
  }

  void _approveItem(int queueIndex) {
    setState(() {
      _queueItems[queueIndex]['badgeText'] = 'Approved';
      _queueItems[queueIndex]['badgeBgColor'] = const Color(0xFFB7E4C7);
      _queueItems[queueIndex]['badgeTextColor'] = const Color(0xFF0E6C4A);
      _queueItems[queueIndex]['isApproveBtn'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_queueItems[queueIndex]['id']} approved successfully',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: const Color(0xFF0E6C4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecureChatScreen()),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attached: ${result.files.first.name}',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: const Color(0xFF012D1D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _postNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _collaborationNotes.insert(0, {
        'author': 'Me',
        'text': text,
        'time': TimeOfDay.now().format(context),
      });
    });
    _noteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note posted', style: GoogleFonts.dmSans()),
        backgroundColor: const Color(0xFF0E6C4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =======================================================================
  // BUILD
  // =======================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6), // bg-background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Title Section
              _buildTitleSection(),
              const SizedBox(height: 24),

              // KPIs Grid — delay 100ms
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: _buildKpiGrid(),
              ),
              const SizedBox(height: 24),

              // Validation Queue — delay 200ms
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: _buildValidationQueue(),
              ),
              const SizedBox(height: 24),

              // Assigned Clients — delay 300ms
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _buildAssignedClients(),
              ),
              const SizedBox(height: 24),

              // Collaboration Feed — delay 400ms
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: _buildCollaborationFeed(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================================
  // HEADER
  // =======================================================================
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF012D1D).withValues(alpha: 0.1), width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCG3KdJDVrmQn-8uV8v31fD0K1oQBJi6bMPa8L9Q37tpFf0r-_cnqiOEEWoh7TgT4dLV_K5UfNWpXKthit3nDA3rEqtAxp2qAG7V8nxjY7Ovuu9kICDyA23wm7FMuyIUwd74mItigQsTtDYDvWum2J2bvs7IG_W5eCv6x_Dmu1IcBrIPC-TonpAT1VTC320hptA858gYIEFQRhrs0zShfgyhTTAkLGK_OdTf21hgpic8Vi_xpcyA94A3apsGnSkMNYnynlh9iJrH4ZD',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'CEO-IT',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF012D1D),
            letterSpacing: -0.01 * 20,
          ),
        ),
        const Spacer(),
        HeavenlyInteraction(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.notifications, color: Color(0xFF414844)),
          ),
        ),
      ],
    );
  }

  // =======================================================================
  // TITLE SECTION
  // =======================================================================
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accountant Workspace',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF012D1D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review pending documents, manage client tasks, and monitor processing KPIs.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF414844),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // =======================================================================
  // KPI GRID (animated counters)
  // =======================================================================
  Widget _buildKpiGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildKpiCard('PENDING INVOICES', 42,
            trendText: '+5 today', trendColor: const Color(0xFFA4161A), isTrendUp: true),
        _buildKpiCard('PROCESSING TIME', 1.2,
            suffix: ' hrs', trendText: '-0.3 hrs', trendColor: const Color(0xFF0E6C4A), isTrendUp: false),
        _buildKpiCard('ACCURACY RATE', 99.4,
            suffix: '%', isPercentage: true),
        _buildKpiCard('URGENT CLIENT MSGS', 3, isUrgent: true),
      ],
    );
  }

  Widget _buildKpiCard(String label, num targetValue, {
    String? suffix,
    String? trendText,
    Color? trendColor,
    bool? isTrendUp,
    bool isPercentage = false,
    bool isUrgent = false,
  }) {
    final isDecimal = targetValue is double;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1C1B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF414844),
              letterSpacing: 0.03 * 11,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Animated counter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: targetValue.toDouble()),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  String display;
                  if (isDecimal) {
                    display = val.toStringAsFixed(1);
                  } else {
                    display = val.toInt().toString();
                  }
                  if (suffix != null) display += suffix;
                  return Text(
                    display,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isUrgent ? const Color(0xFFA4161A) : const Color(0xFF012D1D),
                    ),
                  );
                },
              ),
              if (trendText != null) ...[
                const SizedBox(width: 4),
                Row(
                  children: [
                    Icon(
                      isTrendUp! ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trendText,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // VALIDATION QUEUE
  // =======================================================================
  Widget _buildValidationQueue() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Validation Queue',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF012D1D),
                  ),
                ),
                HeavenlyInteraction(
                  onTap: _showViewAllSheet,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0E6C4A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Color(0xFF0E6C4A), size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E2DF)),
          for (int i = 0; i < _queueItems.length; i++) ...[
            _buildQueueItem(i),
            if (i < _queueItems.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E2DF)),
          ],
        ],
      ),
    );
  }

  Widget _buildQueueItem(int index, {bool inSheet = false}) {
    final item = _queueItems[index];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item['icon'] as IconData, color: const Color(0xFF717973)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['id'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF012D1D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item['badgeBgColor'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['badgeText'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: item['badgeTextColor'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF414844),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          (item['isApproveBtn'] as bool)
              ? HeavenlyInteraction(
                  onTap: () => _approveItem(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6C4A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : HeavenlyInteraction(
                  onTap: () => _openInvoiceDetail(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF717973)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Review',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1A),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // =======================================================================
  // ASSIGNED CLIENTS
  // =======================================================================
  Widget _buildAssignedClients() {
    final clients = _filteredClients;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Clients',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF012D1D),
                  ),
                ),
                // Functional search field
                Container(
                  width: 150,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 16, color: Color(0xFF717973)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search clients...',
                            hintStyle: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF717973)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF012D1D)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E2DF)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: clients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No clients match your search.',
                        style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF717973)),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      for (int i = 0; i < clients.length; i++) ...[
                        Expanded(
                          child: _buildClientCard(
                            clients[i]['initial'] as String,
                            clients[i]['name'] as String,
                            clients[i]['foldersText'] as String,
                            clients[i]['badgeText'] as String,
                            clients[i]['badgeBgColor'] as Color,
                            clients[i]['badgeTextColor'] as Color,
                            clients[i]['avatarBgColor'] as Color,
                          ),
                        ),
                        if (i < clients.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(
    String initial,
    String name,
    String foldersText,
    String badgeText,
    Color badgeBgColor,
    Color badgeTextColor,
    Color avatarBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarBgColor,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF012D1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  foldersText,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF414844),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // COLLABORATION FEED
  // =======================================================================
  Widget _buildCollaborationFeed() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE9), // surface-cream-dark
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collaboration Feed',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF012D1D),
                ),
              ),
              const Icon(Icons.forum, color: Color(0xFF414844), size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamically posted notes (newest first, above pinned)
          for (final note in _collaborationNotes) ...[
            _buildDynamicNote(note),
            const SizedBox(height: 12),
          ],

          // Note 1 Pinned
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E2DF)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF012D1D),
                          ),
                          child: Center(
                            child: Text(
                              'ME',
                              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Internal Note (TechFlow)',
                          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Awaiting updated W-9 before processing INV-2026-089.',
                      style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF414844)),
                    ),
                  ],
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.push_pin, color: Color(0xFF0E6C4A), size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Message with Reply
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E2DF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE5E2DF),
                          ),
                          child: const Icon(Icons.person, size: 14, color: Color(0xFF414844)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Client: Acme Corp',
                          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                        ),
                      ],
                    ),
                    Text(
                      '10:42 AM',
                      style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF717973)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We uploaded the missing receipts for July.',
                  style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF414844)),
                ),
                const SizedBox(height: 8),
                HeavenlyInteraction(
                  onTap: _navigateToChat,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reply',
                        style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0E6C4A)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.reply, size: 12, color: Color(0xFF0E6C4A)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Input area
          Text(
            'New Internal Note / Message',
            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF414844)),
          ),
          const SizedBox(height: 6),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E2DF)),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type here...',
                hintStyle: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF717973)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF012D1D)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              HeavenlyInteraction(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC1C8C2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Attach', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C1A))),
                ),
              ),
              const SizedBox(width: 8),
              HeavenlyInteraction(
                onTap: _postNote,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF012D1D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Post', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Renders a dynamically-posted collaboration note.
  Widget _buildDynamicNote(Map<String, dynamic> note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF012D1D),
                    ),
                    child: Center(
                      child: Text(
                        'ME',
                        style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Internal Note',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF012D1D)),
                  ),
                ],
              ),
              Text(
                note['time'] as String,
                style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF717973)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note['text'] as String,
            style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF414844)),
          ),
        ],
      ),
    );
  }
}
