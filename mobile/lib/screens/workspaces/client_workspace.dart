import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/fade_in_slide.dart';
import '../../widgets/heavenly_interaction.dart';
import '../../theme/app_theme.dart';
import '../secure_chat_screen.dart';
import '../notification_screen.dart';

class ClientWorkspace extends StatefulWidget {
  const ClientWorkspace({super.key});

  @override
  State<ClientWorkspace> createState() => _ClientWorkspaceState();
}

class _ClientWorkspaceState extends State<ClientWorkspace> {
  String? _selectedFileName;
  bool _idUploaded = false;
  bool _invoiceReplaced = false;

  // Client Invoices list (Espace Client)
  final List<Map<String, dynamic>> _clientInvoices = [
    {
      'num': '2026-F-0134',
      'date': '15/05/2026',
      'montant': '2 450 TND',
      'statut': 'Impayée',
      'isOverdue': false,
    },
    {
      'num': '2026-F-0132',
      'date': '12/05/2026',
      'montant': '1 350 TND',
      'statut': 'En retard',
      'isOverdue': true,
    },
    {
      'num': '2026-F-0131',
      'date': '10/05/2026',
      'montant': '3 820 TND',
      'statut': 'Payée',
      'isOverdue': false,
    },
    {
      'num': '2026-F-0128',
      'date': '02/05/2026',
      'montant': '4 800 TND',
      'statut': 'Payée',
      'isOverdue': false,
    },
  ];

  // Client Deadlines
  final List<Map<String, dynamic>> _clientDeadlines = [
    {
      'label': 'Déclaration TVA — Mai 2026',
      'date': '12/06/2026',
      'montant': '950 TND',
      'statut': 'À venir',
      'isUrgent': false,
    },
    {
      'label': 'Paiement fournisseur — Office Matériel',
      'date': '04/06/2026',
      'montant': '2 450 TND',
      'statut': 'Urgent',
      'isUrgent': true,
    },
    {
      'label': 'Cotisation CNSS — T2 2026',
      'date': '15/06/2026',
      'montant': '1 800 TND',
      'statut': 'À venir',
      'isUrgent': false,
    },
  ];

  void _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text(
            'Document transmis au cabinet : $_selectedFileName',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _bookMeeting() {
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
                'Prendre rendez-vous avec votre comptable',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez un créneau disponible pour échanger avec Sarah Jlassi.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeSlot(context, '10:00 AM'),
                  _buildTimeSlot(context, '02:30 PM'),
                  _buildTimeSlot(context, '04:00 PM'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: HeavenlyInteraction(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.accentGreen,
                        content: Text(
                          'Demande de rendez-vous envoyée ! Sarah vous confirmera sous peu.',
                          style: GoogleFonts.dmSans(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Confirmer la demande',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlot(BuildContext context, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Text(
        time,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progressRatio = 0.75;
    if (_invoiceReplaced) progressRatio += 0.12;
    if (_idUploaded) progressRatio += 0.13;
    if (progressRatio > 1.0) progressRatio = 1.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Welcome Banner
              _buildWelcomeBanner(),
              const SizedBox(height: 20),

              // KPI Summary Cards
              FadeInSlide(
                delay: const Duration(milliseconds: 50),
                child: _buildKpiCards(),
              ),
              const SizedBox(height: 20),

              // Dossier Status & Step History Card
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: _buildDossierProgressCard(progressRatio),
              ),
              const SizedBox(height: 20),

              // Document Upload Dropzone
              FadeInSlide(
                delay: const Duration(milliseconds: 150),
                child: _buildUploadCard(),
              ),
              const SizedBox(height: 20),

              // Factures & Invoices Section
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: _buildInvoicesCard(),
              ),
              const SizedBox(height: 20),

              // Échéances & Deadlines Section
              FadeInSlide(
                delay: const Duration(milliseconds: 250),
                child: _buildDeadlinesCard(),
              ),
              const SizedBox(height: 20),

              // Expected Documents & Assigned Accountant Card
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _buildAccountantAndExpectedDocsCard(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary,
            border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            'AB',
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CEO-IT',
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            Text(
              'Espace Client — Société Générale SARL',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }

  // --- Welcome Banner ---
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, Ahmed 👋',
            style: GoogleFonts.fraunces(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bienvenue dans votre espace client CEO-IT. Suivez l\'avancement de vos dossiers et consultez vos factures en toute sécurité.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- Client KPI Summary Cards ---
  Widget _buildKpiCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildKpiTile('DOCUMENTS', '28', '+3 cette semaine', AppTheme.primary, Icons.description_outlined),
        _buildKpiTile('FACTURES IMPAYÉES', '2', '1 250 TND en attente', AppTheme.error, Icons.receipt_long_outlined),
        _buildKpiTile('PROCHAINE ÉCHÉANCE', '12 juin', 'TVA — 950 TND', AppTheme.warning, Icons.calendar_today_outlined),
        _buildKpiTile('MESSAGES NON LUS', '2', 'Cabinet CEO-IT', AppTheme.accentGreen, Icons.chat_bubble_outline),
      ],
    );
  }

  Widget _buildKpiTile(String label, String value, String subtext, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          Text(
            subtext,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- Dossier Progress & Step History Card ---
  Widget _buildDossierProgressCard(double progressRatio) {
    final percentInt = (progressRatio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avancement du dossier',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentInt%',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Clôture exercice 2025 — Étape actuelle : contrôle de conformité par le cabinet',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: AppTheme.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
            ),
          ),
          const SizedBox(height: 16),

          // Status Badges
          Row(
            children: [
              _buildStatusChip('Collecte terminée', AppTheme.accentGreen, true),
              const SizedBox(width: 8),
              _buildStatusChip('En révision', AppTheme.warning, true),
              const SizedBox(width: 8),
              _buildStatusChip('Clôture à venir', AppTheme.textMuted, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.12) : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? color : AppTheme.textMuted,
        ),
      ),
    );
  }

  // --- Upload Card ---
  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Déposer un document',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transmettez vos factures, pièces justificatives ou relevés au cabinet.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 46,
            child: HeavenlyInteraction(
              onTap: _selectFile,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sélectionner un fichier (PDF, JPG, PNG)',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Factures & Invoices Card ---
  Widget _buildInvoicesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dernières factures ébauchées / émanées',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'Tout voir',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _clientInvoices.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.cardBorder),
            itemBuilder: (context, i) {
              final inv = _clientInvoices[i];
              final isOverdue = inv['isOverdue'] == true;
              final isPaid = inv['statut'] == 'Payée';

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isPaid
                          ? AppTheme.accentGreen.withValues(alpha: 0.1)
                          : isOverdue
                              ? AppTheme.error.withValues(alpha: 0.1)
                              : AppTheme.warning.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: isPaid
                          ? AppTheme.accentGreen
                          : isOverdue
                              ? AppTheme.error
                              : AppTheme.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv['num'],
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          inv['date'],
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        inv['montant'],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? AppTheme.accentGreen.withValues(alpha: 0.12)
                              : isOverdue
                                  ? AppTheme.error.withValues(alpha: 0.12)
                                  : AppTheme.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          inv['statut'],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? AppTheme.accentGreen
                                : isOverdue
                                    ? AppTheme.error
                                    : AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Deadlines Card ---
  Widget _buildDeadlinesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaines échéances',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _clientDeadlines.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.cardBorder),
            itemBuilder: (context, i) {
              final d = _clientDeadlines[i];
              final isUrgent = d['isUrgent'] == true;

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isUrgent ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.warning.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.schedule_outlined,
                      color: isUrgent ? AppTheme.error : AppTheme.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['label'],
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Échéance: ${d['date']}',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    d['montant'],
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? AppTheme.error : AppTheme.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Accountant & Expected Documents Card ---
  Widget _buildAccountantAndExpectedDocsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre responsable comptable',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  'SJ',
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah Jlassi',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    'Comptable senior · Cabinet CEO-IT',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HeavenlyInteraction(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecureChatScreen()),
                    );
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Contacter le cabinet',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HeavenlyInteraction(
                  onTap: _bookMeeting,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Prendre RDV',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
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
