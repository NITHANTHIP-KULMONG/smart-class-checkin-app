import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final TextEditingController _previousTopicController = TextEditingController();
  final TextEditingController _expectedTopicController = TextEditingController();

  String? _qrCode;
  Position? _position;
  DateTime? _timestamp;
  int _moodValue = 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final String? code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QrScannerPage()),
    );

    if (code != null && mounted) {
      setState(() {
        _qrCode = code;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location service is disabled. Please enable GPS.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is required.');
      return;
    }

    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _position = position;
    });
  }

  void _recordTimestamp() {
    setState(() {
      _timestamp = DateTime.now();
    });
  }

  Future<void> _submitCheckin() async {
    if (_qrCode == null || _position == null || _timestamp == null) {
      _showMessage('Please scan QR, get GPS, and record timestamp.');
      return;
    }

    if (_previousTopicController.text.trim().isEmpty ||
        _expectedTopicController.text.trim().isEmpty) {
      _showMessage('Please fill all text fields.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final Map<String, dynamic> data = {
      'screen': 'checkin',
      'qrCode': _qrCode,
      'latitude': _position!.latitude,
      'longitude': _position!.longitude,
      'timestamp': _timestamp,
      'previousClassTopic': _previousTopicController.text.trim(),
      'expectedTopicToday': _expectedTopicController.text.trim(),
      'mood': _moodValue,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Example Firestore write for prototype data.
      await FirebaseFirestore.instance.collection('checkins').add(data);
      _showMessage('Check-in submitted and saved to Firestore.');
    } catch (error) {
      debugPrint('Firestore save failed: $error');
      debugPrint('Check-in data: $data');
      _showMessage('Check-in submitted. Firestore is not configured yet.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in (Before Class)')),
      body: Stack(
        children: [
          const _ScreenBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GlassSectionCard(
                        title: 'Attendance Verification',
                        subtitle:
                            'Verify your presence using QR, GPS, and timestamp.',
                        leadingIcon: Icons.verified_user_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AnimatedActionButton(
                              onPressed: _scanQrCode,
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Scan QR Code',
                            ),
                            const SizedBox(height: 10),
                            _StatusRow(
                              icon: Icons.qr_code_2_rounded,
                              label: 'QR Result',
                              value: _qrCode ?? 'Not scanned',
                            ),
                            const SizedBox(height: 14),
                            _AnimatedActionButton(
                              onPressed: _getCurrentLocation,
                              icon: Icons.my_location_rounded,
                              label: 'Get GPS Location',
                            ),
                            const SizedBox(height: 10),
                            _StatusRow(
                              icon: Icons.location_on_rounded,
                              label: 'Location',
                              value: _position == null
                                  ? 'Not captured'
                                  : '${_position!.latitude.toStringAsFixed(6)}, '
                                      '${_position!.longitude.toStringAsFixed(6)}',
                            ),
                            const SizedBox(height: 14),
                            _AnimatedActionButton(
                              onPressed: _recordTimestamp,
                              icon: Icons.access_time_rounded,
                              label: 'Record Timestamp',
                            ),
                            const SizedBox(height: 10),
                            _StatusRow(
                              icon: Icons.schedule_rounded,
                              label: 'Timestamp',
                              value: _timestamp?.toString() ?? 'Not recorded',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GlassSectionCard(
                        title: 'Learning Input',
                        subtitle:
                            'Share your expectation and current learning mood.',
                        leadingIcon: Icons.school_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _previousTopicController,
                              decoration: const InputDecoration(
                                labelText: 'Previous class topic',
                                prefixIcon: Icon(Icons.history_edu_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _expectedTopicController,
                              decoration: const InputDecoration(
                                labelText: 'Expected topic today',
                                prefixIcon: Icon(Icons.lightbulb_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.sentiment_satisfied_alt_rounded,
                                    color: colors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Mood: $_moodValue / 5',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _moodValue.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: _moodValue.toString(),
                              activeColor: colors.primary,
                              onChanged: (double value) {
                                setState(() {
                                  _moodValue = value.round();
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Low',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Neutral',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'High',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AnimatedActionButton(
                        onPressed: _isSubmitting ? null : _submitCheckin,
                        icon: Icons.cloud_upload_rounded,
                        label: _isSubmitting ? 'Submitting...' : 'Submit',
                        primary: true,
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

class _ScreenBackground extends StatefulWidget {
  const _ScreenBackground();

  @override
  State<_ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<_ScreenBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
              begin: Alignment(-1 + (0.6 * t), -1),
              end: Alignment(1, 1 - (0.6 * t)),
              colors: const [
                Color(0xFFF3F8FF),
                Color(0xFFE9F1FF),
                Color(0xFFF7F1FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70 + (math.sin(t * math.pi * 2) * 18),
                right: -40 + (math.cos(t * math.pi * 2) * 18),
                child: const _GlowOrb(color: Color(0x4D4F8CFF), size: 220),
              ),
              Positioned(
                bottom: -40 + (math.cos(t * math.pi * 2) * 16),
                left: -60 + (math.sin(t * math.pi * 2) * 22),
                child: const _GlowOrb(color: Color(0x4D00BFA6), size: 240),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 84, spreadRadius: 12),
          ],
        ),
      ),
    );
  }
}

class _GlassSectionCard extends StatefulWidget {
  const _GlassSectionCard({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget child;

  @override
  State<_GlassSectionCard> createState() => _GlassSectionCardState();
}

class _GlassSectionCardState extends State<_GlassSectionCard> {
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
        offset: Offset(0, _hovered ? -0.012 : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x26112A62).withValues(
                      alpha: _hovered ? 0.22 : 0.15,
                    ),
                    blurRadius: _hovered ? 28 : 20,
                    offset: Offset(0, _hovered ? 16 : 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.leadingIcon, color: colors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: colors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  const _AnimatedActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.primary = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool primary;

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color backgroundColor = widget.primary
        ? colors.primary
        : colors.primary.withValues(alpha: 0.92);

    final Color foregroundColor = widget.primary
        ? colors.onPrimary
        : colors.onPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: _pressed
              ? 0.985
              : _hovered
                  ? 1.01
                  : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hovered
                    ? const [Color(0xFF7C4DFF), Color(0xFF2962FF)]
                    : [
                        backgroundColor,
                        backgroundColor.withValues(alpha: 0.86),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: _hovered ? 0.5 : 0.35),
                  blurRadius: _hovered ? 20 : 12,
                  offset: Offset(0, _hovered ? 9 : 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon),
              label: Text(widget.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: foregroundColor,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) {
                return;
              }

              final String? value = capture.barcodes.first.rawValue;
              if (value == null || value.isEmpty) {
                return;
              }

              _handled = true;
              Navigator.pop(context, value);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Text(
                    'Align QR code inside the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
