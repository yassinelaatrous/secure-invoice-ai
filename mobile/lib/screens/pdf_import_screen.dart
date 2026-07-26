import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';
import 'ai_processing_screen.dart';

class PdfImportScreen extends StatefulWidget {
  const PdfImportScreen({super.key});

  @override
  State<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends State<PdfImportScreen> {
  final List<Map<String, dynamic>> _dummyPdfs = [
    {'name': 'facture_ovh_juin_2026.pdf', 'size': '142 KB', 'date': 'Jul 17, 2026', 'status': 'envoyé'},
    {'name': 'uber_receipt_trip_551.pdf', 'size': '54 KB', 'date': 'Jul 15, 2026', 'status': 'envoyé'},
    {'name': 'orange_business_invoice.pdf', 'size': '210 KB', 'date': 'Jul 10, 2026', 'status': 'brouillon'},
  ];

  Future<void> _selectAndUploadPdf() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final fileSizeKb = (result.files.single.size / 1024).toStringAsFixed(0);

        setState(() {
          _dummyPdfs.insert(0, {
            'name': fileName,
            'size': '$fileSizeKb KB',
            'date': 'Jul 17, 2026',
            'status': 'envoyé',
          });
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIProcessingScreen(filePath: filePath),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text('Erreur d\'importation PDF : $e', style: GoogleFonts.dmSans(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Import PDF',
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: HeavenlyInteraction(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: AppTheme.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropzone box simulator
            FadeInSlide(
              delay: const Duration(milliseconds: 50),
              child: HeavenlyInteraction(
                onTap: _selectAndUploadPdf,
                child: CustomPaint(
                  painter: _DashRectPainter(color: AppTheme.textMuted.withValues(alpha: 0.4)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceCreamDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            size: 30,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionner un fichier PDF',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Le document sera automatiquement importé et soumis au traitement OCR.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title list
            FadeInSlide(
              delay: const Duration(milliseconds: 150),
              child: Text(
                'Historique des imports PDF',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // List files with FadeInSlide transitions
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _dummyPdfs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pdf = _dummyPdfs[index];
                  return FadeInSlide(
                    delay: Duration(milliseconds: 200 + (index * 80)),
                    child: _buildPdfListCard(pdf),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfListCard(Map<String, dynamic> pdf) {
    final isAnalyzed = pdf['status'] == 'envoyé';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: AppTheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pdf['name'],
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${pdf['size']} • Importé le ${pdf['date']}',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAnalyzed ? AppTheme.accentGreen.withValues(alpha: 0.1) : AppTheme.surfaceCreamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAnalyzed ? 'Analysé' : 'Brouillon',
              style: GoogleFonts.dmSans(
                color: isAnalyzed ? AppTheme.accentGreen : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashRectPainter extends CustomPainter {
  final double strokeWidth;
  final double gap;
  final Color color;

  _DashRectPainter({
    this.color = Colors.grey,
  }) : gap = 5.0, strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    double x = 0;
    while (x < width) {
      canvas.drawLine(Offset(x, 0), Offset(x + gap, 0), paint);
      canvas.drawLine(Offset(x, height), Offset(x + gap, height), paint);
      x += gap * 2;
    }

    double y = 0;
    while (y < height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + gap), paint);
      canvas.drawLine(Offset(width, y), Offset(width, y + gap), paint);
      y += gap * 2;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
