import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final TextEditingController _learnedTodayController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  String? _qrCode;
  Position? _position;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
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

  Future<void> _submitFinishClass() async {
    if (_qrCode == null || _position == null) {
      _showMessage('Please scan QR and get GPS location.');
      return;
    }

    if (_learnedTodayController.text.trim().isEmpty ||
        _feedbackController.text.trim().isEmpty) {
      _showMessage('Please fill all text fields.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final Map<String, dynamic> data = {
      'screen': 'finish_class',
      'qrCode': _qrCode,
      'latitude': _position!.latitude,
      'longitude': _position!.longitude,
      'whatDidYouLearnToday': _learnedTodayController.text.trim(),
      'feedbackAboutClass': _feedbackController.text.trim(),
      'submittedAt': DateTime.now(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Example Firestore write for prototype data.
      await FirebaseFirestore.instance.collection('finish_class').add(data);
      _showMessage('Finish class data submitted and saved to Firestore.');
    } catch (error) {
      debugPrint('Firestore save failed: $error');
      debugPrint('Finish class data: $data');
      _showMessage('Finish class submitted. Firestore is not configured yet.');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class (After Class)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _scanQrCode,
              child: const Text('Scan QR Code'),
            ),
            const SizedBox(height: 8),
            Text('QR Result: ${_qrCode ?? 'Not scanned'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Get GPS Location'),
            ),
            const SizedBox(height: 8),
            Text(
              _position == null
                  ? 'Location: Not captured'
                  : 'Location: ${_position!.latitude}, ${_position!.longitude}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _learnedTodayController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'What did you learn today?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Feedback about the class',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFinishClass,
              child: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
            ),
          ],
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
      body: MobileScanner(
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
    );
  }
}
