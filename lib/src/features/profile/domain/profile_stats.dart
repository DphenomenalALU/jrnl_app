class ProfileStats {
  const ProfileStats({
    required this.tierLabel,
    required this.xpTotal,
    required this.progressToNextTier,
    required this.xpRemainingToNextTier,
    required this.nextTierLabel,
  });

  final String tierLabel;
  final int xpTotal;

  /// 0..1
  final double progressToNextTier;

  final int xpRemainingToNextTier;
  final String nextTierLabel;
}

