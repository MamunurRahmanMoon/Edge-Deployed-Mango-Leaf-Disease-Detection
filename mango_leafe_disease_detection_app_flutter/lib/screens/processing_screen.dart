import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math';
import '../providers/app_provider.dart';
import '../utils/translations.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final File imageFile;
  const ProcessingScreen({super.key, required this.imageFile});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  final TFLiteService _tfliteService = TFLiteService();

  // Animations
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Pulsing glow ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotating scan arc
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Fade-in for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // Phase 1: Loading model
      _updateStatus('Loading AI model...', 0.2);
      await _tfliteService.init();

      if (!mounted) return;

      // Phase 2: Analyzing
      _updateStatus('Analyzing leaf patterns...', 0.5);
      await Future.delayed(const Duration(milliseconds: 300));

      final result = await _tfliteService.runInference(widget.imageFile);

      if (!mounted) return;

      // Phase 3: Complete
      _updateStatus('Diagnosis complete!', 1.0);
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageFile: widget.imageFile,
            diseaseName: result['label'] as String,
            confidence: result['confidence'] as double,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Processing error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
    } finally {
      _tfliteService.dispose();
    }
  }

  void _updateStatus(String text, double progress) {
    if (!mounted) return;
    setState(() {
      _statusText = text;
      _progress = progress;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).currentLanguage;
    final t = translations[lang]!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with dark gradient overlay
          Image.file(widget.imageFile, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A1A2E).withAlpha(220),
                  const Color(0xFF1A1A2E).withAlpha(240),
                  const Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated scanning ring with leaf icon
                _buildScanningRing(),

                const SizedBox(height: 48),

                // Status text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        t['analyzing'] ?? 'Analyzing...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withAlpha(130),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom branding
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Powered by MangoCare AI',
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the central animated scanning ring with a pulsing glow
  /// and a rotating arc indicator.
  Widget _buildScanningRing() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing outer glow
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(40),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(30),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Rotating scan arc
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _ScanArcPainter(
                  rotation: _rotateController.value * 2 * pi,
                  color: AppColors.primary,
                ),
              );
            },
          ),

          // Inner circle with leaf icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.eco,
              color: AppColors.primary,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws a rotating partial arc for the scanning effect.
class _ScanArcPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _ScanArcPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw the sweep arc with a gradient-like fade
    const sweepAngle = pi / 2; // 90 degrees
    for (int i = 0; i < 20; i++) {
      final fraction = i / 20;
      paint.color = color.withAlpha((200 * fraction).toInt());
      final startAngle = rotation + (sweepAngle * fraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle / 20,
        false,
        paint,
      );
    }

    // Second arc on opposite side
    for (int i = 0; i < 20; i++) {
      final fraction = i / 20;
      paint.color = color.withAlpha((150 * fraction).toInt());
      final startAngle = rotation + pi + (sweepAngle * fraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle / 20,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanArcPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
