import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification_screen.dart';
import '../../widgets/fade_in_slide.dart';
import '../../widgets/heavenly_interaction.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../invoice_detail_modal.dart';
import '../../models/invoice.dart';

class AdminWorkspace extends StatefulWidget {
  final VoidCallback onScanPressed;

  const AdminWorkspace({super.key, required this.onScanPressed});

  @override
  State<AdminWorkspace> createState() => _AdminWorkspaceState();
}

class _AdminWorkspaceState extends State<AdminWorkspace> {
  String _userName = 'Admin';
  
  final List<Map<String, dynamic>> _activities = [
    {
      'id': 1,
      'fournisseur': 'Global Logistics Inc.',
      'numero': 'INV-2026-004',
      'date': 'Today, 10:24 AM',
      'amount': 1240.00,
      'status': 'validee',
      'icon': Icons.receipt_long,
      'riskScore': 12.0,
    },
    {
      'id': 2,
      'fournisseur': 'Cloud Systems SA',
      'numero': 'INV-2026-003',
      'date': 'Yesterday, 4:45 PM',
      'amount': 842.20,
      'status': 'brouillon',
      'icon': Icons.description,
      'riskScore': 45.0,
    },
    {
      'id': 3,
      'fournisseur': 'Office Supplies Corp',
      'numero': 'INV-2026-002',
      'date': 'Jul 12, 09:12 AM',
      'amount': 156.00,
      'status': 'rejete',
      'icon': Icons.request_quote,
      'riskScore': 85.0,
    },
    {
      'id': 4,
      'fournisseur': 'Apex Tech Solutions',
      'numero': 'INV-2026-001',
      'date': 'Jul 10, 02:30 PM',
      'amount': 4500.00,
      'status': 'controlee',
      'icon': Icons.business,
      'riskScore': 22.0,
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final info = await AuthService.getUserInfo();
    if (info != null && info['nom'] != null) {
      setState(() {
        _userName = info['nom'];
        if (_userName.toUpperCase() == 'ADMIN') {
          _userName = 'Administrator';
        }
      });
    }
  }

  void _showActivityDetail(Map<String, dynamic> act) {
    final invoice = Invoice(
      id: act['id'],
      numero: act['numero'],
      fournisseur: act['fournisseur'],
      dateFacture: DateTime.now().subtract(const Duration(days: 2)),
      dateReception: DateTime.now(),
      devise: 'USD',
      montantHt: act['amount'] * 0.8,
      tva: act['amount'] * 0.2,
      montantTtc: act['amount'],
      iban: 'FR76 3000 6000 0123 4567 8901 234',
      statut: act['status'],
      fraudScore: act['riskScore'] / 100.0,
      confidenceScore: 0.96,
    );
    InvoiceDetailModal.show(context, invoice);
  }

  void _showAllActivities() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Activities',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final act = _activities[index];
                    return HeavenlyInteraction(
                      onTap: () {
                        Navigator.pop(context);
                        _showActivityDetail(act);
                      },
                      child: _buildActivityItemContent(act),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvvHJZhbJ0PcTUfHDjlcANCqwHNCwo6o3QeU5Wmmp4K5owz5g4m8t_PvzIr_-CcsUO1b-IBWs94yf6z8xT3jbJI4Xwkzw69NXtNE2njMg1V7aICuwUMH_IWMRbmsORClZ55Ql2pVE9iQ0vzedkD0AzUX48KooF347aKLSyB3MAN8zfKs4G1GUtu_VjjHl_Ojx55pLwQMbOMMUL0Pf1efNb-arO9BDvF6A8O72iwjS4uIDFBGgUpLql1zRdd3fRKenpMabMHGUsVlWy',
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: AppTheme.textSecondary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting Section
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hello, $_userName',
                      style: GoogleFonts.fraunces(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // KPI Cards Grid (Bento Style)
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Inflow',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGreen,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '\$42,850',
                                style: GoogleFonts.dmSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+12.5%',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Opacity(
                          opacity: 0.05,
                          child: const Icon(
                            Icons.payments,
                            size: 80,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    // Outflow Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outflow',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$12,400',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: 0.45,
                                  backgroundColor: AppTheme.surfaceCreamDark,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pending Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$8,210',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: 0.25,
                                  backgroundColor: AppTheme.surfaceCreamDark,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
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
              const SizedBox(height: 24),

              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cashflow Analytics',
                        style: GoogleFonts.fraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visualizing last 30 days performance',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: _CashflowChart(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeInSlide(
                delay: const Duration(milliseconds: 480),
                child: HeavenlyInteraction(
                  onTap: widget.onScanPressed,
                  scaleDown: 0.96,
                  hoverScale: 1.02,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Scan New Invoice',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recent Activity Header
              FadeInSlide(
                delay: const Duration(milliseconds: 520),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    HeavenlyInteraction(
                      onTap: _showAllActivities,
                      child: Text(
                        'View All',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activities List with Staggered animations
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final act = _activities[index];
                  return FadeInSlide(
                    delay: Duration(milliseconds: 550 + (index * 80)),
                    child: HeavenlyInteraction(
                      onTap: () => _showActivityDetail(act),
                      child: _buildActivityItemContent(act),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItemContent(Map<String, dynamic> act) {
    Color badgeBg;
    Color badgeText;
    String statusStr = 'Pending';
    
    if (act['status'] == 'validee') {
      badgeBg = AppTheme.accentGreen.withValues(alpha: 0.1);
      badgeText = AppTheme.accentGreen;
      statusStr = 'Validated';
    } else if (act['status'] == 'rejete') {
      badgeBg = AppTheme.errorCrimson.withValues(alpha: 0.1);
      badgeText = AppTheme.errorCrimson;
      statusStr = 'Rejected';
    } else {
      badgeBg = AppTheme.surfaceCreamDark;
      badgeText = AppTheme.textSecondary;
      statusStr = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCreamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(act['icon'] as IconData, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act['fournisseur'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  act['date'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(act['amount'] as double).toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  statusStr,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CashflowChart extends StatefulWidget {
  const _CashflowChart();

  @override
  State<_CashflowChart> createState() => _CashflowChartState();
}

class _CashflowChartState extends State<_CashflowChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _tappedBarIndex;

  final List<double> _chartValues = [4200, 6800, 8500, 12750, 3900, 2200, 4500];
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double maxVal = 15000.0;
    const double chartMaxHeight = 110.0;

    return Stack(
      children: [
        // Y-axis and Grid lines
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final val = ((3 - index) * 5).toString();
            return Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    '\$${val}k',
                    style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 8),
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: Colors.white10,
                  ),
                ),
              ],
            );
          }),
        ),

        // Tooltip Overlay
        if (_tappedBarIndex != null)
          Positioned(
            top: 2,
            left: 50,
            right: 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_days[_tappedBarIndex!]}: \$${_chartValues[_tappedBarIndex!].toInt()} Inflow',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),

        // Bars & X-Axis Labels
        Positioned.fill(
          left: 34,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_chartValues.length, (index) {
                  final rawHeight = (_chartValues[index] / maxVal) * chartMaxHeight;
                  final height = rawHeight * _animation.value;
                  final isTapped = _tappedBarIndex == index;

                  return GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _tappedBarIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: height.clamp(4.0, chartMaxHeight),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isTapped ? AppTheme.accent : AppTheme.accent.withValues(alpha: 0.9),
                                AppTheme.accent.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                            boxShadow: isTapped
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accent.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _days[index],
                          style: GoogleFonts.dmSans(
                            color: isTapped ? Colors.white : Colors.white54,
                            fontSize: 9,
                            fontWeight: isTapped ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
