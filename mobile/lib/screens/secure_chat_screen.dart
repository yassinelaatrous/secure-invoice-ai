import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'invoice_detail_modal.dart';
import '../models/invoice.dart';
import '../widgets/fade_in_slide.dart';
import '../theme/app_theme.dart';
import '../widgets/heavenly_interaction.dart';

class SecureChatScreen extends StatefulWidget {
  const SecureChatScreen({super.key});

  @override
  State<SecureChatScreen> createState() => _SecureChatScreenState();
}

class _SecureChatScreenState extends State<SecureChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _chatMessages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'isMe': true,
        'text': text,
        'time': 'Just now',
        'hasDoc': false,
        'statusIcon': Icons.done,
        'statusColor': AppTheme.textMuted,
      });
    });
    _messageController.clear();
    _scrollToBottom();

    // Trigger mock auto-reply after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        // Update previous message status to double checkmark
        for (var msg in _chatMessages) {
          if (msg['isMe'] == true && msg['time'] == 'Just now') {
            msg['statusIcon'] = Icons.done_all;
            msg['statusColor'] = AppTheme.accent;
          }
        }
        _chatMessages.add({
          'isMe': false,
          'text': 'Perfect, thank you! I\'ve logged the licensing classification and updated the status to verified. Let me know if you upload anything else.',
          'time': 'Just now',
          'hasDoc': false,
        });
      });
      _scrollToBottom();
    });
  }

  void _showMockDocument() {
    final mockInvoice = Invoice(
      id: 89,
      numero: 'INV-2023-089',
      fournisseur: 'Apex Tech Solutions',
      dateFacture: DateTime.now().subtract(const Duration(days: 5)),
      dateReception: DateTime.now(),
      devise: 'USD',
      montantHt: 10375.0,
      tva: 2075.0,
      montantTtc: 12450.0,
      iban: 'IE 45 BKRY 9001 2345 6789 01',
      statut: 'nouveau',
      fraudScore: 0.75,
      confidenceScore: 0.98,
    );
    InvoiceDetailModal.show(context, mockInvoice);
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Attachment',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(Icons.camera_alt, 'Camera'),
                    _buildAttachmentOption(Icons.image, 'Gallery'),
                    _buildAttachmentOption(Icons.description, 'Document'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label) {
    return HeavenlyInteraction(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primary,
            content: Text(
              '$label selected for upload',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceCard,
            ),
            child: Icon(icon, color: AppTheme.accentGreen),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: AppTheme.backgroundLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'clear',
          child: Text('Clear Chat', style: GoogleFonts.dmSans(color: AppTheme.error)),
        ),
        PopupMenuItem(
          value: 'mute',
          child: Text('Mute Notifications', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
        ),
        PopupMenuItem(
          value: 'export',
          child: Text('Export Chat', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'clear') {
        setState(() {
          _chatMessages.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history cleared.')),
        );
      } else if (value == 'mute') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications muted.')),
        );
      } else if (value == 'export') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history exported successfully.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: HeavenlyInteraction(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvD-NuPMDxiX7qTxmw_Mr90AIeDNLWboPPRfCD9-nZsc0GV1jyPZKzvGXZzF9Y-mmAN7fqlgVRAwr50TrOtzFJFDHJu-FwTwTGyvUaTJXC8RJ-SG7kjqIMLofewOGZZJlNP7eKOYxuve995rmFhBCJksUgyGhFdWeKxaDog4aGfN99NX9NyH1C3qZxmyPfCqzOJpa97_ZLR0Ll_D67EnIQYa1juKEXdnvneQ25ikdureDBSAjnY4X_3pFYvu7SmXB7VInikmnUBR0',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sarah Jenkins',
                      style: GoogleFonts.fraunces(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppTheme.accentGreen, size: 14),
                  ],
                ),
                Text(
                  'Senior Tax Advisor',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Builder(builder: (context) {
            return HeavenlyInteraction(
              onTap: () => _showMoreMenu(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Date Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCreamDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Text(
                        'Today, 10:42 AM',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Encryption note
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: AppTheme.textSecondary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Messages are end-to-end encrypted.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Messages list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _chatMessages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final msg = _chatMessages[index];
                      if (msg['isMe'] == true) {
                        return FadeInSlide(
                          delay: Duration.zero,
                          child: _buildOutgoingMessage(
                            msg['text'],
                            msg['time'],
                            statusIcon: msg['statusIcon'] ?? Icons.done,
                            statusColor: msg['statusColor'] ?? AppTheme.textMuted,
                          ),
                        );
                      } else {
                        if (msg['hasDoc'] == true) {
                          return FadeInSlide(
                            delay: Duration.zero,
                            child: _buildIncomingMessageWithDoc(msg['text'], msg['time']),
                          );
                        } else {
                          return FadeInSlide(
                            delay: Duration.zero,
                            child: _buildIncomingMessage(msg['text'], msg['time']),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HeavenlyInteraction(
                  onTap: _showAttachmentMenu,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 12, right: 8),
                    child: const Icon(Icons.add_circle, color: AppTheme.textSecondary, size: 28),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a secure message...',
                        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                HeavenlyInteraction(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCreamDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingMessageWithDoc(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCreamDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCreamDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.description, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice #INV-2023-089',
                              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Apex Tech Solutions • 2.4 MB • PDF',
                              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: HeavenlyInteraction(
                      onTap: _showMockDocument,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCreamDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.visibility, size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'View Document',
                              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingMessage(String text, String time, {required IconData statusIcon, required Color statusColor}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.accent.withValues(alpha: 0.8)),
                ),
                const SizedBox(width: 4),
                Icon(statusIcon, color: statusColor, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
