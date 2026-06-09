import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/notification_service.dart';
import 'data/services/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  try {
    await RevenueCatService().configure();
  } catch (_) {
    // RevenueCat failures are surfaced when the paywall is opened.
  }
  runApp(const ProviderScope(child: BrainInboxApp()));
}
