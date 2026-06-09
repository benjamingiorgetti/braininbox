import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';

class SavedConfirmationScreen extends StatelessWidget {
  const SavedConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, int>?) ??
            const {'scheduled': 0, 'inbox': 0, 'total': 0};
    final scheduled = args['scheduled'] ?? 0;
    final inbox = args['inbox'] ?? 0;
    final total = args['total'] ?? 0;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Check icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: kPrimary, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Saved. Your head is clearer.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$total ${total == 1 ? 'item' : 'items'} organized',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (scheduled > 0 || inbox > 0) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (scheduled > 0)
                      _StatChip(
                        icon: Icons.calendar_today_rounded,
                        label:
                            '$scheduled ${scheduled == 1 ? 'item' : 'items'} scheduled',
                        color: const Color(0xFF3B82F6),
                      ),
                    if (inbox > 0)
                      _StatChip(
                        icon: Icons.inbox_rounded,
                        label:
                            '$inbox open ${inbox == 1 ? 'loop' : 'loops'}',
                        color: kPrimary,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 44),
              if (scheduled > 0)
                _PrimaryButton(
                  label: 'View schedule',
                  icon: Icons.calendar_month_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.calendar),
                ),
              if (scheduled > 0 && inbox > 0) const SizedBox(height: 10),
              if (inbox > 0)
                _SecondaryButton(
                  label: 'View inbox',
                  icon: Icons.inbox_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.inbox),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Capture another',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: kTextPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: kDivider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
