// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/config.dart';
import '../../data/services/revenuecat_service.dart';

const _goals = [
  'Daily tasks',
  'Random ideas',
  'Study',
  'Work',
  'Meetings',
  'Personal reminders',
];

const _painPoints = [
  'In my head',
  'WhatsApp',
  'Notes',
  'Calendar',
  'Too many apps',
  'No system works',
];

const _inputModes = [
  'Voice',
  'Text',
  'Both',
];

const _sources = [
  'TikTok',
  'X / Twitter',
  'Instagram',
  'A friend',
  'App Store',
  'Other',
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  int _goal = 0;
  int _pain = 0;
  int _inputMode = 2;
  int _source = 0;
  String? _usefulness;
  bool _paywallBusy = false;

  int get _totalPages => 12;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _totalPages - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _saveAnswers({bool done = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_goal', _goals[_goal]);
    await prefs.setString('onboarding_pain', _painPoints[_pain]);
    await prefs.setString('onboarding_input_mode', _inputModes[_inputMode]);
    await prefs.setString('onboarding_attribution', _sources[_source]);
    if (_usefulness != null) {
      await prefs.setString('onboarding_usefulness', _usefulness!);
    }
    if (done) {
      await prefs.setBool('onboarding_done', true);
    }
  }

  Future<void> _finish() async {
    await _saveAnswers(done: true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  Future<void> _tryVoice() async {
    await _saveAnswers();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.recording);
  }

  Future<void> _openPaywall() async {
    setState(() => _paywallBusy = true);
    try {
      final premium =
          await ref.read(revenueCatServiceProvider).presentPaywallIfNeeded();
      if (!mounted) return;
      if (premium) {
        await _finish();
      } else {
        _next();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Could not open paywall: $e')),
        );
    } finally {
      if (mounted) setState(() => _paywallBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: _ProgressDots(page: _page, total: _totalPages),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  _HeroPage(onNext: _next),
                  _DemoPage(onNext: _next),
                  _ChoicePage(
                    title: 'What do you want to organize better?',
                    subtitle: 'BrainInbox will tune the first run around this.',
                    options: _goals,
                    selected: _goal,
                    onSelected: (i) => setState(() => _goal = i),
                    onNext: _next,
                  ),
                  _ChoicePage(
                    title: 'Where do those things get lost today?',
                    subtitle: 'Pick the place that feels closest.',
                    options: _painPoints,
                    selected: _pain,
                    onSelected: (i) => setState(() => _pain = i),
                    onNext: _next,
                  ),
                  _ChoicePage(
                    title: 'How do you want to capture things?',
                    subtitle: 'You can use either mode later.',
                    options: _inputModes,
                    selected: _inputMode,
                    onSelected: (i) => setState(() => _inputMode = i),
                    onNext: _next,
                  ),
                  _ChoicePage(
                    title: 'How did you hear about BrainInbox?',
                    subtitle:
                        'This helps us understand where real users come from.',
                    options: _sources,
                    selected: _source,
                    onSelected: (i) => setState(() => _source = i),
                    onNext: _next,
                  ),
                  _BuildingPage(
                    goal: _goals[_goal],
                    pain: _painPoints[_pain],
                    inputMode: _inputModes[_inputMode],
                    onNext: _next,
                  ),
                  _TryPage(onVoice: _tryVoice, onExample: _next),
                  _ResultPage(onNext: _next),
                  _UsefulnessPage(
                    selected: _usefulness,
                    onSelected: (value) => setState(() => _usefulness = value),
                    onNext: _usefulness == null ? null : _next,
                  ),
                  _PaywallStep(
                    busy: _paywallBusy,
                    onOpenPaywall: _openPaywall,
                    onRestore: () async {
                      try {
                        final info = await ref
                            .read(revenueCatServiceProvider)
                            .restorePurchases();
                        final active = info
                                .entitlements
                                .all[AppConfig.revenueCatEntitlementId]
                                ?.isActive ==
                            true;
                        if (!context.mounted) return;
                        if (active) {
                          await _finish();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('No active Premium purchase found.'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Restore failed: $e')),
                        );
                      }
                    },
                    onContinueLimited: _next,
                  ),
                  _ExitOfferPage(
                    onPaywall: _openPaywall,
                    onFinish: _finish,
                    busy: _paywallBusy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.page, required this.total});
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i <= page ? kPrimary : kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _OnboardingFrame extends StatelessWidget {
  const _OnboardingFrame({
    required this.children,
    this.footer,
  });

  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 42),
        Image.asset('assets/icon/app_icon.png', width: 74, height: 74),
        const SizedBox(height: 32),
        Text(
          'Your head,\norganized in seconds.',
          style: GoogleFonts.nunitoSans(
            fontSize: 38,
            height: 1.02,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Say what is on your mind. BrainInbox turns it into actions, ideas, and schedule.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 36),
        const _SpeechCard(
          text:
              'Remind me to call Tomi tomorrow at 10 and save the idea for a TikTok video.',
        ),
      ],
      footer: _PrimaryButton(label: 'Start', onPressed: onNext),
    );
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 20),
        const _Eyebrow(icon: Icons.play_circle_rounded, label: 'Quick demo'),
        const SizedBox(height: 16),
        Text(
          'Watch the transformation.',
          style: GoogleFonts.nunitoSans(
            fontSize: 32,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A messy thought becomes clean structure before you forget it.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        const _SpeechCard(
          text:
              'Call Tomi tomorrow at 10, and keep the idea about a productivity TikTok.',
        ),
        const SizedBox(height: 18),
        const _MiniResultTable(),
      ],
      footer: _PrimaryButton(label: 'I want this', onPressed: onNext),
    );
  }
}

class _ChoicePage extends StatelessWidget {
  const _ChoicePage({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 30,
            height: 1.12,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.4,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(options.length, (i) {
            return _OptionChip(
              label: options[i],
              selected: selected == i,
              onTap: () => onSelected(i),
            );
          }),
        ),
      ],
      footer: _PrimaryButton(label: 'Continue', onPressed: onNext),
    );
  }
}

class _BuildingPage extends StatelessWidget {
  const _BuildingPage({
    required this.goal,
    required this.pain,
    required this.inputMode,
    required this.onNext,
  });

  final String goal;
  final String pain;
  final String inputMode;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 32),
        const _Eyebrow(icon: Icons.auto_awesome_rounded, label: 'Personalized'),
        const SizedBox(height: 16),
        Text(
          'Your system is ready.',
          style: GoogleFonts.nunitoSans(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Based on your answers, BrainInbox will help you capture fast, separate actions from ideas, and send scheduled things where they belong.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _SummaryTile(icon: Icons.track_changes_rounded, label: goal),
        _SummaryTile(icon: Icons.location_off_rounded, label: pain),
        _SummaryTile(icon: Icons.keyboard_voice_rounded, label: inputMode),
      ],
      footer: _PrimaryButton(label: 'See example', onPressed: onNext),
    );
  }
}

class _TryPage extends StatelessWidget {
  const _TryPage({required this.onVoice, required this.onExample});
  final VoidCallback onVoice;
  final VoidCallback onExample;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 28),
        Text(
          'Try the magic moment.',
          style: GoogleFonts.nunitoSans(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Use your own voice if you are ready, or see the instant example first.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 28),
        _ActionPanel(
          icon: Icons.mic_rounded,
          title: 'Try with my voice',
          subtitle: 'Record a real thought and let BrainInbox process it.',
          onTap: onVoice,
        ),
        const SizedBox(height: 12),
        _ActionPanel(
          icon: Icons.bolt_rounded,
          title: 'Use quick example',
          subtitle: 'Skip recording and see the result immediately.',
          onTap: onExample,
        ),
      ],
    );
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 20),
        const _Eyebrow(icon: Icons.done_all_rounded, label: 'Understood'),
        const SizedBox(height: 16),
        Text(
          'This is what BrainInbox found.',
          style: GoogleFonts.nunitoSans(
            fontSize: 32,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 22),
        const _ResultCard(
          icon: Icons.check_circle_rounded,
          label: 'Action',
          title: 'Call Tomi',
        ),
        const SizedBox(height: 12),
        const _ResultCard(
          icon: Icons.event_rounded,
          label: 'Schedule',
          title: 'Tomorrow, 10:00',
        ),
        const SizedBox(height: 12),
        const _ResultCard(
          icon: Icons.lightbulb_rounded,
          label: 'Idea',
          title: 'TikTok video about productivity',
        ),
      ],
      footer: _PrimaryButton(label: 'Save to my BrainInbox', onPressed: onNext),
    );
  }
}

class _UsefulnessPage extends StatelessWidget {
  const _UsefulnessPage({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    const answers = ['Yes, a lot', 'Maybe', 'Not yet'];
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 42),
        Text(
          'Would this help in your day to day?',
          style: GoogleFonts.nunitoSans(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'No App Store rating yet. Just tell us if the transformation feels useful.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 26),
        for (final answer in answers) ...[
          _AnswerRow(
            label: answer,
            selected: selected == answer,
            onTap: () => onSelected(answer),
          ),
          const SizedBox(height: 10),
        ],
      ],
      footer: _PrimaryButton(label: 'Continue', onPressed: onNext),
    );
  }
}

class _PaywallStep extends StatelessWidget {
  const _PaywallStep({
    required this.busy,
    required this.onOpenPaywall,
    required this.onRestore,
    required this.onContinueLimited,
  });

  final bool busy;
  final VoidCallback onOpenPaywall;
  final VoidCallback onRestore;
  final VoidCallback onContinueLimited;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 32),
        const _Eyebrow(icon: Icons.workspace_premium_rounded, label: 'Premium'),
        const SizedBox(height: 16),
        Text(
          'Keep your thoughts from slipping away.',
          style: GoogleFonts.nunitoSans(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Unlock Brain Inbox Premium for unlimited capture, organization, and schedule-ready extraction.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        const _PremiumBullet('Unlimited voice and text captures'),
        const _PremiumBullet('Actions, ideas, and scheduled items'),
        const _PremiumBullet('Restore purchases across devices'),
      ],
      footer: Column(
        children: [
          _PrimaryButton(
            label: busy ? 'Opening paywall...' : 'See Premium plans',
            onPressed: busy ? null : onOpenPaywall,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: busy ? null : onRestore,
            child: const Text('Restore purchase'),
          ),
          TextButton(
            onPressed: busy ? null : onContinueLimited,
            child: const Text('Continue with limited access'),
          ),
        ],
      ),
    );
  }
}

class _ExitOfferPage extends StatelessWidget {
  const _ExitOfferPage({
    required this.onPaywall,
    required this.onFinish,
    required this.busy,
  });

  final VoidCallback onPaywall;
  final VoidCallback onFinish;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      children: [
        const SizedBox(height: 42),
        Text(
          'Before you go.',
          style: GoogleFonts.nunitoSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You can still try BrainInbox with a smaller limit, then upgrade when it earns a place in your routine.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.45,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _ActionPanel(
          icon: Icons.percent_rounded,
          title: 'Check Premium offers',
          subtitle:
              'RevenueCat will show the active monthly, yearly, and lifetime options.',
          onTap: busy ? null : onPaywall,
        ),
        const SizedBox(height: 12),
        _ActionPanel(
          icon: Icons.inbox_rounded,
          title: 'Continue free for now',
          subtitle: 'Start with limited access and upgrade later.',
          onTap: busy ? null : onFinish,
        ),
      ],
    );
  }
}

class _SpeechCard extends StatelessWidget {
  const _SpeechCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1726),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E1726).withAlpha(36),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.graphic_eq_rounded, color: kPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniResultTable extends StatelessWidget {
  const _MiniResultTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(radius: 18),
      child: const Column(
        children: [
          _MiniRow(label: 'Action', value: 'Call Tomi'),
          Divider(height: 1, color: kDivider),
          _MiniRow(label: 'Time', value: 'Tomorrow 10:00'),
          Divider(height: 1, color: kDivider),
          _MiniRow(label: 'Idea', value: 'Productivity TikTok'),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withAlpha(24) : kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimary : kDivider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? kPrimaryDark : kTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(radius: 16),
      child: Row(
        children: [
          Icon(icon, color: kPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: kCardDecoration(radius: 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kPrimaryDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.3,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(radius: 18),
      child: Row(
        children: [
          Icon(icon, color: kPrimary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: kTextSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: kTextPrimary,
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

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withAlpha(22) : kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? kPrimary : kDivider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? kPrimary : kTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBullet extends StatelessWidget {
  const _PremiumBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: kPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kPrimary, size: 18),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: kPrimaryDark,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
