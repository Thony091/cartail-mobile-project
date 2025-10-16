import 'package:flutter/material.dart';

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonStyle style;
  final bool isLoading;
  final double? width;
  final double height;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = ModernButtonStyle.primary,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getButtonColors();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.isLoading ? null : widget.onPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else ...[
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonColors _getButtonColors() {
    switch (widget.style) {
      case ModernButtonStyle.primary:
        return ButtonColors(
          gradientColors: [const Color(0xFF3498db), const Color(0xFF2980b9)],
          shadowColor: const Color(0xFF3498db).withOpacity(0.3),
        );
      case ModernButtonStyle.secondary:
        return ButtonColors(
          gradientColors: [const Color(0xFF95a5a6), const Color(0xFF7f8c8d)],
          shadowColor: const Color(0xFF95a5a6).withOpacity(0.3),
        );
      case ModernButtonStyle.danger:
        return ButtonColors(
          gradientColors: [const Color(0xFFe74c3c), const Color(0xFFc0392b)],
          shadowColor: const Color(0xFFe74c3c).withOpacity(0.3),
        );
      case ModernButtonStyle.success:
        return ButtonColors(
          gradientColors: [const Color(0xFF27ae60), const Color(0xFF2ecc71)],
          shadowColor: const Color(0xFF27ae60).withOpacity(0.3),
        );
      case ModernButtonStyle.warning:
        return ButtonColors(
          gradientColors: [const Color(0xFFf39c12), const Color(0xFFe67e22)],
          shadowColor: const Color(0xFFf39c12).withOpacity(0.3),
        );
    }
  }
}

enum ModernButtonStyle { primary, secondary, danger, success, warning }

class ButtonColors {
  final List<Color> gradientColors;
  final Color shadowColor;

  ButtonColors({required this.gradientColors, required this.shadowColor});
}
