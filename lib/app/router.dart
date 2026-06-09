import 'package:flutter/material.dart';
import '../features/capture/home_screen.dart';
import '../features/capture/recording_screen.dart';
import '../features/review/review_screen.dart';
import '../features/review/saved_confirmation_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import 'shell.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const recording = '/recording';
  static const review = '/review';
  static const inbox = '/inbox';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const shell = '/shell';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const savedConfirmation = '/saved';
}

abstract final class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        ),
      AppRoutes.welcome => MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        ),
      AppRoutes.onboarding => MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        ),
      AppRoutes.shell => MaterialPageRoute(
          builder: (_) => const AppShell(),
          settings: settings,
        ),
      AppRoutes.recording => MaterialPageRoute(
          builder: (_) => const RecordingScreen(),
          settings: settings,
          fullscreenDialog: true,
        ),
      AppRoutes.review => MaterialPageRoute(
          builder: (_) => const ReviewScreen(),
          settings: settings,
        ),
      AppRoutes.inbox => MaterialPageRoute(
          builder: (_) => const InboxScreen(),
          settings: settings,
        ),
      AppRoutes.calendar => MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
          settings: settings,
        ),
      AppRoutes.profile => MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        ),
      AppRoutes.savedConfirmation => MaterialPageRoute(
          builder: (_) => const SavedConfirmationScreen(),
          settings: settings,
        ),
      _ => MaterialPageRoute(
          builder: (_) => const AppShell(),
          settings: settings,
        ),
    };
  }
}
