import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Près de vous',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A56A0).withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Fond carte stylisé
                CustomPaint(painter: _MapBgPainter(), size: Size.infinite),
                // Pins animés
                const _MapPin(leftFrac: 0.25, topFrac: 0.30),
                const _MapPin(leftFrac: 0.55, topFrac: 0.55),
                const _MapPin(leftFrac: 0.70, topFrac: 0.25),
                // Bouton "Ma position"
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.my_location_rounded, color: AppColors.primary, size: 14),
                      SizedBox(width: 5),
                      Text('Ma position', style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ]),
                  ),
                ),
                // Label "Vue carte"
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Explorer la zone',
                      style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = Colors.white.withValues(alpha: 0.75)..strokeWidth = 7..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final grid = Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.42), Offset(size.width, size.height * 0.42), road);
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.38, size.height), road);
    canvas.drawLine(Offset(size.width * 0.68, 0), Offset(size.width * 0.68, size.height), grid);
    canvas.drawLine(Offset(0, size.height * 0.72), Offset(size.width, size.height * 0.72), grid);
    final park = Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.18)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.5, size.height * 0.06, 72, 48), const Radius.circular(8)), park);
    final block = Paint()..color = const Color(0xFF90CAF9).withValues(alpha: 0.2)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.05, size.height * 0.55, 60, 30), const Radius.circular(4)), block);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.72, size.height * 0.5, 50, 28), const Radius.circular(4)), block);
  }

  @override
  bool shouldRepaint(_MapBgPainter old) => false;
}

class _MapPin extends StatefulWidget {
  final double leftFrac;
  final double topFrac;
  const _MapPin({required this.leftFrac, required this.topFrac});

  @override
  State<_MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<_MapPin> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(builder: (_, constraints) {
        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Positioned(
            left: constraints.maxWidth * widget.leftFrac,
            top: constraints.maxHeight * widget.topFrac + _anim.value,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 16),
            ),
          ),
        );
      }),
    );
  }
}
