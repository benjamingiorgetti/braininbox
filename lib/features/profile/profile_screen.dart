import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/config.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/capture_repository.dart';
import '../../data/repositories/inbox_repository.dart';
import '../../data/services/google_calendar_service.dart';
import '../../data/services/revenuecat_service.dart';

const _kGcalBlue = Color(0xFF4285F4);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = '';
  bool _gcalConnected = false;
  String? _gcalEmail;
  bool _micEnabled = false;
  bool _premium = false;
  bool _purchaseBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkMic();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final gcal = ref.read(googleCalendarServiceProvider);
    final connected = await gcal.isSignedInAsync;
    final premium = await _loadPremium();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _gcalConnected = connected;
      _gcalEmail = gcal.currentUserEmail;
      _premium = premium;
    });
  }

  Future<bool> _loadPremium() async {
    try {
      return await ref.read(revenueCatServiceProvider).isPremium();
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkMic() async {
    final recorder = AudioRecorder();
    final ok = await recorder.hasPermission();
    await recorder.dispose();
    if (mounted) setState(() => _micEnabled = ok);
  }

  Future<void> _editProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('This will reset your profile and preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This will permanently delete all your captures, items, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = ref.read(appDatabaseProvider);
    final notes = await db.select(db.voiceNotes).get();
    for (final note in notes) {
      if (note.audioPath != null) {
        final file = File(note.audioPath!);
        if (await file.exists()) await file.delete();
      }
    }
    await db.delete(db.voiceNotes).go();
    await db.delete(db.items).go();
    await db.delete(db.appEvents).go();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://braininbox.app/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openSupport() async {
    final uri = Uri.parse('mailto:support@braininbox.app?subject=Brain%20Inbox%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _toggleGcal() async {
    final gcal = ref.read(googleCalendarServiceProvider);
    if (_gcalConnected) {
      await gcal.signOut();
      setState(() {
        _gcalConnected = false;
        _gcalEmail = null;
      });
    } else {
      final ok = await gcal.signIn();
      if (ok) {
        setState(() {
          _gcalConnected = true;
          _gcalEmail = gcal.currentUserEmail;
        });
      }
    }
  }

  Future<void> _openPaywall() async {
    setState(() => _purchaseBusy = true);
    try {
      final premium =
          await ref.read(revenueCatServiceProvider).presentPaywall();
      if (!mounted) return;
      setState(() => _premium = premium);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open paywall: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _purchaseBusy = true);
    try {
      final info = await ref.read(revenueCatServiceProvider).restorePurchases();
      final premium =
          info.entitlements.all[AppConfig.revenueCatEntitlementId]?.isActive ==
              true;
      if (!mounted) return;
      setState(() => _premium = premium);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            premium
                ? 'Brain Inbox Premium restored.'
                : 'No active Premium purchase found.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  Future<void> _openCustomerCenter() async {
    setState(() => _purchaseBusy = true);
    try {
      final info =
          await ref.read(revenueCatServiceProvider).presentCustomerCenter();
      final premium = RevenueCatService.hasPremium(info);
      if (!mounted) return;
      setState(() => _premium = premium);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer Center is unavailable: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
  }

  int _streak(List<DateTime> days) {
    if (days.isEmpty) return 0;
    final sorted = [...days]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime? prev;
    for (final d in sorted) {
      final day = DateTime(d.year, d.month, d.day);
      if (prev == null) {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        if (day == todayOnly ||
            day == todayOnly.subtract(const Duration(days: 1))) {
          streak = 1;
          prev = day;
        } else {
          break;
        }
      } else {
        if (day == prev.subtract(const Duration(days: 1))) {
          streak++;
          prev = day;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);
    final inboxRepo = ref.watch(inboxRepositoryProvider);
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : 'U';
    final displayName = _name.isEmpty ? 'User' : _name;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Title ────────────────────────────────────────────
              Text(
                'Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // ── User card ────────────────────────────────────────
              _UserProfileCard(initial: initial, name: displayName),
              const SizedBox(height: 16),
              _PremiumCard(
                premium: _premium,
                busy: _purchaseBusy,
                onUpgrade: _openPaywall,
                onRestore: _restorePurchases,
                onManage: _openCustomerCenter,
              ),
              const SizedBox(height: 16),

              // ── Usage stats ──────────────────────────────────────
              FutureBuilder<List<DateTime>>(
                future: analyticsRepo.captureDays(),
                builder: (context, snap) {
                  final days = snap.data ?? [];
                  final streak = _streak(days);
                  final total = days.length;
                  return StreamBuilder<int>(
                    stream: inboxRepo.watchTotalSaved(),
                    builder: (context, savedSnap) {
                      final saved = savedSnap.data ?? 0;
                      return _UsageStatsRow(
                        daysActive: streak,
                        thoughtsCaptured: total,
                        itemsOrganized: saved,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── Integrations ─────────────────────────────────────
              const _SectionLabel('INTEGRATIONS'),
              const SizedBox(height: 10),
              _IntegrationCard(
                connected: _gcalConnected,
                email: _gcalEmail,
                onTap: _toggleGcal,
              ),
              const SizedBox(height: 28),

              // ── Permissions ──────────────────────────────────────
              const _SectionLabel('PERMISSIONS'),
              const SizedBox(height: 10),
              _PermissionsCard(
                micEnabled: _micEnabled,
                gcalConnected: _gcalConnected,
              ),
              const SizedBox(height: 28),

              // ── Account ──────────────────────────────────────────
              const _SectionLabel('ACCOUNT'),
              const SizedBox(height: 10),
              _AccountCard(
                onEditProfile: _editProfile,
                onSignOut: _signOut,
                onDeleteAccount: _deleteAccount,
                onPrivacyPolicy: _openPrivacyPolicy,
                onSupport: _openSupport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User profile card
// ---------------------------------------------------------------------------

class _UserProfileCard extends StatelessWidget {
  final String initial;
  final String name;

  const _UserProfileCard({required this.initial, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: kCardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kPrimary.withAlpha(30),
            child: Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Voice-first productivity',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium card
// ---------------------------------------------------------------------------

class _PremiumCard extends StatelessWidget {
  final bool premium;
  final bool busy;
  final VoidCallback onUpgrade;
  final VoidCallback onRestore;
  final VoidCallback onManage;

  const _PremiumCard({
    required this.premium,
    required this.busy,
    required this.onUpgrade,
    required this.onRestore,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: kCardDecoration(radius: 18),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(22),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: kPrimaryDark,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      premium ? 'Brain Inbox Premium' : 'Upgrade to Premium',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      premium
                          ? 'Active subscription'
                          : 'Unlimited captures and organized output',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : (premium ? onManage : onUpgrade),
                  child: Text(
                    busy
                        ? 'Loading...'
                        : premium
                            ? 'Manage'
                            : 'See plans',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: busy ? null : onRestore,
                child: const Text('Restore'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage stats row
// ---------------------------------------------------------------------------

class _UsageStatsRow extends StatelessWidget {
  final int daysActive;
  final int thoughtsCaptured;
  final int itemsOrganized;

  const _UsageStatsRow({
    required this.daysActive,
    required this.thoughtsCaptured,
    required this.itemsOrganized,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          value: '$daysActive',
          label: 'Days active',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.mic_rounded,
          value: '$thoughtsCaptured',
          label: 'Thoughts captured',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          value: '$itemsOrganized',
          label: 'Items organized',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: kCardDecoration(radius: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: kPrimary),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: kTextSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Integration card — Google Calendar
// ---------------------------------------------------------------------------

class _IntegrationCard extends StatelessWidget {
  final bool connected;
  final String? email;
  final VoidCallback onTap;

  const _IntegrationCard({
    required this.connected,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle =
        connected ? (email ?? 'Connected') : 'Sync dated tasks automatically';

    return Container(
      decoration: kCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kGcalBlue.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: _kGcalBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Google Calendar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      if (connected) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle_rounded,
                            color: kPrimary, size: 14),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style:
                        GoogleFonts.plusJakartaSans(fontSize: 12, color: kTextSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: Text(
                connected ? 'Manage' : 'Connect',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: connected ? kTextSecondary : _kGcalBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Permissions card
// ---------------------------------------------------------------------------

class _PermissionsCard extends StatelessWidget {
  final bool micEnabled;
  final bool gcalConnected;

  const _PermissionsCard({
    required this.micEnabled,
    required this.gcalConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(),
      child: Column(
        children: [
          _PermissionRow(
            icon: Icons.mic_rounded,
            label: 'Microphone',
            subtitle: 'Used to capture your thoughts',
            statusLabel: micEnabled ? 'Enabled' : 'Disabled',
            isActive: micEnabled,
          ),
          const Divider(height: 1, color: kDivider),
          const _PermissionRow(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            subtitle: 'Used for reminders',
            statusLabel: 'Enabled',
            isActive: true,
          ),
          const Divider(height: 1, color: kDivider),
          _PermissionRow(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            subtitle: 'Used to create scheduled items',
            statusLabel: gcalConnected ? 'Connected' : 'Not connected',
            isActive: gcalConnected,
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String statusLabel;
  final bool isActive;

  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.statusLabel,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: kTextSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      GoogleFonts.plusJakartaSans(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? kPrimary.withAlpha(25)
                  : kTextSecondary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? kPrimary : kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account card
// ---------------------------------------------------------------------------

class _AccountCard extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onSupport;

  const _AccountCard({
    required this.onEditProfile,
    required this.onSignOut,
    required this.onDeleteAccount,
    required this.onPrivacyPolicy,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(),
      child: Column(
        children: [
          _MenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: onEditProfile,
          ),
          const Divider(height: 1, color: kDivider),
          _MenuRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: onPrivacyPolicy,
          ),
          const Divider(height: 1, color: kDivider),
          _MenuRow(
            icon: Icons.help_outline_rounded,
            label: 'Support',
            onTap: onSupport,
          ),
          const Divider(height: 1, color: kDivider),
          _MenuRow(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: onSignOut,
            destructive: true,
          ),
          const Divider(height: 1, color: kDivider),
          _MenuRow(
            icon: Icons.delete_forever_rounded,
            label: 'Delete All Data',
            onTap: onDeleteAccount,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared primitives
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kTextSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? kError : kTextPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: kTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
