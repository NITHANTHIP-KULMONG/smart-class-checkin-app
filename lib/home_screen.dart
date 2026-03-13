import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'checkin_screen.dart';
import 'finish_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Class Check-in App'),
      ),
      body: Stack(
        children: [
          const _DashboardBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroBanner(colors: colors),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool wide = constraints.maxWidth >= 760;

                          final Widget checkinCard = _FeatureCard(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'Check-in Before Class',
                            description:
                                'Verify attendance with QR, GPS, and your study expectation.',
                            buttonLabel: 'Start Check-in',
                            buttonIcon: Icons.login_rounded,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckInScreen(),
                                ),
                              );
                            },
                          );

                          final Widget finishCard = _FeatureCard(
                            icon: Icons.fact_check_rounded,
                            title: 'Finish Class After Session',
                            description:
                                'Complete verification and submit reflection feedback.',
                            buttonLabel: 'Finish Class',
                            buttonIcon: Icons.task_alt_rounded,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FinishClassScreen(),
                                ),
                              );
                            },
                          );

                          if (wide) {
                            return Row(
                              children: [
                                Expanded(child: checkinCard),
                                const SizedBox(width: 16),
                                Expanded(child: finishCard),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              checkinCard,
                              const SizedBox(height: 14),
                              finishCard,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBackground extends StatefulWidget {
  const _DashboardBackground();

  @override
  State<_DashboardBackground> createState() => _DashboardBackgroundState();
}

class _DashboardBackgroundState extends State<_DashboardBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + (0.7 * t), -1),
              end: Alignment(1, 1 - (0.6 * t)),
              colors: const [
                Color(0xFFF3F7FF),
                Color(0xFFE8F0FF),
                Color(0xFFF8ECFF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60 + (math.sin(t * math.pi * 2) * 18),
                right: -40 + (math.cos(t * math.pi * 2) * 20),
                child: const _BlurCircle(
                  color: Color(0x663F8CFF),
                  size: 220,
                ),
              ),
              Positioned(
                left: -70 + (math.cos(t * math.pi * 2) * 24),
                top: 260 + (math.sin(t * math.pi * 2) * 22),
                child: const _BlurCircle(
                  color: Color(0x55FF4D9F),
                  size: 240,
                ),
              ),
              Positioned(
                right: -70 + (math.sin(t * math.pi * 2) * 24),
                bottom: -10 + (math.cos(t * math.pi * 2) * 20),
                child: const _BlurCircle(
                  color: Color(0x558B5CF6),
                  size: 260,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xEE1A73E8),
                Color(0xEE6C4DFF),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331A73E8),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Smart Class Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Welcome Student',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track attendance, verify presence, and submit your learning reflection in one smooth flow.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.96),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Choose one task for this class session.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        offset: Offset(0, _hovered ? -0.02 : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x260F2D66).withValues(
                      alpha: _hovered ? 0.22 : 0.15,
                    ),
                    blurRadius: _hovered ? 30 : 22,
                    offset: Offset(0, _hovered ? 16 : 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withValues(alpha: 0.72),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedActionButton(
                    label: widget.buttonLabel,
                    icon: widget.buttonIcon,
                    onPressed: widget.onPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  const _AnimatedActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed
              ? 0.985
              : _hovered
                  ? 1.012
                  : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hovered
                    ? const [Color(0xFF7C4DFF), Color(0xFF2962FF)]
                    : [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.82),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: _hovered ? 0.5 : 0.35),
                  blurRadius: _hovered ? 22 : 14,
                  offset: Offset(0, _hovered ? 10 : 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon),
              label: Text(widget.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
