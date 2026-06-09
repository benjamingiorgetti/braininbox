import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/models/item.dart';
import '../../data/models/processing_state.dart';
import '../shared/quick_edit_sheet.dart';
import 'review_controller.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(reviewControllerProvider);
    final notifier = ref.read(reviewControllerProvider.notifier);

    if (items.isEmpty) {
      return _EmptyReviewScreen(transcript: notifier.transcript);
    }

    final actions = items.where((i) => i.type == ItemType.action).toList();
    final ideas = items.where((i) => i.type == ItemType.idea).toList();
    final selectedCount = items.where((i) => i.isSelected).length;
    final totalCount = items.length;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I found $totalCount ${totalCount == 1 ? 'thing' : 'things'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            Text(
              'Review before saving',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: kTextSecondary),
          tooltip: 'Discard',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _TranscriptTile(transcript: notifier.transcript),
                const SizedBox(height: 8),
                if (actions.isNotEmpty) ...[
                  _SectionHeader(label: 'Actions', count: actions.length),
                  ...actions.map((item) => _ItemTile(
                        key: ValueKey(item.tempId),
                        item: item,
                        onToggle: () => notifier.toggleSelection(item.tempId),
                        onDelete: () => notifier.deleteItem(item.tempId),
                        onEdit: () => _openQuickEdit(context, ref, item),
                      )),
                ],
                if (ideas.isNotEmpty) ...[
                  _SectionHeader(label: 'Ideas', count: ideas.length),
                  ...ideas.map((item) => _ItemTile(
                        key: ValueKey(item.tempId),
                        item: item,
                        onToggle: () => notifier.toggleSelection(item.tempId),
                        onDelete: () => notifier.deleteItem(item.tempId),
                        onEdit: () => _openQuickEdit(context, ref, item),
                      )),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _onSave(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                selectedCount > 0
                    ? 'Save to Brain Inbox ($selectedCount)'
                    : 'Save to Brain Inbox',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    // Compute counts BEFORE saving — state is cleared by saveAll().
    final allItems = ref.read(reviewControllerProvider);
    final selected = allItems.where((i) => i.isSelected).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Nothing to save — check at least one item.'),
        ));
      return;
    }

    final scheduled = selected
        .where((i) => i.dateTime != null && i.type == ItemType.action)
        .length;
    final inbox = selected.length - scheduled;

    final saved = await ref.read(reviewControllerProvider.notifier).saveAll();
    if (!saved || !context.mounted) return;

    // Persist latest capture summary for the Home card.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'latest_capture_time', DateTime.now().toIso8601String());
    await prefs.setInt('latest_capture_scheduled', scheduled);
    await prefs.setInt('latest_capture_inbox', inbox);

    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.savedConfirmation,
      arguments: {
        'scheduled': scheduled,
        'inbox': inbox,
        'total': selected.length,
      },
    );
  }

  Future<void> _openQuickEdit(
      BuildContext context, WidgetRef ref, ReviewItem item) async {
    final result = await showQuickEditSheet(
      context,
      initialTitle: item.title,
      initialDate: item.dateTime,
      initialPerson: item.person,
    );
    if (result == null) return;
    ref.read(reviewControllerProvider.notifier).quickEdit(
          item.tempId,
          title: result.title,
          dateTime: result.date,
          person: result.person,
        );
  }
}

// ---------------------------------------------------------------------------
// Destination helpers (pure UI — no data layer change)
// ---------------------------------------------------------------------------

String _destination(ReviewItem item) {
  if (item.type == ItemType.idea) return 'Inbox';
  if (item.needsReview) return 'Needs review';
  if (item.dateTime != null) return 'Schedule';
  return 'Inbox';
}

Color _destinationColor(ReviewItem item) {
  if (item.type == ItemType.idea) return kPrimary;
  if (item.needsReview) return Colors.amber;
  if (item.dateTime != null) return const Color(0xFF3B82F6);
  return kPrimary;
}

IconData _destinationIcon(ReviewItem item) {
  if (item.dateTime != null && item.type != ItemType.idea) {
    return Icons.calendar_today_rounded;
  }
  return Icons.inbox_rounded;
}

// ---------------------------------------------------------------------------
// Empty review screen
// ---------------------------------------------------------------------------

class _EmptyReviewScreen extends StatelessWidget {
  const _EmptyReviewScreen({required this.transcript});
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        title: Text(
          'Review',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inbox_outlined,
                    size: 36, color: kPrimary),
              ),
              const SizedBox(height: 24),
              Text(
                'Nothing actionable found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (transcript.isNotEmpty)
                Text(
                  transcript,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: kTextSecondary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Capture again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transcript accordion
// ---------------------------------------------------------------------------

class _TranscriptTile extends StatefulWidget {
  const _TranscriptTile({required this.transcript});
  final String transcript;

  @override
  State<_TranscriptTile> createState() => _TranscriptTileState();
}

class _TranscriptTileState extends State<_TranscriptTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notes_rounded, size: 14, color: kTextSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.transcript,
                maxLines: _expanded ? null : 2,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
            ),
            Icon(
              _expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              size: 16,
              color: kTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        '$label ($count)',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: kPrimary,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item tile with destination chip
// ---------------------------------------------------------------------------

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final ReviewItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final destLabel = _destination(item);
    final destColor = _destinationColor(item);
    final destIcon = _destinationIcon(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(item.tempId),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: kError.withAlpha(200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 20),
        ),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isSelected ? kPrimary.withAlpha(60) : kDivider,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              item.isSelected ? kPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.isSelected ? kPrimary : kDivider,
                            width: 2,
                          ),
                        ),
                        child: item.isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.isSelected
                              ? kTextPrimary
                              : kTextSecondary,
                          decoration: item.isSelected
                              ? null
                              : TextDecoration.lineThrough,
                          decorationColor: kTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                // Chips row: destination + date + person
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 34),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MiniChip(
                        label: '→ $destLabel',
                        icon: destIcon,
                        color: destColor,
                      ),
                      if (item.dateTime != null)
                        _MiniChip(
                          label: _shortDate(item.dateTime!),
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFFFF8C00),
                        ),
                      if (item.person != null)
                        _MiniChip(
                          label: item.person!,
                          icon: Icons.person_outline_rounded,
                          color: const Color(0xFF8B5CF6),
                        ),
                      if (item.durationMinutes != null)
                        _MiniChip(
                          label: '${item.durationMinutes} min',
                          icon: Icons.timer_outlined,
                          color: const Color(0xFF6366F1),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    final now = DateTime.now();
    final diff =
        dt.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${dt.day}/${dt.month}';
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
