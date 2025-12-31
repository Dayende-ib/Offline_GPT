import 'package:flutter/material.dart';

class TechPalette {
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF142038);
  static const surfaceStrong = Color(0xFF182643);
  static const outline = Color(0xFF27344E);
  static const accent = Color(0xFF38E8E1);
  static const accentAlt = Color(0xFF57F287);
  static const textPrimary = Color(0xFFEAF1FF);
  static const textMuted = Color(0xFF8AA2C1);
  static const error = Color(0xFFFF6B6B);
  static const grid = Color(0x1A8AA2C1);
}

ThemeData buildTechTheme() {
  final scheme = ColorScheme.dark(
    primary: TechPalette.accent,
    secondary: TechPalette.accentAlt,
    surface: TechPalette.surface,
    error: TechPalette.error,
    onPrimary: TechPalette.background,
    onSecondary: TechPalette.background,
    onSurface: TechPalette.textPrimary,
    onError: TechPalette.background,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TechPalette.background,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: TechPalette.background,
      foregroundColor: TechPalette.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: TechPalette.surfaceStrong,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: TechPalette.outline),
      ),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: TechPalette.textPrimary,
      displayColor: TechPalette.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TechPalette.surface,
      labelStyle: const TextStyle(color: TechPalette.textMuted),
      hintStyle: const TextStyle(color: TechPalette.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TechPalette.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TechPalette.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TechPalette.accent, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TechPalette.surfaceStrong,
      indicatorColor: TechPalette.accent.withAlpha(51),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? TechPalette.textPrimary
            : TechPalette.textMuted;
        return TextStyle(color: color, fontWeight: FontWeight.w600);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? TechPalette.accent
            : TechPalette.textMuted;
        return IconThemeData(color: color);
      }),
    ),
    tabBarTheme: const TabBarThemeData(
      dividerColor: Colors.transparent,
      labelColor: TechPalette.background,
      unselectedLabelColor: TechPalette.textMuted,
    ),
  );
}

class TechBackground extends StatelessWidget {
  const TechBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _TechGradient(),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        const Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(color: TechPalette.accent, size: 180),
        ),
        const Positioned(
          bottom: -60,
          left: -40,
          child: _GlowOrb(color: TechPalette.accentAlt, size: 160),
        ),
      ],
    );
  }
}

class _TechGradient extends StatelessWidget {
  const _TechGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TechPalette.background,
            Color(0xFF0E1629),
            Color(0xFF131F33),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(46),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(89),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = TechPalette.grid
          ..strokeWidth = 1;

    const spacing = 48.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
