import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/capture/home_screen.dart';
import '../features/capture/text_capture_sheet.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/profile/profile_screen.dart';
import 'router.dart';
import 'theme.dart';

part 'shell.g.dart';

@riverpod
class ShellTab extends _$ShellTab {
  @override
  int build() => 0;

  void switchTo(int index) => state = index;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = [
    HomeScreen(),
    InboxScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabProvider);

    void onRecord() => Navigator.pushNamed(context, AppRoutes.recording);

    void onFabLongPress() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _CaptureChoiceSheet(
          onVoice: () {
            Navigator.pop(context);
            onRecord();
          },
          onText: () {
            Navigator.pop(context);
            showTextCaptureSheet(context, ref);
          },
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: _BottomNav(
        index: index,
        onTap: (i) => ref.read(shellTabProvider.notifier).switchTo(i),
        onRecord: onRecord,
        onRecordLongPress: onFabLongPress,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onRecord;
  final VoidCallback onRecordLongPress;

  const _BottomNav({
    required this.index,
    required this.onTap,
    required this.onRecord,
    required this.onRecordLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.checklist_outlined,
                activeIcon: Icons.checklist_rounded,
                label: 'Inbox',
                selected: index == 1,
                onTap: () => onTap(1),
              ),
              // Center mic FAB — tap to record, long press for voice/text choice
              GestureDetector(
                onTap: onRecord,
                onLongPress: onRecordLongPress,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimaryLight, kPrimaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withAlpha(120),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'Schedule',
                selected: index == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                selected: index == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? kPrimary : kTextSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kPrimary : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureChoiceSheet extends StatelessWidget {
  final VoidCallback onVoice;
  final VoidCallback onText;
  const _CaptureChoiceSheet({required this.onVoice, required this.onText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 32),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _ChoiceTile(
            icon: Icons.mic_rounded,
            label: 'Voice capture',
            subtitle: 'Speak your thoughts out loud',
            color: kPrimary,
            onTap: onVoice,
          ),
          const SizedBox(height: 12),
          _ChoiceTile(
            icon: Icons.edit_rounded,
            label: 'Type instead',
            subtitle: 'Write your brain dump as text',
            color: const Color(0xFF6366F1),
            onTap: onText,
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
