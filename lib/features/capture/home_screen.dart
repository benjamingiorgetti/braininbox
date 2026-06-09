import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../app/shell.dart';
import '../../app/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/models/inbox_filter.dart';
import '../../data/models/item.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/inbox_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeBody();
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody();

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? '';
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(inboxRepositoryProvider);
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _HomeHeader(greeting: _greeting, name: _name),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: HeroCaptureCard(repo: repo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _MomentumCard(repo: repo, analyticsRepo: analyticsRepo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _TodaySection(repo: repo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              sliver: SliverToBoxAdapter(
                child: _NeedsReviewSection(repo: repo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  final String greeting;
  final String name;

  const _HomeHeader({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'there' : name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "What's on your mind?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: kPrimary,
          child: Text(
            initial,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero capture card
// ---------------------------------------------------------------------------

class HeroCaptureCard extends StatelessWidget {
  final InboxRepository repo;

  const HeroCaptureCard({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryLight, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withAlpha(80),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clear your head',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Speak freely. Brain Inbox will organize it.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(180),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<int>(
            stream: repo.watchPendingCount(),
            builder: (ctx, snap) {
              final pending = snap.data ?? 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pending open loops',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.recording),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic_rounded, color: kPrimaryDark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start recording',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Daily momentum card
// ---------------------------------------------------------------------------

class _MomentumCard extends StatelessWidget {
  final InboxRepository repo;
  final AnalyticsRepository analyticsRepo;

  const _MomentumCard({required this.repo, required this.analyticsRepo});

  static int _computeStreak(List<DateTime> days) {
    if (days.isEmpty) return 0;
    final sorted = [...days]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime? prev;
    for (final d in sorted) {
      final day = DateTime(d.year, d.month, d.day);
      if (prev == null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (day == today || day == today.subtract(const Duration(days: 1))) {
          streak = 1;
          prev = day;
        } else {
          break;
        }
      } else if (day == prev.subtract(const Duration(days: 1))) {
        streak++;
        prev = day;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: repo.watchTodayScheduledCount(),
      builder: (ctx, totalSnap) {
        return StreamBuilder<int>(
          stream: repo.watchTodayCompletedCount(),
          builder: (ctx2, doneSnap) {
            return FutureBuilder<List<DateTime>>(
              future: analyticsRepo.captureDays(),
              builder: (ctx3, streakSnap) {
                final total = totalSnap.data ?? 0;
                final done = doneSnap.data ?? 0;
                final streak = _computeStreak(streakSnap.data ?? []);
                final pct = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

                final streakLabel = streak == 0
                    ? 'Start your streak'
                    : '🔥 $streak day${streak == 1 ? '' : 's'}';
                final streakSub =
                    streak == 0 ? 'Record today to begin' : 'Keep it going';

                return Container(
                  decoration: kCardDecoration(radius: 20),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily momentum',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kTextSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  total == 0
                                      ? 'No tasks planned'
                                      : '$done of $total done',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  total == 0
                                      ? '0 planned today'
                                      : '${(pct * 100).round()}% completed',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: kTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Container(
                            width: 1,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            color: kDivider,
                          ),
                          // Streak column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  streakLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  streakSub,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: kTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (total > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 4,
                            backgroundColor: kDivider,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kPrimary),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Today section
// ---------------------------------------------------------------------------

class _TodaySection extends ConsumerWidget {
  final InboxRepository repo;

  const _TodaySection({required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<ItemRow>>(
      stream: repo.watchInbox(InboxFilter.today),
      builder: (ctx, snap) {
        // Exclude items that still need review — they belong in the section below.
        final items = (snap.data ?? [])
            .where((item) => !item.needsReview)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Today',
              subtitle: 'Scheduled from your voice notes',
              actionLabel: 'View schedule →',
              onAction: () =>
                  ref.read(shellTabProvider.notifier).switchTo(2),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _emptyStateCard(
                'Nothing planned today',
                'Say: "Tomorrow at 10, remind me to send the invoice."',
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TodayPreviewCard(item: item),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Needs review section
// ---------------------------------------------------------------------------

class _NeedsReviewSection extends ConsumerWidget {
  final InboxRepository repo;

  const _NeedsReviewSection({required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<ItemRow>>(
      stream: repo.watchInbox(InboxFilter.needsReview),
      builder: (ctx, snap) {
        final items = (snap.data ?? []).take(3).toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Needs review',
              subtitle: 'Captured items waiting for a decision',
              actionLabel: 'View inbox →',
              onAction: () =>
                  ref.read(shellTabProvider.notifier).switchTo(1),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReviewItemCard(item: item),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Review item card
// ---------------------------------------------------------------------------

class _ReviewItemCard extends StatelessWidget {
  final ItemRow item;

  const _ReviewItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const Wrap(
                  spacing: 6,
                  children: [
                    _TypePill(
                      label: 'Voice note',
                      color: kTextSecondary,
                      icon: Icons.mic_none_rounded,
                    ),
                    _TypePill(
                      label: 'Review',
                      color: Color(0xFFF59E0B),
                      icon: Icons.flag_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Today preview card
// ---------------------------------------------------------------------------

class TodayPreviewCard extends StatelessWidget {
  final ItemRow item;

  const TodayPreviewCard({super.key, required this.item});

  String _formatTime(DateTime dt) {
    final rawHour = dt.hour;
    final h = rawHour == 0
        ? 12
        : rawHour > 12
            ? rawHour - 12
            : rawHour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = rawHour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(radius: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.scheduledAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(item.scheduledAt!),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          _TypePill(label: item.type == ItemType.idea ? 'Idea' : 'Task'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _TypePill extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const _TypePill({required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? kPrimaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: pillColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: pillColor,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _emptyStateCard(String title, String subtitle) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: kBackground,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kDivider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextSecondary,
          ),
        ),
      ],
    ),
  );
}
