import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/users/domain/app_user.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';
import 'edit_profile_screen.dart';

const _kProfileAccentBlue = Color(0xFF2563EB);

/// Own profile vs. viewing another member's profile (badges, challenges, actions differ).
enum UserProfileMode { me, other }

/// Full-screen profile: large avatar, streak/rank pill, badges, and recent challenges.
/// Pass [otherUid] when [mode] == [UserProfileMode.other] to load that user's data.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({
    super.key,
    required this.mode,
    this.otherUid,
  });

  final UserProfileMode mode;
  final String? otherUid;

  static const _avatarAsset = 'lib/assets/ai-image.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewingSelf = mode == UserProfileMode.me;

    final userAsync = viewingSelf
        ? ref.watch(currentAppUserProvider)
        : otherUid != null
            ? ref.watch(_otherUserProvider(otherUid!))
            : const AsyncData<AppUser?>(null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileTopBar(
              viewingSelf: viewingSelf,
              onBack: () => Navigator.of(context).pop(),
              onEdit: viewingSelf
                  ? () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.background,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => const EditProfileScreen(),
                      )
                  : null,
            ),
            Expanded(
              child: userAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (user) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: _LargeAvatar(
                          photoUrl: user?.photoUrl,
                          assetPath: _avatarAsset,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user?.displayName ?? 'Member',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.playfair(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: AppColors.primary,
                        ),
                      ),
                      if (viewingSelf) ...[
                        if (user?.location != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            user!.location!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.playfair(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: AppColors.labelSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                        if (user?.bio != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            user!.bio!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.labelSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ] else ...[
                        if (user?.bio != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            user!.bio!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.playfair(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: _kProfileAccentBlue,
                              height: 1.35,
                            ),
                          ),
                        ],
                        if (user?.location != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            user!.location!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.labelTertiary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 28),
                      _StatsPill(
                        streakCount: user?.streakCount ?? 0,
                        xpTotal: user?.xpTotal ?? 0,
                      ),
                      const SizedBox(height: 36),
                      _TopBadgesSection(viewingSelf: viewingSelf),
                      const SizedBox(height: 36),
                      _RecentChallengesSection(viewingSelf: viewingSelf),
                      if (!viewingSelf) ...[
                        const SizedBox(height: 32),
                        _FollowMessageRow(
                            displayName: user?.displayName ?? 'Member'),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _otherUserProvider =
    StreamProvider.autoDispose.family<AppUser?, String>((ref, uid) {
  return ref.watch(usersRepositoryProvider).watchUser(uid);
});

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.viewingSelf,
    required this.onBack,
    this.onEdit,
  });

  final bool viewingSelf;
  final VoidCallback onBack;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.primary),
            tooltip: 'Back',
          ),
          const Spacer(),
          if (viewingSelf && onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 22, color: AppColors.primary),
              tooltip: 'Edit profile',
            )
          else if (!viewingSelf) ...[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.share_outlined, size: 22, color: AppColors.primary.withValues(alpha: 0.85)),
              tooltip: 'Share',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, size: 26, color: AppColors.primary),
              tooltip: 'More',
            ),
          ],
        ],
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  const _LargeAvatar({required this.assetPath, this.photoUrl});

  final String assetPath;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 112,
      height: 112,
      color: AppColors.inputSurface,
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 48, color: AppColors.labelTertiary),
    );
    return ClipOval(
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : Image.asset(
              assetPath,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  const _StatsPill({required this.streakCount, required this.xpTotal});

  final int streakCount;
  final int xpTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: AppTextStyles.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$streakCount Days',
                  style: AppTextStyles.playfair(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'XP TOTAL',
                  style: AppTextStyles.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$xpTotal',
                  style: AppTextStyles.playfair(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
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

class _TopBadgesSection extends StatelessWidget {
  const _TopBadgesSection({required this.viewingSelf});

  final bool viewingSelf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Top Badges',
              style: AppTextStyles.playfair(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              'VIEW GALLERY',
              style: AppTextStyles.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (viewingSelf)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EmptyBadgeOrb(),
              const SizedBox(width: 20),
              _BadgeOrb(
                child: SvgPicture.asset(
                  'lib/assets/journal_icons/sparkle.svg',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),
              _EmptyBadgeOrb(),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LabeledBadge(
                label: 'EARLY RISER',
                child: const Icon(Icons.wb_sunny_outlined, size: 24, color: AppColors.primary),
              ),
              _LabeledBadge(
                label: 'DEEP REFLECTOR',
                child: _SvgBadgeIcon(asset: 'lib/assets/journal_icons/sparkle.svg'),
              ),
              _LabeledBadge(
                label: 'STOIC MIND',
                child: const Icon(Icons.track_changes, size: 24, color: AppColors.primary),
              ),
            ],
          ),
      ],
    );
  }
}

class _EmptyBadgeOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _BadgeOrb extends StatelessWidget {
  const _BadgeOrb({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _LabeledBadge extends StatelessWidget {
  const _LabeledBadge({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _BadgeOrb(child: child),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.labelTertiary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SvgBadgeIcon extends StatelessWidget {
  const _SvgBadgeIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
    );
  }
}

class _RecentChallengesSection extends StatelessWidget {
  const _RecentChallengesSection({required this.viewingSelf});

  final bool viewingSelf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recent Challenges',
          style: AppTextStyles.playfair(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        if (viewingSelf) ...[
          _OwnChallengeTile(
            asset: 'lib/assets/journal_icons/action-item-reflect.svg',
            title: '7 Days of Gratitude',
            subtitle: 'Consider why you felt overwhelmed at work today.',
            onTap: () {},
          ),
          _Hairline(),
          _OwnChallengeTile(
            asset: 'lib/assets/journal_icons/action-item-resonance.svg',
            title: '5-Minute Resonance',
            subtitle: 'Try a short breathing exercise to reset your nervous system.',
            onTap: () {},
          ),
          _Hairline(),
          _OwnChallengeTile(
            asset: 'lib/assets/journal_icons/action-item-acknowledge.svg',
            title: "Acknowledge a 'Win'",
            subtitle: 'Journal briefly about one small success from this morning.',
            onTap: () {},
          ),
        ] else ...[
          _OtherChallengeTile(
            category: 'SOCIAL CHALLENGE',
            title: '7 Days of Gratitude',
            status: 'COMPLETED OCT 12',
            trailing: const Icon(Icons.check_circle, size: 22, color: _kProfileAccentBlue),
          ),
          _Hairline(),
          _OtherChallengeTile(
            category: 'SOLO QUEST',
            title: 'Midnight Reflection',
            status: 'COMPLETED OCT 10',
            trailing: const Icon(Icons.check_circle, size: 22, color: _kProfileAccentBlue),
          ),
          _Hairline(),
          _OtherChallengeTile(
            category: 'INSIGHT BOOST',
            title: 'Digital Minimalism',
            status: 'IN PROGRESS · ENDS TODAY',
            trailing: Icon(Icons.hourglass_empty, size: 22, color: AppColors.labelTertiary),
          ),
        ],
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.divider);
  }
}

class _OwnChallengeTile extends StatelessWidget {
  const _OwnChallengeTile({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.06),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                asset,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.playfair(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Icon(
                Icons.chevron_right,
                size: 22,
                color: AppColors.labelTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherChallengeTile extends StatelessWidget {
  const _OtherChallengeTile({
    required this.category,
    required this.title,
    required this.status,
    required this.trailing,
  });

  final String category;
  final String title;
  final String status;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: AppTextStyles.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: AppColors.labelTertiary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTextStyles.playfair(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: AppColors.labelSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  trailing,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowMessageRow extends StatelessWidget {
  const _FollowMessageRow({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, size: 18, color: Colors.white.withValues(alpha: 0.95)),
                    const SizedBox(width: 10),
                    Text(
                      'FOLLOW ${displayName.toUpperCase()}',
                      style: AppTextStyles.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mail_outline, size: 20, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
