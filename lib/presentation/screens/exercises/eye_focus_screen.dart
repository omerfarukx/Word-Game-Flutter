import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../core/utils/audio_manager.dart';

class EyeFocusScreen extends StatefulWidget {
  const EyeFocusScreen({super.key});

  @override
  State<EyeFocusScreen> createState() => _EyeFocusScreenState();
}

class _EyeFocusScreenState extends State<EyeFocusScreen> {
  bool _isPlaying = false;
  Timer? _timer;
  Timer? _gameTimer;
  double _dotX = 0;
  double _dotY = 0;
  int _speed = 1000;
  bool _showSettings = false;
  final _random = math.Random();
  int _score = 0;
  int _successfulClicks = 0;
  int _missedClicks = 0;
  double _accuracy = 0.0;
  final AudioManager _audioManager = AudioManager();

  // Süre ile ilgili değişkenler
  int _remainingSeconds = 60; // 1 dakika
  bool _isGameOver = false;

  @override
  void dispose() {
    _timer?.cancel();
    _gameTimer?.cancel();
    _audioManager.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _successfulClicks = 0;
      _missedClicks = 0;
      _accuracy = 0.0;
      _remainingSeconds = 60;
      _updateDotPosition();
    });

    // Nokta hareketi için zamanlayıcı
    _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) {
      if (!_isGameOver) {
        _updateDotPosition();
        setState(() {
          _missedClicks++;
        });
        _updateAccuracy();
      }
    });

    // Oyun süresi için zamanlayıcı
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _dotX = 0;
      _dotY = 0;
    });
  }

  void _endGame() {
    _timer?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Bitti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Toplam Puan: $_score'),
            const SizedBox(height: 8),
            Text('İsabet Oranı: ${_accuracy.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Başarılı Tıklamalar: $_successfulClicks'),
            Text('Kaçırılan Noktalar: $_missedClicks'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isGameOver = false;
                _dotX = 0;
                _dotY = 0;
              });
            },
            child: const Text('Tamam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startExercise();
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  void _updateDotPosition() {
    setState(() {
      _dotX = (_random.nextDouble() * 1.6) - 0.8;
      _dotY = (_random.nextDouble() * 1.6) - 0.8;
    });
  }

  void _updateSpeed(int newSpeed) {
    // Hızı ters çevir (2000'den çıkar)
    int actualSpeed = 2100 - newSpeed;
    setState(() {
      _speed = actualSpeed;
    });

    // Mevcut zamanlayıcıyı iptal et ve yeni hızla tekrar başlat
    if (_isPlaying) {
      _timer?.cancel();
      _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) {
        if (!_isGameOver) {
          _updateDotPosition();
          setState(() {
            _missedClicks++;
          });
          _updateAccuracy();
        }
      });
    }
  }

  void _updateAccuracy() {
    setState(() {
      int totalAttempts = _successfulClicks + _missedClicks;
      if (totalAttempts > 0) {
        // İsabet oranını 100 üzerinden hesapla
        _accuracy = (_successfulClicks / totalAttempts) * 100;
        // En fazla 100 olabilir
        _accuracy = _accuracy.clamp(0, 100);
      } else {
        _accuracy = 0;
      }
    });
  }

  void _handleDotTap() {
    if (_isPlaying && !_isGameOver) {
      _audioManager.playSound('correct');
      setState(() {
        _score += 10;
        _successfulClicks++;
        // Başarılı tıklama olduğu için son kaçırma sayısını düşür
        if (_missedClicks > 0) {
          _missedClicks--;
        }
        _updateAccuracy();
      });
      _updateDotPosition();
    }
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
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
                          value: 2100 - _speed.toDouble(),
                          min: 100,
                          max: 2000,
                          divisions: 19,
                          label:
                              '${((2100 - _speed) / 2000 * 100).toStringAsFixed(0)}%',
                          onChanged: (value) => _updateSpeed(value.toInt()),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
              // Skor, İstatistik ve Süre Paneli
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Skor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _score.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ThemeConstants.lightPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'İsabet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_accuracy.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ThemeConstants.lightPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Süre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds <= 10
                                ? Colors.red
                                : ThemeConstants.lightPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (_isPlaying && !_isGameOver)
                      GestureDetector(
                        onTapDown: (_) => _handleDotTap(),
                        child: Align(
                          alignment: Alignment(_dotX, _dotY),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ThemeConstants.lightPrimaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeConstants.lightPrimaryColor
                                      .withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (!_isGameOver)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 48,
                              color: ThemeConstants.lightPrimaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Başlamak için butona basın',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Noktaları yakalamaya çalışın!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
