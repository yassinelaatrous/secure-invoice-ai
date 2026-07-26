import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';
import 'ai_processing_screen.dart';
import 'notification_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'Invoice';
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _processFile(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIProcessingScreen(filePath: path),
      ),
    );
  }

  Future<void> _handleCameraCapture() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file != null) {
      _processFile(file.path);
    }
  }

  Future<void> _handleGalleryPick() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null) {
      _processFile(file.path);
    }
  }

  Future<void> _handlePdfImport() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      _processFile(result.files.single.path!);
    }
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
              FadeInSlide(
                delay: Duration.zero,
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
              ),
              const SizedBox(height: 24),

              // Category Selector
              FadeInSlide(
                delay: const Duration(milliseconds: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOCUMENT CATEGORY',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          _buildCategorySegment('Invoice'),
                          _buildCategorySegment('Receipt'),
                          _buildCategorySegment('Contract'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Viewfinder Section
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C1B),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Simulated Camera Feed Image
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAtFVZHcCfbUX_cLuNW_u73w_EWH9uGjCHjGh4dTZgismgQ4-bSTw_BlMiT43u8hT5umsdM8ENp5ZzPirgkgpXTtx9m4Ct-aVh39Kaiu6ImEQZ26R7olbMducYfs0_6OHRrtalKnUjACmef62-d7VOqYpleZZBlD5jUvqUssqE-GMkv_qqLW7GELaxh7Wipd0_hgUZFmahKETH_rin5ZNOLLmuKatfmJrjjYbfpS8YbX9TsnLYHUHTQIZkJGenp6pR0YIn4XCfYzk1c',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Scanning Frame UI
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Stack(
                              children: [
                                // Border
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.accentGreen.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),

                                // Scanning Line Animation with height constraint bug fixed (constant 280)
                                AnimatedBuilder(
                                  animation: _scanAnimation,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: _scanAnimation.value * 280.0,
                                      left: 0,
                                      right: 0,
                                      child: Opacity(
                                        opacity: _scanAnimation.value < 0.05 || _scanAnimation.value > 0.95 ? 0.0 : 1.0,
                                        child: Container(
                                          height: 2.5,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                AppTheme.accent.withValues(alpha: 0.8),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Corner Accents
                                _buildCornerMarker(top: 0, left: 0),
                                _buildCornerMarker(top: 0, right: 0),
                                _buildCornerMarker(bottom: 0, left: 0),
                                _buildCornerMarker(bottom: 0, right: 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Capture Controls
              FadeInSlide(
                delay: const Duration(milliseconds: 150),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: HeavenlyInteraction(
                          onTap: _handleCameraCapture,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.center_focus_strong, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'TAKE PHOTO',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: HeavenlyInteraction(
                          onTap: _handlePdfImport,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCreamDark,
                              border: Border.all(color: AppTheme.cardBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file, color: AppTheme.textPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  'UPLOAD PDF',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 0.6,
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
              ),
              const SizedBox(height: 16),

              // Select from Gallery Button (Correct label)
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: HeavenlyInteraction(
                  onTap: _handleGalleryPick,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library, color: AppTheme.accentGreen, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Select from Gallery',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Drag & Drop Area with cream opacity
              FadeInSlide(
                delay: const Duration(milliseconds: 250),
                child: HeavenlyInteraction(
                  onTap: _handleGalleryPick,
                  child: CustomPaint(
                    painter: _DashRectPainter(color: AppTheme.textMuted.withValues(alpha: 0.4)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_upload, color: AppTheme.textMuted, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to browse files here',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supports PDF, JPG, PNG up to 10MB',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Capture Tips Card
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: AppTheme.accentGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Smart Capture Tips',
                            style: GoogleFonts.fraunces(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTipRow(Icons.brightness_high, 'Ensure bright, even lighting to avoid shadows on text.'),
                      const SizedBox(height: 12),
                      _buildTipRow(Icons.align_horizontal_center, 'Keep the document flat and centered within the frame.'),
                      const SizedBox(height: 12),
                      _buildTipRow(
                        Icons.document_scanner,
                        'OCR Quality Detection active',
                        subtext: 'The AI will automatically enhance low-contrast documents for better extraction.',
                        isBoldHeader: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySegment(String label) {
    final isSelected = _selectedCategory == label;
    return Expanded(
      child: HeavenlyInteraction(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarker({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? BorderSide(color: AppTheme.accentGreen, width: 4) : BorderSide.none,
            bottom: bottom != null ? BorderSide(color: AppTheme.accentGreen, width: 4) : BorderSide.none,
            left: left != null ? BorderSide(color: AppTheme.accentGreen, width: 4) : BorderSide.none,
            right: right != null ? BorderSide(color: AppTheme.accentGreen, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text, {String? subtext, bool isBoldHeader = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isBoldHeader ? FontWeight.bold : FontWeight.normal,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
