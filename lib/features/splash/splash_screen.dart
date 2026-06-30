import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../core/constants/route_constants.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_typography.dart';
import '../../core/design/widgets/aurora_background.dart';

/// Animated launch screen: an aurora backdrop, a glowing app mark that springs
/// in, the title "KELİME ATÖLYESİ" decoding out of scrambled letters (a nod to
/// the anagram game), a tagline, then a smooth fade into the home screen.
/// Tap anywhere to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  // Continuous glow/shimmer loop behind the mark and across the title.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  late final Animation<double> _logo = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.42, curve: Curves.elasticOut),
  );
  late final Animation<double> _decode = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.22, 0.82, curve: Curves.easeOut),
  );
  late final Animation<double> _tagline = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
  );

  bool _leaving = false;
  bool _introDone = false;
  bool _bootDone = false;

  @override
  void initState() {
    super.initState();
    _intro.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 450));
      _introDone = true;
      _tryExit();
    });
    _boot();
  }

  Future<void> _boot() async {
    try {
      await bootstrap();
    } catch (_) {
      // Even if init partially fails, don't trap the user on the splash.
    }
    _bootDone = true;
    _tryExit();
  }

  /// Leave only once both the intro animation and app init have finished.
  void _tryExit() {
    if (_introDone && _bootDone) _exit();
  }

  void _exit() {
    if (_leaving || !mounted) return;
    setState(() => _leaving = true);
  }

  void _onFadedOut() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteConstants.home);
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap fast-forwards the intro, but we still wait for init to finish.
      onTap: () {
        _introDone = true;
        _tryExit();
      },
      child: AnimatedOpacity(
        opacity: _leaving ? 0 : 1,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOut,
        onEnd: _leaving ? _onFadedOut : null,
        child: Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: Stack(
            children: [
              const Positioned.fill(
                child: AuroraBackground(accent: AppColors.word),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_logo, _loop]),
                      builder: (context, child) {
                        final glow = 0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi);
                        return Transform.scale(
                          scale: _logo.value.clamp(0.0, 1.0),
                          child: _Mark(glow: glow),
                        );
                      },
                    ),
                    const SizedBox(height: 34),
                    AnimatedBuilder(
                      animation: Listenable.merge([_decode, _loop]),
                      builder: (context, _) => _DecodeTitle(
                        progress: _decode.value,
                        shimmer: _loop.value,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _tagline,
                      child: Text(
                        'Kelimelerle zihnini çalıştır',
                        style: AppText.body(14, color: AppColors.textMid),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: FadeTransition(
                    opacity: _tagline,
                    child: _Dots(loop: _loop),
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

/// The glowing app mark — the crossword logo with a pulsing violet halo.
class _Mark extends StatelessWidget {
  const _Mark({required this.glow});
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.word.withValues(alpha: 0.30 + 0.35 * glow),
            blurRadius: 40 + 32 * glow,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset('assets/images/logo.png',
          width: 116, height: 116, filterQuality: FilterQuality.medium),
    );
  }
}

/// "KELİME ATÖLYESİ" with each letter cycling through random glyphs until it
/// locks into place, left to right — then a moving shimmer sweeps across.
class _DecodeTitle extends StatelessWidget {
  const _DecodeTitle({required this.progress, required this.shimmer});
  final double progress;
  final double shimmer;

  static const String _target = 'KELİME ATÖLYESİ';
  static const String _alphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

  @override
  Widget build(BuildContext context) {
    final chars = _target.split('');
    final n = chars.length;
    final buffer = StringBuffer();
    for (var i = 0; i < n; i++) {
      final ch = chars[i];
      if (ch == ' ') {
        buffer.write(' ');
        continue;
      }
      final reveal = (i + 1) / n; // stagger lock points across the word
      if (progress >= reveal) {
        buffer.write(ch);
      } else {
        final idx = ((progress * 60).floor() + i * 7) % _alphabet.length;
        buffer.write(_alphabet[idx]);
      }
    }

    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment(-1 + 2 * shimmer - 0.4, 0),
        end: Alignment(-1 + 2 * shimmer + 0.4, 0),
        colors: const [
          Color(0xFF8B5CF6),
          Colors.white,
          Color(0xFF8B5CF6),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            buffer.toString(),
            maxLines: 1,
            style: AppText.display(30, color: Colors.white, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}

/// Three pulsing dots — a quiet "loading" cue at the bottom.
class _Dots extends StatelessWidget {
  const _Dots({required this.loop});
  final Animation<double> loop;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (loop.value + i * 0.18) % 1.0;
            final t = 0.4 + 0.6 * math.sin(phase * 2 * math.pi).abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.word.withValues(alpha: t),
              ),
            );
          }),
        );
      },
    );
  }
}
