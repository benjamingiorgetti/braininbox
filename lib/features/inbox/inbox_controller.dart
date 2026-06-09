import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/db/app_database.dart';
import '../../data/models/inbox_filter.dart';
import '../../data/repositories/inbox_repository.dart';

part 'inbox_controller.g.dart';

@riverpod
Stream<List<ItemRow>> inboxItems(Ref ref, InboxFilter filter) =>
    ref.watch(inboxRepositoryProvider).watchInbox(filter);

@riverpod
Stream<int> pendingCount(Ref ref) =>
    ref.watch(inboxRepositoryProvider).watchPendingCount();
