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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: HeroCaptureCard(repo: repo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _OpenLoopsSection(repo: repo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _TodayCompactSection(repo: repo),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              sliver: SliverToBoxAdapter(
                child: _MomentumCard(repo: repo, analyticsRepo: analyticsRepo),
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

class HeroCaptureCard extends ConsumerWidget {
  final InboxRepository repo;

  const HeroCaptureCard({super.key, required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
          StreamBuilder<List<ItemRow>>(
            stream: repo.watchInbox(InboxFilter.noDate),
            builder: (ctx, snap) {
              final pending = (snap.data ?? []).length;
              return GestureDetector(
                onTap: () =>
                    ref.read(shellTabProvider.notifier).switchTo(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pending == 0
                        ? 'Inbox clear'
                        : '$pending open loop${pending == 1 ? '' : 's'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
// Open loops section — compact preview, max 2 items
// ---------------------------------------------------------------------------

class _OpenLoopsSection extends ConsumerWidget {
  final InboxRepository repo;

  const _OpenLoopsSection({required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<ItemRow>>(
      stream: repo.watchInbox(InboxFilter.noDate),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();

        final preview = items.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Text(
                  'Open loops',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length} captured',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).switchTo(1),
                  child: Text(
                    'View inbox →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Preview rows
            Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                children: preview.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final chipLabel = item.needsReview
                      ? 'Needs time'
                      : item.type == ItemType.idea
                          ? 'Idea'
                          : 'Task';
                  final chipColor = item.needsReview
                      ? kWarning
                      : item.type == ItemType.idea
                          ? const Color(0xFF8B5CF6)
                          : kPrimary;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: chipColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                chipLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: chipColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < preview.length - 1)
                        const Divider(height: 1, color: kDivider),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Today compact section  (calendar preview — lightweight)
// ---------------------------------------------------------------------------

class _TodayCompactSection extends ConsumerWidget {
  final InboxRepository repo;

  const _TodayCompactSection({required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<ItemRow>>(
      stream: repo.watchInbox(InboxFilter.today),
      builder: (ctx, snap) {
        final items = (snap.data ?? [])
            .where((item) => !item.needsReview)
            .take(4)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: kTextSecondary),
                const SizedBox(width: 7),
                Text(
                  'Today',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      ref.read(shellTabProvider.notifier).switchTo(2),
                  child: Text(
                    items.isEmpty ? 'View schedule →' : 'View full schedule →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 21),
                child: Text(
                  'No tasks scheduled',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                ),
              )
            else
              Container(
                decoration: kCardDecoration(radius: 16),
                child: Column(
                  children: items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _TodayCompactRow(item: item),
                        if (i < items.length - 1)
                          const Divider(
                              height: 1, indent: 48, color: kDivider),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TodayCompactRow extends StatelessWidget {
  final ItemRow item;

  const _TodayCompactRow({required this.item});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              item.scheduledAt != null ? _formatTime(item.scheduledAt!) : '—',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: kPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}



