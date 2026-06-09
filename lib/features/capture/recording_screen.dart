import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/models/processing_state.dart';
import 'capture_controller.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProcessingState>(captureControllerProvider, (_, next) {
      if (next is AutoSaved && context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.savedConfirmation,
          arguments: {
            'scheduled': next.scheduled,
            'inbox': next.inbox,
            'total': next.total,
          },
        );
        // Defer reset so the navigation frame renders before state reverts to
        // Idle — avoids a brief flash of the mic/idle UI during transition.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(captureControllerProvider.notifier).reset();
        });
      }
    });

    final state = ref.watch(captureControllerProvider);

    return Scaffold(
      backgroundColor: kTextPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white60, size: 26),
                    onPressed: () {
                      ref.read(captureControllerProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: switch (state) {
                  Idle() => _IdleView(pulse: _pulse),
                  Recording(:final elapsed) => _RecordingView(
                      elapsed: elapsed,
                      pulse: _pulse,
                      onStop: () => ref
                          .read(captureControllerProvider.notifier)
                          .stopRecording(),
                    ),
                  Transcribing() =>
                    const _ProcessingView(label: 'Transcribing…', icon: '✍️'),
                  Extracting() => const _ProcessingView(
                      label: 'Organizing and saving…', icon: '🧠'),
                  ReviewReady() => const SizedBox.shrink(),
                  AutoSaved() => const SizedBox.shrink(),
                  ProcessingError(:final message, :final retryable) =>
                    _ErrorView(
                      message: message,
                      retryable: retryable,
                      onRetry: () =>
                          ref.read(captureControllerProvider.notifier).retry(),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final AnimationController pulse;
  const _IdleView({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "What's on your mind?",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to start recording',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 56),
        Consumer(builder: (context, ref, _) {
          return GestureDetector(
            onTap: () =>
                ref.read(captureControllerProvider.notifier).startRecording(),
            child: _MicButton(pulse: pulse, recording: false),
          );
        }),
      ],
    );
  }
}

// ── Recording ─────────────────────────────────────────────────────────────────

class _RecordingView extends StatelessWidget {
  final Duration elapsed;
  final AnimationController pulse;
  final VoidCallback onStop;

  const _RecordingView({
    required this.elapsed,
    required this.pulse,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final s = elapsed.inSeconds;
    final label =
        '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recording…',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: kPrimary),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: onStop,
          child: _MicButton(pulse: pulse, recording: true),
        ),
        const SizedBox(height: 24),
        Text(
          'Tap to stop',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white38),
        ),
      ],
    );
  }
}

// ── Mic Button ────────────────────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  final AnimationController pulse;
  final bool recording;
  const _MicButton({required this.pulse, required this.recording});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final scale = recording ? (1.0 + pulse.value * 0.12) : 1.0;
        final ringOpacity = recording ? (0.3 + pulse.value * 0.3) : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Transform.scale(
              scale: scale * 1.5,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withAlpha((ringOpacity * 50).toInt()),
                ),
              ),
            ),
            // Inner ring
            Transform.scale(
              scale: scale * 1.25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withAlpha((ringOpacity * 80).toInt()),
                ),
              ),
            ),
            // Main button
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recording ? kError : kPrimary,
                boxShadow: [
                  BoxShadow(
                    color: (recording ? kError : kPrimary).withAlpha(100),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Processing ────────────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  final String label;
  final String icon;
  const _ProcessingView({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 24),
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: kPrimary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final bool retryable;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.message, required this.retryable, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😬', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          if (retryable) ...[
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
