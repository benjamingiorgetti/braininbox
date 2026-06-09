import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router.dart';
import '../../app/theme.dart';

const _phrases = [
  'call Juan tomorrow at 9am',
  'finish the proposal by Friday',
  'follow up with María about the project',
  'dentist appointment next Tuesday',
  'buy groceries before dinner',
  'review the contract this week',
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _phraseIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF6FF), Color(0xFFF7F9FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              // Logo
              Image.asset(
                'assets/icon/app_icon.png',
                width: 96,
                height: 96,
              ),
              const SizedBox(height: 28),
              // App name
              Text(
                'Brain Inbox',
                style: GoogleFonts.nunitoSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 32),
              // Animated phrase block
              Text(
                'Brain Inbox,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 60,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Align(
                    key: ValueKey(_phraseIndex),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _phrases[_phraseIndex],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tagline
              Text(
                'Speak messy. Get clear actions.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const Spacer(flex: 4),
              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.onboarding),
                  child: const Text('Get started →'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
