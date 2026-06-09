import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/models/inbox_filter.dart';
import '../../data/models/item.dart';
import '../../data/repositories/inbox_repository.dart';
import 'inbox_controller.dart';
import '../shared/quick_edit_sheet.dart';

enum InboxTab { open, ideas, done }

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  InboxTab _tab = InboxTab.open;

  @override
  Widget build(BuildContext context) {
    final noDateAsync = ref.watch(inboxItemsProvider(InboxFilter.noDate));
    final doneAsync = ref.watch(inboxItemsProvider(InboxFilter.done));

    final allNoDate = noDateAsync.valueOrNull ?? [];
    final openItems =
        allNoDate.where((i) => i.type == ItemType.action).toList();
    final ideaItems =
        allNoDate.where((i) => i.type == ItemType.idea).toList();
    final doneItems = doneAsync.valueOrNull ?? [];

    final canPop = Navigator.canPop(context);

    final items = switch (_tab) {
      InboxTab.open => openItems,
      InboxTab.ideas => ideaItems,
      InboxTab.done => doneItems,
    };

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (canPop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: kTextPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inbox',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                        ),
                      ),
                      Text(
                        'Things waiting for a decision',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InboxFilterTabs(
              selected: _tab,
              onSelect: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? InboxEmptyState(tab: _tab)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = items[i];

                        if (_tab == InboxTab.ideas) {
                          return IdeaItemCard(
                            item: item,
                            onTurnIntoTask: () => ref
                                .read(inboxRepositoryProvider)
                                .updateItemType(item.id, ItemType.action),
                            onArchive: () => ref
                                .read(inboxRepositoryProvider)
                                .markDone(item.id, done: true),
                          );
                        }

                        return InboxItemCard(
                          item: item,
                          onToggle: (done) => ref
                              .read(inboxRepositoryProvider)
                              .markDone(item.id, done: done),
                          onScheduleToday: () {
                            final now = DateTime.now();
                            ref.read(inboxRepositoryProvider).updateItem(
                                  item.id,
                                  scheduledAt: DateTime(
                                      now.year, now.month, now.day, 9),
                                );
                          },
                          onScheduleTomorrow: () {
                            final now = DateTime.now();
                            final t = now.add(const Duration(days: 1));
                            ref.read(inboxRepositoryProvider).updateItem(
                                  item.id,
                                  scheduledAt:
                                      DateTime(t.year, t.month, t.day, 9),
                                );
                          },
                          onPickDate: () async {
                            final result = await showQuickEditSheet(
                              context,
                              initialTitle: item.title,
                              initialDate: item.scheduledAt,
                              initialPerson: item.person,
                            );
                            if (result == null || !context.mounted) return;
                            await ref.read(inboxRepositoryProvider).updateItem(
                                  item.id,
                                  title: result.title,
                                  scheduledAt: result.date,
                                  person: result.person,
                                );
                          },
                          onDelete: () => ref
                              .read(inboxRepositoryProvider)
                              .deleteItem(item.id),
                          onEdit: () async {
                            final result = await showQuickEditSheet(
                              context,
                              initialTitle: item.title,
                              initialDate: item.scheduledAt,
                              initialPerson: item.person,
                            );
                            if (result == null || !context.mounted) return;
                            await ref.read(inboxRepositoryProvider).updateItem(
                                  item.id,
                                  title: result.title,
                                  scheduledAt: result.date,
                                  person: result.person,
                                );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter tabs
// ---------------------------------------------------------------------------

class InboxFilterTabs extends StatelessWidget {
  final InboxTab selected;
  final ValueChanged<InboxTab> onSelect;

  const InboxFilterTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _labels = {
    InboxTab.open: 'Open',
    InboxTab.ideas: 'Ideas',
    InboxTab.done: 'Done',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: InboxTab.values.map((tab) {
          final isSelected = selected == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kPrimary : kDivider,
                  ),
                ),
                child: Text(
                  _labels[tab]!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : kTextSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inbox item card (Open + Done tabs)
// ---------------------------------------------------------------------------

class InboxItemCard extends StatelessWidget {
  final ItemRow item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onScheduleToday;
  final VoidCallback onScheduleTomorrow;
  final VoidCallback onPickDate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const InboxItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onScheduleToday,
    required this.onScheduleTomorrow,
    required this.onPickDate,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isAction = item.type == ItemType.action;
    final typeLabel = isAction ? 'Action' : 'Idea';
    final typeColor = isAction ? kPrimary : const Color(0xFF3B82F6);
    final showQuickActions = !item.isDone;

    return GestureDetector(
      onLongPress: onEdit,
      child: Container(
        decoration: kCardDecoration(radius: 20),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: GestureDetector(
                    onTap: () => onToggle(!item.isDone),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: item.isDone ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.isDone ? kPrimary : kDivider,
                          width: 2,
                        ),
                      ),
                      child: item.isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.isDone ? kTextSecondary : kTextPrimary,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: kTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Chip(label: typeLabel, color: typeColor),
              ],
            ),
            if (item.scheduledAt != null || item.person != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Wrap(
                  spacing: 6,
                  children: [
                    if (item.scheduledAt != null)
                      _Chip(
                        label: _formatDate(item.scheduledAt!),
                        color: const Color(0xFFFF8C00),
                        icon: Icons.schedule_rounded,
                      ),
                    if (item.person != null)
                      _Chip(
                        label: item.person!,
                        color: const Color(0xFF8B5CF6),
                        icon: Icons.person_outline_rounded,
                      ),
                  ],
                ),
              ),
            ],
            if (showQuickActions) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Row(
                  children: [
                    QuickActionButton(
                        label: 'Today', onTap: onScheduleToday),
                    const SizedBox(width: 6),
                    QuickActionButton(
                        label: 'Tomorrow', onTap: onScheduleTomorrow),
                    const SizedBox(width: 6),
                    QuickActionButton(
                        label: 'Pick date', onTap: onPickDate),
                    const Spacer(),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_outlined,
                          size: 18, color: kTextSecondary),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${dt.day}/${dt.month}';
  }
}

// ---------------------------------------------------------------------------
// Idea item card
// ---------------------------------------------------------------------------

class IdeaItemCard extends StatelessWidget {
  final ItemRow item;
  final VoidCallback onTurnIntoTask;
  final VoidCallback onArchive;

  const IdeaItemCard({
    super.key,
    required this.item,
    required this.onTurnIntoTask,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(radius: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _Chip(label: 'Idea', color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _IdeaActionButton(
                label: 'Turn into task',
                color: kPrimary,
                onTap: onTurnIntoTask,
              ),
              const SizedBox(width: 8),
              _IdeaActionButton(
                label: 'Archive',
                color: kTextSecondary,
                onTap: onArchive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdeaActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IdeaActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action button
// ---------------------------------------------------------------------------

class QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kDivider),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kTextSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class InboxEmptyState extends StatelessWidget {
  final InboxTab tab;

  const InboxEmptyState({super.key, required this.tab});

  IconData get _icon => switch (tab) {
        InboxTab.open => Icons.inbox_rounded,
        InboxTab.ideas => Icons.lightbulb_outline_rounded,
        InboxTab.done => Icons.check_circle_outline_rounded,
      };

  Color get _iconColor => switch (tab) {
        InboxTab.open || InboxTab.done => kPrimary,
        InboxTab.ideas => const Color(0xFFF59E0B),
      };

  String get _title => switch (tab) {
        InboxTab.open => 'Inbox clear',
        InboxTab.ideas => 'No ideas yet',
        InboxTab.done => 'Nothing completed yet',
      };

  String get _subtitle => switch (tab) {
        InboxTab.open =>
          'Things without a date will appear here after recording.',
        InboxTab.ideas =>
          'Record thoughts and Brain Inbox will capture your ideas.',
        InboxTab.done => 'Completed items will appear here.',
      };

  bool get _showButton => tab == InboxTab.open;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _iconColor.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              _title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (_showButton) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.recording),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Record a thought',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
