class Achievement {
  final String id;
  final String title;
  final String description;
  final String badgeAsset;
  final int requiredScore;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeAsset,
    required this.requiredScore,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? badgeAsset,
    int? requiredScore,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeAsset: badgeAsset ?? this.badgeAsset,
      requiredScore: requiredScore ?? this.requiredScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
