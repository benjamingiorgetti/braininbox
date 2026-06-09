// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inboxItemsHash() => r'8791f725f9ee80071d05949af9819deb622b6993';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [inboxItems].
@ProviderFor(inboxItems)
const inboxItemsProvider = InboxItemsFamily();

/// See also [inboxItems].
class InboxItemsFamily extends Family<AsyncValue<List<ItemRow>>> {
  /// See also [inboxItems].
  const InboxItemsFamily();

  /// See also [inboxItems].
  InboxItemsProvider call(
    InboxFilter filter,
  ) {
    return InboxItemsProvider(
      filter,
    );
  }

  @override
  InboxItemsProvider getProviderOverride(
    covariant InboxItemsProvider provider,
  ) {
    return call(
      provider.filter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inboxItemsProvider';
}

/// See also [inboxItems].
class InboxItemsProvider extends AutoDisposeStreamProvider<List<ItemRow>> {
  /// See also [inboxItems].
  InboxItemsProvider(
    InboxFilter filter,
  ) : this._internal(
          (ref) => inboxItems(
            ref as InboxItemsRef,
            filter,
          ),
          from: inboxItemsProvider,
          name: r'inboxItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inboxItemsHash,
          dependencies: InboxItemsFamily._dependencies,
          allTransitiveDependencies:
              InboxItemsFamily._allTransitiveDependencies,
          filter: filter,
        );

  InboxItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final InboxFilter filter;

  @override
  Override overrideWith(
    Stream<List<ItemRow>> Function(InboxItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InboxItemsProvider._internal(
        (ref) => create(ref as InboxItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ItemRow>> createElement() {
    return _InboxItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InboxItemsProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InboxItemsRef on AutoDisposeStreamProviderRef<List<ItemRow>> {
  /// The parameter `filter` of this provider.
  InboxFilter get filter;
}

class _InboxItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<ItemRow>> with InboxItemsRef {
  _InboxItemsProviderElement(super.provider);

  @override
  InboxFilter get filter => (origin as InboxItemsProvider).filter;
}

String _$pendingCountHash() => r'8136754a3d9b25949743a4548548b39b520de40f';

/// See also [pendingCount].
@ProviderFor(pendingCount)
final pendingCountProvider = AutoDisposeStreamProvider<int>.internal(
  pendingCount,
  name: r'pendingCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pendingCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
