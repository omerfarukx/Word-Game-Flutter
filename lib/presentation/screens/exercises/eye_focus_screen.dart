import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/theme_constants.dart';

class EyeFocusScreen extends StatefulWidget {
  const EyeFocusScreen({super.key});

  @override
  State<EyeFocusScreen> createState() => _EyeFocusScreenState();
}

class _EyeFocusScreenState extends State<EyeFocusScreen> {
  bool _isPlaying = false;
  Timer? _timer;
  double _dotX = 0;
  double _dotY = 0;
  int _speed = 1000; // milisaniye
  bool _showSettings = false;
  final _random = math.Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _updateDotPosition();
    });

    _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) {
      _updateDotPosition();
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _dotX = 0;
      _dotY = 0;
    });
  }

  void _updateDotPosition() {
    setState(() {
      // -0.8 ile 0.8 arasında rastgele değer (ekranın kenarlarından uzak tutmak için)
      _dotX = (_random.nextDouble() * 1.6) - 0.8;
      _dotY = (_random.nextDouble() * 1.6) - 0.8;
    });
  }

  void _updateSpeed(int newSpeed) {
    setState(() {
      _speed = newSpeed;
      if (_isPlaying) {
        _stopExercise();
        _startExercise();
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_isPlaying) {
      _stopExercise();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isPlaying) {
                _stopExercise();
              }
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Göz Odaklama'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_showSettings) ...[
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hız Ayarı (ms)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _speed.toDouble(),
                          min: 500,
                          max: 3000,
                          divisions: 25,
                          label: _speed.toString(),
                          onChanged: (value) => _updateSpeed(value.toInt()),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
              Expanded(
                child: Stack(
                  children: [
                    if (_isPlaying)
                      Align(
                        alignment: Alignment(_dotX, _dotY),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: ThemeConstants.lightPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          'Başlamak için butona basın',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _isPlaying ? _stopExercise : _startExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.lightPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    _isPlaying ? 'Durdur' : 'Başla',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
