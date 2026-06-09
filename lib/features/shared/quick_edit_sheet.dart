import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';

/// Generic edit sheet used both in Review and Inbox.
/// Returns the updated values, or null if dismissed.
Future<({String title, DateTime? date, String? person})?> showQuickEditSheet(
  BuildContext context, {
  required String initialTitle,
  DateTime? initialDate,
  String? initialPerson,
}) {
  return showModalBottomSheet<({String title, DateTime? date, String? person})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickEditSheet(
      initialTitle: initialTitle,
      initialDate: initialDate,
      initialPerson: initialPerson,
    ),
  );
}

class _QuickEditSheet extends StatefulWidget {
  final String initialTitle;
  final DateTime? initialDate;
  final String? initialPerson;

  const _QuickEditSheet({
    required this.initialTitle,
    this.initialDate,
    this.initialPerson,
  });

  @override
  State<_QuickEditSheet> createState() => _QuickEditSheetState();
}

class _QuickEditSheetState extends State<_QuickEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _personCtrl;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _personCtrl = TextEditingController(text: widget.initialPerson ?? '');
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _personCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'Edit item',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: GoogleFonts.plusJakartaSans(color: kTextSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              filled: true,
              fillColor: kBackground,
            ),
            style: GoogleFonts.plusJakartaSans(
                color: kTextPrimary, fontWeight: FontWeight.w600),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDivider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: kTextSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'No date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedDate != null
                            ? kTextPrimary
                            : kTextSecondary,
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: kTextSecondary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _personCtrl,
            decoration: InputDecoration(
              labelText: 'Person (optional)',
              labelStyle: GoogleFonts.plusJakartaSans(color: kTextSecondary),
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: kTextSecondary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              filled: true,
              fillColor: kBackground,
            ),
            style: GoogleFonts.plusJakartaSans(
                color: kTextPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
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
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : TimeOfDay.now(),
    );
    setState(() {
      _selectedDate = time != null
          ? DateTime(picked.year, picked.month, picked.day, time.hour,
              time.minute)
          : DateTime(picked.year, picked.month, picked.day);
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final person = _personCtrl.text.trim();
    Navigator.of(context).pop((
      title: title.isEmpty ? widget.initialTitle : title,
      date: _selectedDate,
      person: person.isEmpty ? null : person,
    ));
  }
}
