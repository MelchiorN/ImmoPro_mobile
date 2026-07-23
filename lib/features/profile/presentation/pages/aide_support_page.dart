import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../ai_chat/presentation/pages/ai_chat_page.dart';

class AideSupportPage extends StatelessWidget {
  const AideSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Aide & Support',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Chatbot IA Card ─────────────────────────────────────────────
            _buildAiAssistantCard(context),
            const SizedBox(height: 28),

            // ── FAQ ─────────────────────────────────────────────────────────
            const Text(
              'Questions fréquentes',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFaqSection(),
            const SizedBox(height: 28),

            // ── Contact & Signalement ───────────────────────────────────────
            const Text(
              'Besoin d\'assistance ?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactButtons(context),
            const SizedBox(height: 28),

            // ── Liens ───────────────────────────────────────────────────────
            _buildLegalLinks(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAssistantCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003E7E), Color(0xFF1A56A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003E7E).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Assistant IA ImmoPro',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Notre assistant virtuel est disponible 24h/24 pour répondre à toutes vos questions sur l\'application, les contrats ou la gestion locative.',
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
              height: 1.4,
              color: Color(0xFFE2E8F0), // Light color
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiChatPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF003E7E),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Poser une question à l\'assistant',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          _buildFaqItem(
            question: 'Comment réserver un bien ?',
            answer: 'Allez sur la fiche du bien, cliquez sur "Louer le bien", acceptez les conditions du contrat et procédez au paiement des frais requis.',
          ),
          _buildDivider(),
          _buildFaqItem(
            question: 'Quel est le délai de validation d\'un bien ?',
            answer: 'Une fois votre bien publié, nos agents l\'étudient sous 24 à 48 heures ouvrées pour le valider ou vous demander des modifications.',
          ),
          _buildDivider(),
          _buildFaqItem(
            question: 'Quels sont les moyens de paiement acceptés ?',
            answer: 'Nous acceptons les paiements mobiles (CashPay, Flooz/T-Money) ainsi que les cartes bancaires via notre passerelle sécurisée.',
          ),
          _buildDivider(),
          _buildFaqItem(
            question: 'Comment contacter le propriétaire ?',
            answer: 'Vous pouvez échanger avec le propriétaire ou l\'agent en charge via la section "Messages" disponible dans la barre de navigation.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 13,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: AppColors.outlineVariant);

  Widget _buildContactButtons(BuildContext context) {
    return Column(
      children: [
        _buildContactTile(
          icon: Icons.mail_outline_rounded,
          title: 'Nous écrire par e-mail',
          subtitle: 'support@immopro.com',
          onTap: () {
            // Stub email launch
            _showSuccess(context, 'Ouverture de votre boîte mail...');
          },
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.report_problem_outlined,
          title: 'Signaler un problème',
          subtitle: 'Signaler une annonce suspecte ou un bug',
          onTap: () {
            _showSuccess(context, 'Formulaire de signalement bientôt disponible.');
          },
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryContainer, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Column(
      children: [
        _buildLinkTile(context, 'Conditions Générales d\'Utilisation'),
        _buildLinkTile(context, 'Politique de confidentialité'),
        _buildLinkTile(context, 'À propos de ImmoPro'),
      ],
    );
  }

  Widget _buildLinkTile(BuildContext context, String text) {
    return InkWell(
      onTap: () => _showSuccess(context, 'Chargement de la page légale...'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'HankenGrotesk')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
