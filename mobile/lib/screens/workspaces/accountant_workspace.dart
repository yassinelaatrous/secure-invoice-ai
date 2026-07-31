import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification_screen.dart';
import '../invoice_detail_modal.dart';
import '../../models/invoice.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_in_slide.dart';
import '../../widgets/heavenly_interaction.dart';

class AccountantWorkspace extends StatefulWidget {
  const AccountantWorkspace({super.key});

  @override
  State<AccountantWorkspace> createState() => _AccountantWorkspaceState();
}

class _AccountantWorkspaceState extends State<AccountantWorkspace> {
  final TextEditingController _searchController = TextEditingController();

  // State for task checkboxes
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Vérifier relevé bancaire — STB',
      'date': '28/05/2026',
      'priority': 'Urgent',
      'completed': false,
    },
    {
      'title': 'Saisir OD de valeur — Le Bon Goût',
      'date': '29/05/2026',
      'priority': 'À venir',
      'completed': false,
    },
    {
      'title': 'Contrôle TVA — Mai 2026',
      'date': '31/05/2026',
      'priority': 'Urgent',
      'completed': false,
    },
    {
      'title': 'Préparer clôture mensuelle — DGS',
      'date': '02/06/2026',
      'priority': 'Faible',
      'completed': true,
    },
    {
      'title': 'Lettrage comptes clients',
      'date': '03/06/2026',
      'priority': 'À venir',
      'completed': false,
    },
  ];

  // Assigned Client Dossiers
  final List<Map<String, dynamic>> _assignedDossiers = [
    {
      'name': 'Société Tunisienne de Bâtiment',
      'sigle': 'STB',
      'secteur': 'BTP',
      'statut': 'Actif',
      'solde': '2 450 TND',
      'color': const Color(0xFF3B7DDB),
    },
    {
      'name': 'Alpha Distribution',
      'sigle': 'ADI',
      'secteur': 'Négoce',
      'statut': 'Actif',
      'solde': '0 TND',
      'color': const Color(0xFFF4841F),
    },
    {
      'name': 'Le Bon Goût Traiteur',
      'sigle': 'LBG',
      'secteur': 'Restauration',
      'statut': 'En retard',
      'solde': '1 350 TND',
      'color': const Color(0xFFE14B4B),
    },
    {
      'name': 'MedixPlus',
      'sigle': 'MDX',
      'secteur': 'Santé',
      'statut': 'En onboarding',
      'solde': '0 TND',
      'color': const Color(0xFFF0B429),
    },
    {
      'name': 'Digital Solutions',
      'sigle': 'DGS',
      'secteur': 'IT',
      'statut': 'Actif',
      'solde': '3 820 TND',
      'color': const Color(0xFF1E9E6B),
    },
  ];

  // Documents to Verify
  final List<Map<String, dynamic>> _documentsToVerify = [
    {
      'title': 'Facture fournisseur — Office Matériel',
      'client': 'Office Matériel',
      'statut': 'À vérifier',
      'date': '29/05/2026',
      'amount': '2 450 TND',
      'preparedBySelf': true, // SoD simulation: Prepared by self, validation locked
    },
    {
      'title': 'Relevé bancaire — BIAT',
      'client': 'Alpha Distribution',
      'statut': 'Nouveau',
      'date': '29/05/2026',
      'amount': '980 TND',
      'preparedBySelf': false,
    },
    {
      'title': 'Justificatif de paiement',
      'client': 'Best Trade',
      'statut': 'À vérifier',
      'date': '26/05/2026',
      'amount': '3 600 TND',
      'preparedBySelf': false,
    },
    {
      'title': 'Facture fournisseur — Global Printing',
      'client': 'Global Printing',
      'statut': 'Nouveau',
      'date': '26/05/2026',
      'amount': '980 TND',
      'preparedBySelf': false,
    },
  ];

  // Recent Accounting Entries
  final List<Map<String, dynamic>> _accountingEntries = [
    {
      'title': 'STB — Achats de marchandises',
      'date': '28/05/2026',
      'amount': '- 2 450 TND',
      'isExpense': true,
    },
    {
      'title': 'DGS — Règlement fournisseur',
      'date': '27/05/2026',
      'amount': '- 980 TND',
      'isExpense': true,
    },
    {
      'title': 'LBG — Facture client',
      'date': '27/05/2026',
      'amount': '+ 1 350 TND',
      'isExpense': false,
    },
    {
      'title': 'ALPHA — Charges diverses',
      'date': '26/05/2026',
      'amount': '- 3 200 TND',
      'isExpense': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Invoice _buildSampleInvoice(Map<String, dynamic> doc) {
    return Invoice(
      id: 1,
      numero: '2026-F-0134',
      fournisseur: doc['client'] ?? 'Office Matériel',
      dateFacture: DateTime.now(),
      dateReception: DateTime.now(),
      devise: 'TND',
      montantHt: 2000.0,
      tva: 450.0,
      montantTtc: 2450.0,
      iban: 'TN59 1000 6035 1835 9898 3943',
      statut: doc['statut'] ?? 'A vérifier',
      fraudScore: 12.0,
      confidenceScore: 0.98,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Title Banner
              _buildTitleBanner(),
              const SizedBox(height: 24),

              // KPI Row
              FadeInSlide(
                delay: const Duration(milliseconds: 50),
                child: _buildKpiRow(),
              ),
              const SizedBox(height: 24),

              // Main Section: Assigned Dossiers & Documents to Verify
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: _buildDossiersAndDocsSection(),
              ),
              const SizedBox(height: 24),

              // Tasks & Recent Accounting Entries
              FadeInSlide(
                delay: const Duration(milliseconds: 150),
                child: _buildTasksAndEntriesSection(),
              ),
              const SizedBox(height: 24),

              // Workflow & SoD Security Compliance Card
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: _buildWorkflowAndSecuritySection(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentOrange,
            border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            'SJ',
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
              'Espace Collaborateur / Comptable',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentOrange,
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

  // --- Title Banner ---
  Widget _buildTitleBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon espace de travail 👋',
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bonjour Sarah — voici un aperçu de vos activités, dossiers attribués et tâches comptables en cours.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KPI Row ---
  Widget _buildKpiRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.4 : 1.3,
          children: [
            _buildKpiCard('DOSSIERS ATTRIBUÉS', '28', 'Actifs', AppTheme.primary, Icons.folder_outlined),
            _buildKpiCard('DOCUMENTS À VÉRIFIER', '16', 'À contrôler', AppTheme.accentOrange, Icons.description_outlined),
            _buildKpiCard('FACTURES À TRAITER', '12', '18 650 TND', AppTheme.accentGreen, Icons.receipt_long_outlined),
            _buildKpiCard('ÉCHÉANCES À VENIR', '7', '9 480 TND', AppTheme.error, Icons.schedule_outlined),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String label, String value, String subtext, Color color, IconData icon) {
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
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 22,
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

  // --- Assigned Dossiers & Documents to Verify Section ---
  Widget _buildDossiersAndDocsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Dossiers Attribués
        Container(
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
                    'Dossiers attribués',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    'Afficher tous (14)',
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
                itemCount: _assignedDossiers.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.cardBorder),
                itemBuilder: (context, i) {
                  final item = _assignedDossiers[i];
                  final isLate = item['statut'] == 'En retard';
                  return Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (item['color'] as Color).withValues(alpha: 0.15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['sigle'],
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${item['secteur']} • Solde: ${item['solde']}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLate ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['statut'],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLate ? AppTheme.error : AppTheme.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Card 2: Documents à vérifier
        Container(
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
                    'Documents à vérifier',
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    'Voir la liste',
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
                itemCount: _documentsToVerify.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.cardBorder),
                itemBuilder: (context, i) {
                  final doc = _documentsToVerify[i];
                  final isPreparedBySelf = doc['preparedBySelf'] == true;

                  return Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.accentOrange.withValues(alpha: 0.12),
                        ),
                        child: const Icon(Icons.description_outlined, color: AppTheme.accentOrange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['title'],
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${doc['client']} • ${doc['date']}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPreparedBySelf) ...[
                        Tooltip(
                          message: 'SoD Policy: Validation Locked (You prepared this document)',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_outline, size: 12, color: AppTheme.error),
                                const SizedBox(width: 4),
                                Text(
                                  'SoD Locked',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        HeavenlyInteraction(
                          onTap: () {
                            InvoiceDetailModal.show(context, _buildSampleInvoice(doc));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Traiter',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Tasks & Recent Accounting Entries Section ---
  Widget _buildTasksAndEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Tâches assignées
        Container(
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
                'Tâches assignées',
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
                itemCount: _tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 12, color: AppTheme.cardBorder),
                itemBuilder: (context, i) {
                  final task = _tasks[i];
                  final isUrgent = task['priority'] == 'Urgent';
                  return Row(
                    children: [
                      Checkbox(
                        value: task['completed'],
                        activeColor: AppTheme.accentGreen,
                        onChanged: (val) {
                          setState(() {
                            task['completed'] = val;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          task['title'],
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: task['completed'] ? AppTheme.textMuted : AppTheme.textPrimary,
                            decoration: task['completed'] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isUrgent ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task['priority'],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUrgent ? AppTheme.error : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Card 2: Écritures récentes
        Container(
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
                'Écritures comptables récentes',
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
                itemCount: _accountingEntries.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.cardBorder),
                itemBuilder: (context, i) {
                  final entry = _accountingEntries[i];
                  final isExpense = entry['isExpense'] == true;

                  return Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isExpense ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.accentGreen.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isExpense ? AppTheme.error : AppTheme.accentGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'],
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              entry['date'],
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        entry['amount'],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExpense ? AppTheme.error : AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Workflow & Security Section ---
  Widget _buildWorkflowAndSecuritySection() {
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
            'Workflow & Répartition des Dossiers',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressCircle('6', 'Clôturés', AppTheme.accentGreen),
              _buildProgressCircle('14', 'En cours', AppTheme.primary),
              _buildProgressCircle('5', 'En révision', AppTheme.accentOrange),
              _buildProgressCircle('3', 'Collecte', AppTheme.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppTheme.accentGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Politique SoD active: La validation est verrouillée si vous êtes l\'auteur de la pièce.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
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

  Widget _buildProgressCircle(String count, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              style: GoogleFonts.fraunces(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
