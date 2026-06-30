import 'package:flutter/material.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_typography.dart';
import '../../core/design/decorations.dart';
import '../../core/design/widgets/aurora_background.dart';

class _Page {
  const _Page(this.icon, this.accent, this.title, this.body);
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
}

const _pages = <_Page>[
  _Page(
    Icons.psychology_rounded,
    AppColors.word,
    'Kelime Atölyesi’ne hoş geldin',
    'Hızlı okuma ve kelime becerini geliştiren 10 mini oyun. Her gün birkaç dakika, fark yaratır.',
  ),
  _Page(
    Icons.sports_esports_rounded,
    AppColors.visual,
    'Üç tür egzersiz',
    'Kelime oyunları, görsel tarama ve hızlı okuma. Her oyunu ilk açtığında kısa bir “nasıl oynanır” gösterilir.',
  ),
  _Page(
    Icons.emoji_events_rounded,
    AppColors.reading,
    'İlerle ve rekor kır',
    'Seviye atla, günlük hedefini tuttur, rozet topla ve her oyunda kişisel rekorunu zorla.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  void _next() {
    if (_isLast) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _pages[_index].accent;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: AuroraBackground(accent: accent)),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                    child: TextButton(
                      onPressed: widget.onDone,
                      child: Text('Atla',
                          style: AppText.body(14, color: AppColors.textLow)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, i) => _PageView(page: _pages[i]),
                  ),
                ),
                _Dots(count: _pages.length, index: _index),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.forAccent(accent),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _next,
                          child: SizedBox(
                            height: 54,
                            child: Center(
                              child: Text(_isLast ? 'Başla' : 'Devam',
                                  style: AppText.body(16,
                                      weight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppGradients.forAccent(page.accent),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: page.accent.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 12)),
              ],
            ),
            child: Icon(page.icon, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (r) => AppGradients.forAccent(page.accent)
                .createShader(r),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: AppText.display(30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: AppText.body(15, color: AppColors.textMid, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.textHi : AppColors.stroke,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
