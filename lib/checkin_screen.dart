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
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in (Before Class)')),
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
            ElevatedButton(
              onPressed: _recordTimestamp,
              child: const Text('Record Timestamp'),
            ),
            const SizedBox(height: 8),
            Text('Timestamp: ${_timestamp?.toString() ?? 'Not recorded'}'),
            const SizedBox(height: 16),
            TextField(
              controller: _previousTopicController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Previous class topic',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expectedTopicController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Expected topic today',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Mood (1-5):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                final int value = index + 1;
                return ChoiceChip(
                  label: Text(value.toString()),
                  selected: _moodValue == value,
                  onSelected: (_) {
                    setState(() {
                      _moodValue = value;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckin,
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
