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
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A56A0).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Carte stylisée (placeholder)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFE8F0F9),
                  child: CustomPaint(
                    painter: _MockMapPainter(),
                  ),
                ),
                // Pins animés
                const _AnimatedMapPin(left: 0.3, top: 0.25),
                const _AnimatedMapPin(left: 0.6, top: 0.5),
                const _AnimatedMapPin(left: 0.2, top: 0.65),
                // Contrôles carte
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _MapControlButton(icon: Icons.add, onTap: () {}),
                      const SizedBox(height: 8),
                      _MapControlButton(icon: Icons.remove, onTap: () {}),
                    ],
                  ),
                ),
                // Bouton Ma position
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Ma position',
                            style: TextStyle(
                              fontFamily: 'HankenGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
        ),
      ],
    );
  }
}

/// Peintre de carte fictive stylisée
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Routes principales
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      gridPaint,
    );

    // Bloc vert (parc)
    final parkPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.05, 80, 60),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(_MockMapPainter oldDelegate) => false;
}

/// Pin animé sur la carte
class _AnimatedMapPin extends StatefulWidget {
  final double left;
  final double top;

  const _AnimatedMapPin({required this.left, required this.top});

  @override
  State<_AnimatedMapPin> createState() => _AnimatedMapPinState();
}

class _AnimatedMapPinState extends State<_AnimatedMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: constraints.maxWidth * widget.left,
                top: constraints.maxHeight * widget.top + _animation.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
