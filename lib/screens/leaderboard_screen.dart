import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/leaderboard/presentation/leaderboard_controller.dart';
import '../src/features/users/domain/app_user.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';
import 'user_profile_screen.dart';

/// Social leaderboard: friends/challenges toggle, stats, contributors, engagements.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _segment = 0; // 0 = Friends, 1 = Challenges

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(),
                const SizedBox(height: 20),
                _SegmentedTabs(
                  friendsSelected: _segment == 0,
                  onFriends: () => setState(() => _segment = 0),
                  onChallenges: () => setState(() => _segment = 1),
                ),
                const SizedBox(height: 24),
                if (_segment == 0) ...[
                  _PersonalStatsRow(),
                  const SizedBox(height: 28),
                  const _TopContributorsSection(),
                  const SizedBox(height: 32),
                  const _OpenEngagementsSection(),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Challenge rankings and seasonal ladders will appear here.',
                    style: AppTextStyles.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Social Leaderboard',
            style: AppTextStyles.playfair(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.15,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'VOLUME IV / ISSUE II',
            style: AppTextStyles.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: AppColors.labelTertiary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.friendsSelected,
    required this.onFriends,
    required this.onChallenges,
  });

  final bool friendsSelected;
  final VoidCallback onFriends;
  final VoidCallback onChallenges;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentChip(
            label: 'FRIENDS',
            filled: friendsSelected,
            onTap: onFriends,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SegmentChip(
            label: 'CHALLENGES',
            filled: !friendsSelected,
            onTap: onChallenges,
          ),
        ),
      ],
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppColors.primary,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: filled ? Colors.white : AppColors.primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalStatsRow extends ConsumerWidget {
  const _PersonalStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    final uid = ref.watch(currentUidProvider);
    final lbState = ref.watch(leaderboardControllerProvider).valueOrNull;
    final leaderboard = lbState?.users ?? const <AppUser>[];
    final rank =
        uid == null ? null : leaderboard.indexWhere((u) => u.uid == uid) + 1;
    final rankLabel = (rank != null && rank > 0)
        ? 'No. $rank'
        : leaderboard.isNotEmpty
            ? '${LeaderboardController.initialLimit}+'
            : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL RANK',
                    style: AppTextStyles.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.labelSecondary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    rankLabel,
                    style: AppTextStyles.playfair(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'STATUS',
                    style: AppTextStyles.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.labelSecondary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.tier ?? 'Novice',
                    style: AppTextStyles.playfair(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _TopContributorsSection extends ConsumerWidget {
  const _TopContributorsSection();

  static const _avatarColors = [
    Color(0xFF6B7280),
    Color(0xFF9CA3AF),
    Color(0xFF4B5563),
    Color(0xFF374151),
    Color(0xFF6366F1),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TOP CONTRIBUTORS',
              style: AppTextStyles.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            const Spacer(),
            Text(
              'By XP total',
              style: AppTextStyles.playfair(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        leaderboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (state) {
            final users = state.users.take(10).toList();
            if (users.isEmpty) {
              return Text(
                'No contributors yet.',
                style: AppTextStyles.inter(
                  fontSize: 14,
                  color: AppColors.labelSecondary,
                  height: 1.4,
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < users.length; i++) ...[
                  _ContributorTile(
                    rank: (i + 1).toString().padLeft(2, '0'),
                    user: users[i],
                    avatarColor: _avatarColors[i % _avatarColors.length],
                  ),
                  if (i < users.length - 1) ...[
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                  ],
                ],
                if (state.hasMore) ...[
                  const SizedBox(height: 18),
                  OutlinedButton(
                    onPressed: state.loadingMore
                        ? null
                        : () => ref
                            .read(leaderboardControllerProvider.notifier)
                            .loadMore(),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: AppColors.primary, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      state.loadingMore ? 'LOADING…' : 'LOAD MORE',
                      style: AppTextStyles.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        )
      ],
    );
  }
}

class _ContributorTile extends StatelessWidget {
  const _ContributorTile({
    required this.rank,
    required this.user,
    required this.avatarColor,
  });

  final String rank;
  final AppUser user;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty ? user.displayName[0] : '?';
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => UserProfileScreen(
              mode: UserProfileMode.other,
              otherUid: user.uid,
            ),
          ),
        );
      },
      splashColor: AppColors.primary.withValues(alpha: 0.06),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank,
              style: AppTextStyles.playfair(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColor,
            child: Text(
              initial,
              style: AppTextStyles.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTextStyles.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.streakCount} day streak',
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.labelTertiary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${user.xpTotal} XP',
            style: AppTextStyles.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenEngagementsSection extends StatelessWidget {
  const _OpenEngagementsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'OPEN ENGAGEMENTS',
          style: AppTextStyles.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        const _GratitudeCard(),
        const SizedBox(height: 16),
        const _WordWarriorCard(),
      ],
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  const _GratitudeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gratitude Spirit',
            style: AppTextStyles.playfair(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '7 DAYS · 1.2K ACTIVE',
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: AppColors.labelSecondary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.primary,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    'JOIN ENGAGEMENTS',
                    style: AppTextStyles.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordWarriorCard extends StatelessWidget {
  const _WordWarriorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'lib/assets/journal_icons/word-warrior-check.svg',
              width: 13,
              height: 13,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  'Word Warrior',
                  style: AppTextStyles.playfair(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ONGOING · DAY 03',
                style: AppTextStyles.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: AppColors.labelSecondary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _ProgressTrack(percent: 0.6),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'PROGRESS',
                    style: AppTextStyles.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppColors.labelSecondary,
                      height: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '60%',
                    style: AppTextStyles.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final p = percent.clamp(0.0, 1.0);
        return SizedBox(
          height: 4,
          width: w,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                width: w,
                color: AppColors.divider,
              ),
              Container(
                height: 4,
                width: w * p,
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
