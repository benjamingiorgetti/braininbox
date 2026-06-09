import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import 'capture_controller.dart';

void showTextCaptureSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TextCaptureSheet(ref: ref),
  );
}

class _TextCaptureSheet extends StatefulWidget {
  final WidgetRef ref;
  const _TextCaptureSheet({required this.ref});

  @override
  State<_TextCaptureSheet> createState() => _TextCaptureSheetState();
}

class _TextCaptureSheetState extends State<_TextCaptureSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _extract() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() => _loading = true);
    await widget.ref
        .read(captureControllerProvider.notifier)
        .startFromSharedText(text);
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.recording);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 24),
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
          Row(
            children: [
              Text(
                'Type your thoughts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const Spacer(),
              const Text(
                '✍️',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 6,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: kTextPrimary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'What\'s on your mind? Write it all out…',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: kTextSecondary,
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              filled: true,
              fillColor: kBackground,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _ctrl.text.trim().isEmpty ? null : _extract,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: kDivider,
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
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Extract with AI →'),
            ),
          ),
        ],
      ),
    );
  }
}
