import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice.dart';
import '../theme/app_theme.dart';
import '../widgets/heavenly_interaction.dart';

class InvoiceDetailModal extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailModal({super.key, required this.invoice});

  static void show(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailModal(invoice: invoice),
    );
  }

  @override
  State<InvoiceDetailModal> createState() => _InvoiceDetailModalState();
}

class _InvoiceDetailModalState extends State<InvoiceDetailModal> {
  bool _isZoomed = false;
  bool _isExpanded = false;

  void _validateInvoice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.accentGreen),
              const SizedBox(height: 16),
              Text(
                'Invoice Validated',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invoice ${widget.invoice.numero} has been approved successfully.',
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Close modal sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.accentGreen,
            content: Text('Invoice ${widget.invoice.numero} marked as validated.'),
          ),
        );
      }
    });
  }

  void _rejectInvoice() {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Reject Invoice',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please specify the reason for rejecting invoice ${widget.invoice.numero}.',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mismatched total amounts, blurry scanning, wrong IBAN...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final comment = commentController.text.trim();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close sheet modal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.error,
                    content: Text(
                      'Invoice rejected: ${comment.isNotEmpty ? comment : "No comment specification"}',
                      style: GoogleFonts.dmSans(color: Colors.white),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Submit Rejection', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((_) => commentController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    double calculatedRisk = widget.invoice.fraudScore;
    if (calculatedRisk < 0) calculatedRisk = 0;
    if (calculatedRisk <= 1.0 && calculatedRisk > 0.0) {
      calculatedRisk = calculatedRisk * 100.0;
    }
    if (calculatedRisk > 100.0) {
      calculatedRisk = 100.0;
    }
    final double riskScore = calculatedRisk;
    Color riskColor;
    String riskText = 'Low Risk';

    if (riskScore >= 70.0) {
      riskColor = AppTheme.error;
      riskText = 'Critical Risk';
    } else if (riskScore >= 40.0) {
      riskColor = Colors.orange[800]!;
      riskText = 'Medium Risk';
    } else {
      riskColor = AppTheme.accentGreen;
      riskText = 'Low Risk';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: FractionallySizedBox(
        heightFactor: _isExpanded ? 0.98 : 0.9,
        child: Column(
          children: [
            // Grab handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Back button breadcrumb
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Back to Invoices',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${widget.invoice.numero}',
                        style: GoogleFonts.fraunces(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.invoice.fournisseur,
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Verified Vendor',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Risk Assessment Circular Gauge Card
                    _buildRiskGaugeCard(riskScore, riskColor, riskText),
                    const SizedBox(height: 16),

                    // Extracted Fields & Confidence
                    _buildExtractedFieldsCard(),
                    const SizedBox(height: 16),

                    // Fraud Analysis Explanation Card
                    if (riskScore >= 40.0) ...[
                      _buildFraudExplanationCard(riskScore, riskColor),
                      const SizedBox(height: 16),
                    ],

                    // Invoice Visual Scan Card
                    _buildVisualScanCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Buttons
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: HeavenlyInteraction(
                      onTap: _validateInvoice,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Validate Invoice',
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: HeavenlyInteraction(
                      onTap: _rejectInvoice,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.error),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.block, color: AppTheme.error),
                            const SizedBox(width: 8),
                            Text(
                              'Reject with Comment',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskGaugeCard(double score, Color color, String riskText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Text(
            'Risk Assessment',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.surfaceCreamDark,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toInt()}%',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    riskText,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            score >= 40.0
                ? 'High risk anomalies detected in ledger details. Audit verification required.'
                : 'All invoice compliance rules parsed successfully.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXTRACTED FIELDS & CONFIDENCE',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildExtractedRow('Vendor', widget.invoice.fournisseur, '99%', AppTheme.accentGreen.withValues(alpha: 0.15), AppTheme.accentGreen, Icons.check_circle),
          const Divider(height: 24, color: AppTheme.cardBorder),
          _buildExtractedRow('IBAN', widget.invoice.iban.isNotEmpty ? widget.invoice.iban : 'MOCK IBAN FR76...', '65%', Colors.orange[100]!, Colors.orange[850]!, Icons.warning),
          const Divider(height: 24, color: AppTheme.cardBorder),
          _buildExtractedRow('VAT Amount', '${widget.invoice.devise} ${widget.invoice.tva.toStringAsFixed(2)}', '95%', AppTheme.accentGreen.withValues(alpha: 0.15), AppTheme.accentGreen, Icons.check_circle),
          const Divider(height: 24, color: AppTheme.cardBorder),
          _buildExtractedRow('Total HT', '${widget.invoice.devise} ${widget.invoice.montantHt.toStringAsFixed(2)}', '98%', AppTheme.accentGreen.withValues(alpha: 0.15), AppTheme.accentGreen, Icons.check_circle),
          const Divider(height: 24, color: AppTheme.cardBorder),
          _buildExtractedRow('Total TTC', '${widget.invoice.devise} ${widget.invoice.montantTtc.toStringAsFixed(2)}', '99%', AppTheme.accentGreen.withValues(alpha: 0.15), AppTheme.accentGreen, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildExtractedRow(String label, String value, String confidence, Color badgeBg, Color badgeText, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, color: badgeText, size: 14),
              const SizedBox(width: 4),
              Text(
                confidence,
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: badgeText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFraudExplanationCard(double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.policy, color: AppTheme.error, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anomaly Alert Details',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The invoice contains features flagged as unusual (${score.toInt()}% severity score):',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('IBAN mismatch check:', ' Extracted IBAN is not matches with vendor directory records.'),
                const SizedBox(height: 8),
                _buildBulletPoint('OCR confidence alert:', ' Certain characters have medium extraction thresholds (65% on bank credentials).'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String boldPrefix, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
              children: [
                TextSpan(text: boldPrefix, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualScanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceCreamDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INVOICE VISUAL SCAN',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isZoomed ? Icons.zoom_out : Icons.zoom_in,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isZoomed = !_isZoomed;
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.close_fullscreen : Icons.open_in_full,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedScale(
            scale: _isZoomed ? 1.5 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              height: 256,
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: Container(
                  width: 192,
                  height: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 48, height: 16, color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 16),
                          Container(width: double.infinity, height: 8, color: const Color(0xFFF8FAFC)),
                          const SizedBox(height: 6),
                          Container(width: 120, height: 8, color: const Color(0xFFF8FAFC)),
                          const SizedBox(height: 6),
                          Container(width: double.infinity, height: 8, color: const Color(0xFFF8FAFC)),
                          const Spacer(),
                          Container(height: 1, color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 32, height: 8, color: const Color(0xFFF1F5F9)),
                              Container(width: 48, height: 16, color: const Color(0xFFE2E8F0)),
                            ],
                          ),
                        ],
                      ),
                      // Highlights
                      Positioned(
                        top: 96,
                        left: 16,
                        right: 16,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            border: Border.all(color: AppTheme.error, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 16,
                        right: 16,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
