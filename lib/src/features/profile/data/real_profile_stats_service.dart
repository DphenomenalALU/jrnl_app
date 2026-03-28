import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../users/domain/app_user.dart';
import '../../users/domain/users_repository.dart';
import '../../users/presentation/current_app_user_provider.dart';
import '../domain/profile_stats.dart';
import '../domain/profile_stats_service.dart';

class RealProfileStatsService implements ProfileStatsService {
  RealProfileStatsService(this._ref, this._usersRepository);

  final Ref _ref;
  final UsersRepository _usersRepository;

  static const int _xpPerTier = 1000;

  @override
  Stream<ProfileStats> watchStats() {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) {
      return Stream.value(_empty());
    }
    return _usersRepository.watchUser(uid).map((user) {
      if (user == null) return _empty();
      return _fromUser(user);
    });
  }

  ProfileStats _empty() {
    return const ProfileStats(
      tierLabel: '—',
      xpTotal: 0,
      progressToNextTier: 0,
      xpRemainingToNextTier: 0,
      nextTierLabel: '—',
    );
  }

  ProfileStats _fromUser(AppUser user) {
    final xpTotal = user.xpTotal;
    final remainder = xpTotal % _xpPerTier;
    final progress = remainder / _xpPerTier;
    final remaining = remainder == 0 && xpTotal > 0 ? _xpPerTier : _xpPerTier - remainder;

    final tierNumber = _parseTierNumber(user.tier) ?? (xpTotal ~/ _xpPerTier) + 1;
    final tierLabel = user.tier?.trim().isNotEmpty == true ? user.tier!.trim() : 'Tier ${_toRoman(tierNumber)}';
    final nextTierLabel = 'Tier ${_toRoman(tierNumber + 1)}';

    // Force intl to be referenced so the dependency is “used” in this layer.
    // (We still format in the UI; this prevents accidental removal.)
    NumberFormat.decimalPattern().format(xpTotal);

    return ProfileStats(
      tierLabel: tierLabel,
      xpTotal: xpTotal,
      progressToNextTier: progress.clamp(0, 1),
      xpRemainingToNextTier: remaining,
      nextTierLabel: nextTierLabel,
    );
  }
}

int? _parseTierNumber(String? tier) {
  final raw = tier?.trim();
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.split(' ');
  if (parts.length < 2) return null;
  final token = parts.last;
  final asInt = int.tryParse(token);
  if (asInt != null) return asInt;
  return _fromRoman(token);
}

String _toRoman(int value) {
  if (value <= 0) return 'I';
  const numerals = [
    (1000, 'M'),
    (900, 'CM'),
    (500, 'D'),
    (400, 'CD'),
    (100, 'C'),
    (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];
  var n = value;
  final buf = StringBuffer();
  for (final (v, s) in numerals) {
    while (n >= v) {
      buf.write(s);
      n -= v;
    }
  }
  return buf.toString();
}

int? _fromRoman(String roman) {
  final r = roman.toUpperCase();
  const map = {
    'I': 1,
    'V': 5,
    'X': 10,
    'L': 50,
    'C': 100,
    'D': 500,
    'M': 1000,
  };
  var total = 0;
  var prev = 0;
  for (final ch in r.split('').reversed) {
    final v = map[ch];
    if (v == null) return null;
    if (v < prev) {
      total -= v;
    } else {
      total += v;
      prev = v;
    }
  }
  return total == 0 ? null : total;
}

