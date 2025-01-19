import 'dart:async';
import 'package:flutter/material.dart';

class SpeedReadingScreen extends StatefulWidget {
  const SpeedReadingScreen({super.key});

  @override
  State<SpeedReadingScreen> createState() => _SpeedReadingScreenState();
}

class _SpeedReadingScreenState extends State<SpeedReadingScreen> {
  final String _text = '''
Hızlı okuma, gözün metni daha hızlı taraması ve beynin bilgiyi daha hızlı işlemesi prensibine dayanır. 
Bu yeteneği geliştirmek için düzenli pratik yapmak gerekir. 
Göz kaslarının eğitilmesi ve odaklanma yeteneğinin artırılması önemlidir.
Hızlı okuma yaparken anlama oranının da yüksek olması hedeflenir.
Bunun için okuma hızı kademeli olarak artırılmalıdır.
''';

  final List<String> _words = [];
  String _currentWord = '';
  int _currentIndex = 0;
  bool _isPlaying = false;
  Timer? _timer;
  int _speed = 300; // milisaniye
  bool _showSettings = false;
  int _wordsPerMinute = 0;

  @override
  void initState() {
    super.initState();
    _words.addAll(_text.split(' '));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _currentIndex = 0;
      _currentWord = _words[_currentIndex];
      _wordsPerMinute = (60000 / _speed).round();
    });

    _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) {
      setState(() {
        if (_currentIndex < _words.length - 1) {
          _currentIndex++;
          _currentWord = _words[_currentIndex];
        } else {
          _stopExercise();
        }
      });
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentWord = '';
    });
  }

  void _updateSpeed(int newSpeed) {
    setState(() {
      _speed = newSpeed;
      _wordsPerMinute = (60000 / _speed).round();
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
    final primaryColor = Theme.of(context).colorScheme.primary;
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
          title: const Text('Hızlı Okuma'),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hız Ayarı (ms)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_wordsPerMinute kelime/dk',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _speed.toDouble(),
                          min: 100,
                          max: 1000,
                          divisions: 18,
                          label: _speed.toString(),
                          onChanged: (value) => _updateSpeed(value.toInt()),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
              if (!_isPlaying)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _text,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentWord,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Hız: $_wordsPerMinute kelime/dk',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _isPlaying ? _stopExercise : _startExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
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
