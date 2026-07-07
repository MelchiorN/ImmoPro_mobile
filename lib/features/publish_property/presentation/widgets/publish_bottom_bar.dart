import 'package:flutter/material.dart';

/// Barre de navigation bas commune au flow "Publier un bien".
/// Contient un bouton "Retour" optionnel et un bouton "Suivant / Soumettre".
class PublishBottomBar extends StatelessWidget {
  final bool showBack;
  final bool isLoading;
  final String nextLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const PublishBottomBar({
    super.key,
    this.showBack = true,
    this.isLoading = false,
    this.nextLabel = 'Suivant',
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Color(0xFFC2C6D3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBack) ...[
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onBack,
                  icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  label: const Text('Retour'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF424751),
                    side: const BorderSide(color: Color(0xFFC2C6D3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onNext,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded, size: 20),
                label: Text(nextLabel),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56A0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF1A56A0).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
