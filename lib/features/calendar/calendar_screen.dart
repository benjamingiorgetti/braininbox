import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/models/calendar_event.dart';
import '../../data/models/inbox_filter.dart';
import '../../data/models/item.dart';
import '../../data/repositories/inbox_repository.dart';
import '../../data/services/google_calendar_service.dart';
import '../shared/quick_edit_sheet.dart';

enum ScheduleFilter { all, tasks, reminders, events }

enum CalendarViewMode { week, month }

const double _kHourHeight = 56.0;
const double _kTimeLabelWidth = 52.0;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late final DateTime _today;
  late final DateTime _todayWeekStart;
  late final PageController _weekPageCtrl;
  static const int _kBasePage = 5000;

  DateTime _selectedDay = DateTime.now();
  late DateTime _focusedMonth;
  late int _currentWeekPage;
  List<CalendarEvent> _gcalEvents = [];
  ScheduleFilter _filter = ScheduleFilter.all;
  CalendarViewMode _viewMode = CalendarViewMode.week;
  bool? _gcalSignedIn;
  late final Stream<List<ItemRow>> _allItemsStream;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _todayWeekStart = _weekStartFor(_today);
    _selectedDay = _today;
    _focusedMonth = DateTime(now.year, now.month);
    _currentWeekPage = _kBasePage;
    _weekPageCtrl = PageController(initialPage: _kBasePage);

    final repo = ref.read(inboxRepositoryProvider);
    _allItemsStream = _buildAllItemsStream(repo);

    _checkGcalSignIn();
    _fetchGcalEvents(_focusedMonth);
  }

  @override
  void dispose() {
    _weekPageCtrl.dispose();
    super.dispose();
  }

  // Sunday-based week start: day.weekday % 7 → 0 for Sun, 1 for Mon, …, 6 for Sat.
  static DateTime _weekStartFor(DateTime day) =>
      day.subtract(Duration(days: day.weekday % 7));

  String _monthLabel(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.year}';

  Future<void> _checkGcalSignIn() async {
    final gcal = ref.read(googleCalendarServiceProvider);
    final signedIn = await gcal.isSignedInAsync;
    if (mounted) setState(() => _gcalSignedIn = signedIn);
  }

  Future<void> _fetchGcalEvents(DateTime month) async {
    final gcal = ref.read(googleCalendarServiceProvider);
    if (!await gcal.isSignedInAsync) return;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final events = await gcal.fetchEvents(start, end);
    if (mounted) setState(() => _gcalEvents = events);
  }

  Stream<List<ItemRow>> _buildAllItemsStream(InboxRepository repo) {
    return Stream.multi((controller) {
      List<ItemRow> upcoming = [];
      List<ItemRow> today = [];
      List<ItemRow> done = [];
      void emit() => controller.add([...upcoming, ...today, ...done]);
      repo.watchInbox(InboxFilter.upcoming).listen((v) {
        upcoming = v;
        emit();
      });
      repo.watchInbox(InboxFilter.today).listen((v) {
        today = v;
        emit();
      });
      repo.watchInbox(InboxFilter.done).listen((v) {
        done = v;
        emit();
      });
    });
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = DateTime(day.year, day.month, day.day));
  }

  void _jumpToWeekOf(DateTime day) {
    final diff = _weekStartFor(day).difference(_todayWeekStart).inDays ~/ 7;
    if (_weekPageCtrl.hasClients) {
      _weekPageCtrl.jumpToPage(_kBasePage + diff);
    }
  }

  void _showEventDetail(BuildContext ctx, {required ItemRow item}) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailSheet(
        item: item,
        onToggleDone: () {
          ref
              .read(inboxRepositoryProvider)
              .markDone(item.id, done: !item.isDone);
          Navigator.pop(ctx);
        },
        onEdit: () async {
          Navigator.pop(ctx);
          final result = await showQuickEditSheet(
            ctx,
            initialTitle: item.title,
            initialDate: item.scheduledAt,
            initialPerson: item.person,
          );
          if (result == null || !mounted) return;
          await ref.read(inboxRepositoryProvider).updateItem(
                item.id,
                title: result.title,
                scheduledAt: result.date,
                person: result.person,
              );
        },
        onDelete: () {
          ref.read(inboxRepositoryProvider).deleteItem(item.id);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: StreamBuilder<List<ItemRow>>(
          stream: _allItemsStream,
          builder: (context, snapshot) {
            final allItems = snapshot.data ?? [];

            final daysWithItems = <DateTime>{};
            for (final item in allItems) {
              if (item.scheduledAt != null) {
                daysWithItems.add(DateTime(item.scheduledAt!.year,
                    item.scheduledAt!.month, item.scheduledAt!.day));
              }
            }
            final gcalDays = <DateTime>{
              for (final e in _gcalEvents)
                DateTime(e.start.year, e.start.month, e.start.day),
            };

            final sel = _selectedDay;

            // Normalised GCal titles for the selected day (used for dedup).
            final gcalTitlesForDay = _gcalEvents
                .where((e) =>
                    DateTime(e.start.year, e.start.month, e.start.day) == sel)
                .map((e) => e.title.toLowerCase().trim())
                .toSet();

            final dayDbItems = allItems.where((item) {
              if (item.scheduledAt == null) return false;
              // Skip items with no confirmed time — they belong in Inbox, not calendar.
              if (item.needsReview) return false;
              final d = DateTime(item.scheduledAt!.year,
                  item.scheduledAt!.month, item.scheduledAt!.day);
              if (d != sel) return false;
              // Dedup: hide DB item if a GCal event with the same title exists today.
              if (gcalTitlesForDay.contains(item.title.toLowerCase().trim())) {
                return false;
              }
              return true;
            }).toList()
              ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));

            final dayGcalEvents = _gcalEvents.where((e) {
              final d = DateTime(e.start.year, e.start.month, e.start.day);
              return d == sel;
            }).toList()
              ..sort((a, b) => a.start.compareTo(b.start));

            bool hasTime(ItemRow i) =>
                i.scheduledAt != null &&
                (i.scheduledAt!.hour != 0 || i.scheduledAt!.minute != 0);

            final List<ItemRow> visibleDbItems = dayDbItems;
            final visibleGcalItems = dayGcalEvents;

            final visibleTimedItems = visibleDbItems.where(hasTime).toList();
            final visibleAllDayItems =
                visibleDbItems.where((i) => !hasTime(i)).toList();

            final subLabel = _viewMode == CalendarViewMode.week
                ? _monthLabel(sel)
                : _monthLabel(_focusedMonth);

            return Column(
              children: [
                // ── Row 1: title + Week/Month toggle ─────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Schedule',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      WeekMonthToggle(
                        selected: _viewMode,
                        onSelect: (mode) {
                          if (mode == CalendarViewMode.month) {
                            setState(() {
                              _viewMode = CalendarViewMode.month;
                              _focusedMonth = DateTime(
                                  _selectedDay.year, _selectedDay.month);
                            });
                          } else {
                            final day = _selectedDay;
                            setState(() => _viewMode = CalendarViewMode.week);
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _jumpToWeekOf(day));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // ── Row 2: prev/next chevrons + month label + Today link ──
                _SubheaderNavRow(
                  label: subLabel,
                  showToday: _selectedDay != _today,
                  onPrev: _viewMode == CalendarViewMode.week
                      ? () => _weekPageCtrl.animateToPage(
                            _currentWeekPage - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          )
                      : () {
                          final m = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1);
                          setState(() => _focusedMonth = m);
                          _fetchGcalEvents(m);
                        },
                  onNext: _viewMode == CalendarViewMode.week
                      ? () => _weekPageCtrl.animateToPage(
                            _currentWeekPage + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          )
                      : () {
                          final m = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1);
                          setState(() => _focusedMonth = m);
                          _fetchGcalEvents(m);
                        },
                  onToday: () {
                    if (_viewMode == CalendarViewMode.week) {
                      setState(() => _selectedDay = _today);
                      _weekPageCtrl.animateToPage(
                        _kBasePage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      setState(() {
                        _selectedDay = _today;
                        _focusedMonth =
                            DateTime(_today.year, _today.month);
                      });
                    }
                  },
                ),
                // ── GCal connect prompt ───────────────────────────────────
                if (_gcalSignedIn == false)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: CalendarConnectBanner(
                      isConnected: false,
                      onConnect: () async {
                        final gcal = ref.read(googleCalendarServiceProvider);
                        final ok = await gcal.signIn();
                        if (ok && mounted) {
                          setState(() => _gcalSignedIn = true);
                          _fetchGcalEvents(_focusedMonth);
                        }
                      },
                    ),
                  ),
                // ── Week strip + filters + header + content (week only) ──
                if (_viewMode == CalendarViewMode.week) ...[
                  const SizedBox(height: 4),
                  _WeekStrip(
                    pageController: _weekPageCtrl,
                    todayWeekStart: _todayWeekStart,
                    kBasePage: _kBasePage,
                    today: _today,
                    selectedDay: _selectedDay,
                    daysWithItems: daysWithItems,
                    gcalDays: gcalDays,
                    onDaySelected: _selectDay,
                    onPageChanged: (page) =>
                        setState(() => _currentWeekPage = page),
                  ),
                  _DayHeader(
                    selectedDay: sel,
                    today: _today,
                    itemCount: visibleTimedItems.length +
                        visibleAllDayItems.length +
                        visibleGcalItems.length,
                  ),
                  Expanded(
                    child: _DayTimeline(
                      key: ValueKey(sel),
                      selectedDay: sel,
                      today: _today,
                      timedItems: visibleTimedItems,
                      allDayItems: visibleAllDayItems,
                      gcalEvents: visibleGcalItems,
                      onItemTap: (item) =>
                          _showEventDetail(context, item: item),
                      onGcalTap: (_) {},
                    ),
                  ),
                ]
                // ── Month grid + filters + agenda (month only) ────────────
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: MonthCalendarView(
                              focusedMonth: _focusedMonth,
                              selectedDay: _selectedDay,
                              daysWithItems: daysWithItems,
                              gcalDays: gcalDays,
                              onDaySelected: _selectDay,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: ScheduleFilterTabs(
                              selected: _filter,
                              onSelect: (f) => setState(() => _filter = f),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            child: _MonthDayAgenda(
                              selectedDay: _selectedDay,
                              today: _today,
                              items: visibleDbItems,
                              gcalEvents: visibleGcalItems,
                              onItemTap: (item) =>
                                  _showEventDetail(context, item: item),
                              onViewInWeek: () {
                                final day = _selectedDay;
                                setState(
                                    () => _viewMode = CalendarViewMode.week);
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _jumpToWeekOf(day));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subheader nav row — "June 2026" + left/right chevrons
// ---------------------------------------------------------------------------

class _SubheaderNavRow extends StatelessWidget {
  final String label;
  final bool showToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _SubheaderNavRow({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    this.showToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: kTextSecondary, size: 20),
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: kTextSecondary, size: 20),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          if (showToday) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToday,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day header — shows selected day name + item count
// ---------------------------------------------------------------------------

class _DayHeader extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime today;
  final int itemCount;

  const _DayHeader({
    required this.selectedDay,
    required this.today,
    required this.itemCount,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _label {
    final diff = selectedDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${_weekdays[selectedDay.weekday - 1]}, '
        '${_months[selectedDay.month - 1]} ${selectedDay.day}';
  }

  String get _sub => itemCount == 0
      ? 'Nothing scheduled'
      : '$itemCount ${itemCount == 1 ? 'item' : 'items'} scheduled';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week / Month toggle
// ---------------------------------------------------------------------------

class WeekMonthToggle extends StatelessWidget {
  final CalendarViewMode selected;
  final ValueChanged<CalendarViewMode> onSelect;

  const WeekMonthToggle({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Week',
            isSelected: selected == CalendarViewMode.week,
            onTap: () => onSelect(CalendarViewMode.week),
          ),
          _Segment(
            label: 'Month',
            isSelected: selected == CalendarViewMode.month,
            onTap: () => onSelect(CalendarViewMode.month),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : kTextSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GCal connect / connected banner
// ---------------------------------------------------------------------------

class CalendarConnectBanner extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback? onManage;

  const CalendarConnectBanner({
    super.key,
    required this.isConnected,
    required this.onConnect,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isConnected
        ? Icons.check_circle_outline_rounded
        : Icons.calendar_today_outlined;
    final iconColor = isConnected ? kPrimary : kTextSecondary;
    final text = isConnected
        ? 'Google Calendar connected'
        : 'Google Calendar not connected';
    final ctaLabel = isConnected ? 'Manage' : 'Connect';
    final ctaColor = isConnected ? kTextSecondary : kPrimary;
    final ctaAction = isConnected ? (onManage ?? () {}) : onConnect;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: ctaAction,
            child: Text(
              ctaLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ctaColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week strip — infinite PageView of 7-day rows
// ---------------------------------------------------------------------------

class _WeekStrip extends StatelessWidget {
  final PageController pageController;
  final DateTime todayWeekStart;
  final int kBasePage;
  final DateTime today;
  final DateTime selectedDay;
  final Set<DateTime> daysWithItems;
  final Set<DateTime> gcalDays;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<int> onPageChanged;

  const _WeekStrip({
    required this.pageController,
    required this.todayWeekStart,
    required this.kBasePage,
    required this.today,
    required this.selectedDay,
    required this.daysWithItems,
    required this.gcalDays,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemBuilder: (ctx, page) {
          final ws = todayWeekStart.add(Duration(days: (page - kBasePage) * 7));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeekRow(
              weekStart: ws,
              today: today,
              selectedDay: selectedDay,
              daysWithItems: daysWithItems,
              gcalDays: gcalDays,
              onDaySelected: onDaySelected,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week row — 7 equally-spaced day cells
// ---------------------------------------------------------------------------

class _WeekRow extends StatelessWidget {
  final DateTime weekStart;
  final DateTime today;
  final DateTime selectedDay;
  final Set<DateTime> daysWithItems;
  final Set<DateTime> gcalDays;
  final ValueChanged<DateTime> onDaySelected;

  const _WeekRow({
    required this.weekStart,
    required this.today,
    required this.selectedDay,
    required this.daysWithItems,
    required this.gcalDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        return Expanded(
          child: _WeekDayCell(
            day: day,
            isToday: day == today,
            isSelected: day == selectedDay,
            hasDot: daysWithItems.contains(day) || gcalDays.contains(day),
            onTap: () => onDaySelected(day),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Week day cell
// ---------------------------------------------------------------------------

class _WeekDayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool hasDot;
  final VoidCallback onTap;

  const _WeekDayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasDot,
    required this.onTap,
  });

  // Indexed by day.weekday % 7: 0=Sun, 1=Mon, …, 6=Sat
  static const _abbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _abbr[day.weekday % 7],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? kPrimary : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: kPrimary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? kPrimary
                          : kTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          hasDot
              ? Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kPrimary.withAlpha(160),
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day timeline — hourly grid with positioned event blocks
// ---------------------------------------------------------------------------

class _DayTimeline extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime today;
  final List<ItemRow> timedItems;
  final List<ItemRow> allDayItems;
  final List<CalendarEvent> gcalEvents;
  final void Function(ItemRow) onItemTap;
  final void Function(CalendarEvent) onGcalTap;

  const _DayTimeline({
    super.key,
    required this.selectedDay,
    required this.today,
    required this.timedItems,
    required this.allDayItems,
    required this.gcalEvents,
    required this.onItemTap,
    required this.onGcalTap,
  });

  @override
  State<_DayTimeline> createState() => _DayTimelineState();
}

class _DayTimelineState extends State<_DayTimeline> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final isToday = widget.selectedDay == widget.today;

    final int targetHour;
    if (isToday) {
      // Find the next upcoming timed item (at or after now).
      DateTime? nextUpcoming;
      for (final item in widget.timedItems) {
        final t = item.scheduledAt!;
        if (!t.isBefore(now) &&
            (nextUpcoming == null || t.isBefore(nextUpcoming))) {
          nextUpcoming = t;
        }
      }
      for (final e in widget.gcalEvents.where((e) => !e.isAllDay)) {
        if (!e.start.isBefore(now) &&
            (nextUpcoming == null || e.start.isBefore(nextUpcoming))) {
          nextUpcoming = e.start;
        }
      }
      // Scroll to 1 hour before next upcoming event; if none, use current time.
      final anchor = nextUpcoming ?? now;
      targetHour = (anchor.hour - 1).clamp(0, 23);
    } else {
      // Other days: scroll to 1 hour before earliest item, or 8 AM.
      int? earliest;
      for (final item in widget.timedItems) {
        final h = item.scheduledAt!.hour;
        if (earliest == null || h < earliest) earliest = h;
      }
      for (final e in widget.gcalEvents.where((e) => !e.isAllDay)) {
        final h = e.start.hour;
        if (earliest == null || h < earliest) earliest = h;
      }
      targetHour = earliest != null ? (earliest - 1).clamp(0, 23) : 8;
    }

    final offset = (targetHour * _kHourHeight).clamp(0.0, 23.0 * _kHourHeight);
    _scrollCtrl = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  double _topFor(DateTime dt) =>
      dt.hour * _kHourHeight + dt.minute / 60.0 * _kHourHeight;

  static String _fmt12(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  Widget _dbBlock(ItemRow item) {
    final color =
        item.type == ItemType.action ? kPrimary : const Color(0xFF3B82F6);
    final isToday = widget.selectedDay == widget.today;
    final isPast =
        isToday && item.scheduledAt!.isBefore(DateTime.now()) && !item.isDone;
    return Positioned(
      top: _topFor(item.scheduledAt!),
      left: _kTimeLabelWidth + 4,
      right: 8,
      child: GestureDetector(
        onTap: () => widget.onItemTap(item),
        child: _TimelineBlock(
          title: item.title,
          timeLabel: _fmt12(item.scheduledAt!),
          color: color,
          isDone: item.isDone,
          isPast: isPast,
        ),
      ),
    );
  }

  Widget _gcalBlock(CalendarEvent event) {
    double? height;
    if (event.end != null) {
      final mins = event.end!.difference(event.start).inMinutes;
      height = (mins / 60.0) * _kHourHeight;
      if (height < 36) height = 36;
    }
    return Positioned(
      top: _topFor(event.start),
      left: _kTimeLabelWidth + 4,
      right: 8,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onGcalTap(event),
        child: _TimelineBlock(
          title: event.title,
          timeLabel: _fmt12(event.start),
          color: const Color(0xFF4285F4),
          isDone: false,
          isPast: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gcalTimed = widget.gcalEvents.where((e) => !e.isAllDay).toList();
    final gcalAllDay = widget.gcalEvents.where((e) => e.isAllDay).toList();
    final isToday = widget.selectedDay == widget.today;

    return Column(
      children: [
        if (widget.allDayItems.isNotEmpty || gcalAllDay.isNotEmpty)
          _AllDaySection(
            items: widget.allDayItems,
            gcalAllDay: gcalAllDay,
            onItemTap: widget.onItemTap,
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            child: SizedBox(
              height: 24 * _kHourHeight,
              child: Stack(
                children: [
                  Column(
                    children: List.generate(24, (h) => _HourRow(hour: h)),
                  ),
                  ...widget.timedItems.map(_dbBlock),
                  ...gcalTimed.map(_gcalBlock),
                  if (isToday)
                    Positioned(
                      top: _topFor(DateTime.now()) - 4,
                      left: _kTimeLabelWidth - 4,
                      right: 0,
                      child: const _CurrentTimeLine(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hour row — divider + time label
// ---------------------------------------------------------------------------

class _HourRow extends StatelessWidget {
  final int hour;

  const _HourRow({required this.hour});

  static String _label(int h) {
    if (h == 0) return '';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kHourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kTimeLabelWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _label(hour),
                textAlign: TextAlign.right,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              height: 0.5,
              color: kDivider,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline event block — used for both DB items and GCal events
// ---------------------------------------------------------------------------

class _TimelineBlock extends StatelessWidget {
  final String title;
  final String timeLabel;
  final Color color;
  final bool isDone;
  final bool isPast;

  const _TimelineBlock({
    required this.title,
    required this.timeLabel,
    required this.color,
    required this.isDone,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    // Past items are visually muted; done items are struck-through.
    final bgAlpha = (isPast || isDone) ? 14 : 30;
    final borderColor = (isPast || isDone) ? color.withAlpha(100) : color;
    final titleColor = isDone
        ? kTextSecondary
        : isPast
            ? kTextSecondary
            : kTextPrimary;
    final timeColor = (isPast || isDone) ? color.withAlpha(120) : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(bgAlpha),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
              decoration: isDone ? TextDecoration.lineThrough : null,
              decorationColor: kTextSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                timeLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: timeColor,
                ),
              ),
              if (isPast) ...[
                const SizedBox(width: 5),
                Text(
                  'Past',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary.withAlpha(160),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current-time indicator line
// ---------------------------------------------------------------------------

class _CurrentTimeLine extends StatelessWidget {
  const _CurrentTimeLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(height: 1.5, color: kPrimary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// All-day section — bar above the hourly timeline
// ---------------------------------------------------------------------------

class _AllDaySection extends StatelessWidget {
  final List<ItemRow> items;
  final List<CalendarEvent> gcalAllDay;
  final void Function(ItemRow) onItemTap;

  const _AllDaySection({
    required this.items,
    required this.gcalAllDay,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kDivider, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(_kTimeLabelWidth + 4, 6, 8, 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          ...items.map((item) => _AllDayChip(
                label: item.title,
                color: item.type == ItemType.action
                    ? kPrimary
                    : const Color(0xFF3B82F6),
                onTap: () => onItemTap(item),
              )),
          ...gcalAllDay.map((e) => _AllDayChip(
                label: e.title,
                color: const Color(0xFF4285F4),
                onTap: () {},
              )),
        ],
      ),
    );
  }
}

class _AllDayChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AllDayChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Event detail bottom sheet
// ---------------------------------------------------------------------------

class _EventDetailSheet extends StatelessWidget {
  final ItemRow item;
  final VoidCallback onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventDetailSheet({
    required this.item,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  static const _weekdayShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _fmtDate(DateTime dt) =>
      '${_weekdayShort[dt.weekday - 1]}, ${_monthShort[dt.month - 1]} ${dt.day}, ${dt.year}';

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final isAction = item.type == ItemType.action;
    final hasTime = item.scheduledAt != null &&
        (item.scheduledAt!.hour != 0 || item.scheduledAt!.minute != 0);
    final typeLabel = !isAction
        ? 'Idea'
        : hasTime
            ? 'Reminder'
            : 'Task';

    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        32 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (item.scheduledAt != null) ...[
            _SheetRow(
                icon: Icons.calendar_today_outlined,
                text: _fmtDate(item.scheduledAt!)),
            if (hasTime)
              _SheetRow(
                  icon: Icons.schedule_outlined,
                  text: _fmtTime(item.scheduledAt!)),
          ],
          _SheetRow(icon: Icons.label_outline_rounded, text: typeLabel),
          const _SheetRow(
              icon: Icons.mic_none_rounded, text: 'From voice note'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SheetActionBtn(
                  label: item.isDone ? 'Unmark' : 'Mark done',
                  icon: Icons.check_rounded,
                  onTap: onToggleDone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetActionBtn(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  color: kError,
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SheetRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kTextSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _SheetActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: c.withAlpha(80)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month calendar view
// ---------------------------------------------------------------------------

class MonthCalendarView extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Set<DateTime> daysWithItems;
  final Set<DateTime> gcalDays;
  final ValueChanged<DateTime> onDaySelected;

  const MonthCalendarView({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.daysWithItems,
    required this.gcalDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(radius: 20),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 28,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kTextSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          _CalendarGrid(
            focusedMonth: focusedMonth,
            selectedDay: selectedDay,
            daysWithItems: daysWithItems,
            gcalDays: gcalDays,
            onDaySelected: onDaySelected,
            compact: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month day agenda — shown below the month grid
// ---------------------------------------------------------------------------

class _MonthDayAgenda extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime today;
  final List<ItemRow> items;
  final List<CalendarEvent> gcalEvents;
  final void Function(ItemRow) onItemTap;
  final VoidCallback onViewInWeek;

  const _MonthDayAgenda({
    required this.selectedDay,
    required this.today,
    required this.items,
    required this.gcalEvents,
    required this.onItemTap,
    required this.onViewInWeek,
  });

  static const _weekdayShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static bool _hasTime(ItemRow i) =>
      i.scheduledAt != null &&
      (i.scheduledAt!.hour != 0 || i.scheduledAt!.minute != 0);

  String get _dayLabel {
    final diff = selectedDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${_weekdayShort[selectedDay.weekday - 1]}, '
        '${_monthShort[selectedDay.month - 1]} ${selectedDay.day}';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) {
        final aT = _hasTime(a);
        final bT = _hasTime(b);
        if (aT == bT) return a.scheduledAt!.compareTo(b.scheduledAt!);
        return aT ? -1 : 1;
      });
    final hasAnything = items.isNotEmpty || gcalEvents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _dayLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${items.length + gcalEvents.length} ${items.length + gcalEvents.length == 1 ? 'item' : 'items'} scheduled',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewInWeek,
                child: Text(
                  'Week view',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!hasAnything)
          const _CompactEmptyState()
        else
          Column(
            children: [
              ...gcalEvents.map((e) => _MonthGcalRow(event: e)),
              ...sorted.map(
                (item) => _MonthAgendaRow(
                  item: item,
                  onTap: () => onItemTap(item),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _MonthAgendaRow extends StatelessWidget {
  final ItemRow item;
  final VoidCallback onTap;

  const _MonthAgendaRow({required this.item, required this.onTap});

  static bool _hasTime(ItemRow i) =>
      i.scheduledAt != null &&
      (i.scheduledAt!.hour != 0 || i.scheduledAt!.minute != 0);

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final timed = _hasTime(item);
    final isAction = item.type == ItemType.action;
    final typeLabel = !isAction
        ? 'Idea'
        : timed
            ? 'Reminder'
            : 'Task';
    final typeColor = isAction ? kPrimary : const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: timed ? kPrimary : kTextSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            if (timed) ...[
              Text(
                _fmtTime(item.scheduledAt!),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: kTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _TypePill(label: typeLabel, color: typeColor),
          ],
        ),
      ),
    );
  }
}

class _MonthGcalRow extends StatelessWidget {
  static const _gcalBlue = Color(0xFF4285F4);
  final CalendarEvent event;

  const _MonthGcalRow({required this.event});

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = event.isAllDay ? 'All day' : _fmtTime(event.start);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _gcalBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            timeStr,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const _TypePill(label: 'Calendar', color: _gcalBlue),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter tabs
// ---------------------------------------------------------------------------

class ScheduleFilterTabs extends StatelessWidget {
  final ScheduleFilter selected;
  final ValueChanged<ScheduleFilter> onSelect;

  const ScheduleFilterTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _labels = {
    ScheduleFilter.all: 'All',
    ScheduleFilter.tasks: 'Tasks',
    ScheduleFilter.reminders: 'Reminders',
    ScheduleFilter.events: 'Events',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ScheduleFilter.values.map((f) {
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? kPrimary : kDivider),
                ),
                child: Text(
                  _labels[f]!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
// Type pill
// ---------------------------------------------------------------------------

class _TypePill extends StatelessWidget {
  final String label;
  final Color color;

  const _TypePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact empty state — horizontal card
// ---------------------------------------------------------------------------

class _CompactEmptyState extends StatelessWidget {
  const _CompactEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nothing scheduled',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Record a thought with a date and it will appear here.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.recording),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic_none_rounded,
                          size: 12, color: kPrimary),
                      const SizedBox(width: 3),
                      Text(
                        'Record a thought',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Calendar grid — used by MonthCalendarView
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Set<DateTime> daysWithItems;
  final Set<DateTime> gcalDays;
  final ValueChanged<DateTime> onDaySelected;
  final bool compact;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.daysWithItems,
    required this.gcalDays,
    required this.onDaySelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double cellW = compact ? 28 : 32;
    final double cellH = compact ? 28 : 36;
    final double circleSize = compact ? 22 : 28;
    final double fontSize = compact ? 11 : 12;

    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    final cells = <Widget>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(SizedBox(width: cellW, height: cellH));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(focusedMonth.year, focusedMonth.month, d);
      final isToday = day == today;
      final isSelected = day == selected;
      final hasDot = daysWithItems.contains(day);
      final hasGcal = gcalDays.contains(day);

      cells.add(GestureDetector(
        onTap: () => onDaySelected(day),
        child: SizedBox(
          width: cellW,
          height: cellH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? kPrimary
                      : isToday
                          ? kPrimary.withAlpha(30)
                          : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    '$d',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: fontSize,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? kPrimary
                              : kTextPrimary,
                    ),
                  ),
                ),
              ),
              if ((hasDot || hasGcal) && !isSelected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasDot)
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.only(top: 1, right: 1),
                        decoration: const BoxDecoration(
                            color: kPrimary, shape: BoxShape.circle),
                      ),
                    if (hasGcal)
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: const BoxDecoration(
                            color: Color(0xFF4285F4), shape: BoxShape.circle),
                      ),
                  ],
                ),
              if ((hasDot || hasGcal) && isSelected)
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(180),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: cellW / cellH,
      children: cells,
    );
  }
}
