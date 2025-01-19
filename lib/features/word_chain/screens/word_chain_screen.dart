import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_chain_game.dart';
import '../../statistics/providers/statistics_provider.dart';

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen> {
  late WordChainGame _game;
  final _wordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _game = WordChainGame();
    _game.gameState.listen((state) {
      if (!state.isGameActive && state.score > 0) {
        context.read<StatisticsProvider>().saveWordChainScore(state.score);
      }
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _game.dispose();
    super.dispose();
  }

  void _submitWord() {
    if (_wordController.text.isNotEmpty) {
      _game.submitWord(_wordController.text.trim());
      _wordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Zinciri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nasıl Oynanır?'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHelpItem(
                        '1. Oyun Kuralları:',
                        '• Her kelimenin son harfi ile yeni kelime türetin\n'
                            '• Kelimeler en az 2 harf olmalıdır\n'
                            '• Aynı kelimeyi tekrar kullanamazsınız',
                      ),
                      const SizedBox(height: 16),
                      _buildHelpItem(
                        '2. Puanlama:',
                        '• Her harf 10 puan değerindedir\n'
                            '• 3 veya daha fazla doğru kelime art arda girildiğinde %50 bonus puan\n'
                            '• Yanlış kelime girişinde combo sıfırlanır',
                      ),
                      const SizedBox(height: 16),
                      _buildHelpItem(
                        '3. Süre:',
                        '• Oyun süresi 90 saniyedir\n'
                            '• Süre dolmadan önce mümkün olduğunca çok kelime türetmeye çalışın',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<WordChainGameState>(
        stream: _game.gameState,
        builder: (context, snapshot) {
          final gameState = snapshot.data;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
                    : [Colors.blue.shade100, Colors.blue.shade200],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  children: [
                    // Üst bilgi kartları
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Puan',
                            '${gameState?.score ?? 0}',
                            Icons.stars,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Süre',
                            '${gameState?.timeLeft ?? 90}',
                            Icons.timer,
                            (gameState?.timeLeft ?? 90) > 30
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Combo',
                            '${gameState?.combo ?? 0}',
                            Icons.flash_on,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Mevcut kelime ve ipucu
                    if (gameState?.currentWord.isNotEmpty ?? false)
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          child: Column(
                            children: [
                              const Text(
                                'Mevcut Kelime',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gameState!.currentWord.toUpperCase(),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${gameState.currentWord[gameState.currentWord.length - 1].toUpperCase()}" ile başlayan bir kelime girin',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Kelime girişi
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _wordController,
                              decoration: InputDecoration(
                                hintText: 'Kelime girin',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _submitWord,
                                ),
                              ),
                              enabled: gameState?.isGameActive ?? false,
                              onSubmitted: (_) => _submitWord(),
                              textCapitalization: TextCapitalization.characters,
                            ),
                            if (gameState?.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  gameState!.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Başlat/Bitir düğmesi
                    if (!(gameState?.isGameActive ?? false))
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _game.startGame(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'BAŞLAT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (gameState != null && gameState.score > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Oyun Bitti!',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'En Uzun Kelime: ${gameState.longestWord} harf'),
                                  Text(
                                      'En Yüksek Combo: ${gameState.maxCombo}'),
                                ],
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Kullanılan kelimeler listesi
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Kullanılan Kelimeler (${gameState?.usedWords.length ?? 0})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: gameState?.usedWords.length ?? 0,
                                itemBuilder: (context, index) {
                                  final word = gameState!.usedWords[index];
                                  return ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    title: Text(
                                      word.toUpperCase(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.teal,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    trailing: Text(
                                      '${word.length * 10} puan',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }
}
