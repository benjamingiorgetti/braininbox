import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router.dart';
import 'theme.dart';
import '../data/repositories/analytics_repository.dart';
import '../features/capture/capture_controller.dart';

class BrainInboxApp extends ConsumerWidget {
  const BrainInboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Brain Inbox',
      theme: buildTheme(),
      home: const _SplashRouter(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Reads SharedPreferences once, then navigates to the correct screen.
class _SplashRouter extends ConsumerStatefulWidget {
  const _SplashRouter();

  @override
  ConsumerState<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends ConsumerState<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final done = prefs.getBool('onboarding_done') ?? false;
    ref.read(analyticsRepositoryProvider).logAppOpen();
    _initShareIntent();
    Navigator.pushReplacementNamed(
      context,
      done ? AppRoutes.shell : AppRoutes.welcome,
    );
  }

  void _initShareIntent() {
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      final textFile =
          files.where((f) => f.type == SharedMediaType.text).firstOrNull;
      if (textFile != null && textFile.path.isNotEmpty) {
        ref
            .read(captureControllerProvider.notifier)
            .startFromSharedText(textFile.path);
        if (mounted) Navigator.pushNamed(context, AppRoutes.recording);
      }
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      final textFile =
          files.where((f) => f.type == SharedMediaType.text).firstOrNull;
      if (textFile != null && textFile.path.isNotEmpty) {
        ref
            .read(captureControllerProvider.notifier)
            .startFromSharedText(textFile.path);
        if (mounted) Navigator.pushNamed(context, AppRoutes.recording);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: CircularProgressIndicator(color: kPrimary),
      ),
    );
  }
}
