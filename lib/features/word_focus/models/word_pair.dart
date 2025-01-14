class WordPair {
  final String mainWord;
  final List<String> relatedWords;
  final List<String> correctWords;
  final String category;

  const WordPair({
    required this.mainWord,
    required this.relatedWords,
    required this.correctWords,
    this.category = '',
  });

  factory WordPair.fromJson(Map<String, dynamic> json) {
    return WordPair(
      mainWord: json['mainWord'] as String,
      relatedWords: List<String>.from(json['relatedWords']),
      correctWords: List<String>.from(json['correctWords']),
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainWord': mainWord,
      'relatedWords': relatedWords,
      'correctWords': correctWords,
      'category': category,
    };
  }
}
