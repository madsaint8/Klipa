import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/remote/beneficiaries_remote_datasource.dart';
import '../../data/models/beneficiaries/beneficiary_model.dart';

final beneficiariesRemoteProvider = Provider(
  (_) => BeneficiariesRemoteDatasource(),
);

// ── Phone lookup state ────────────────────────────────────────────────────────

enum PhoneLookupStatus { idle, loading, found, notFound, error }

class PhoneLookupState {
  final PhoneLookupStatus status;
  final Map<String, dynamic>? user;
  final String? error;

  const PhoneLookupState({
    this.status = PhoneLookupStatus.idle,
    this.user,
    this.error,
  });

  PhoneLookupState copyWith({
    PhoneLookupStatus? status,
    Map<String, dynamic>? user,
    String? error,
  }) =>
      PhoneLookupState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error ?? this.error,
      );
}

final phoneLookupProvider =
    StateNotifierProvider.autoDispose<PhoneLookupNotifier, PhoneLookupState>(
  (ref) => PhoneLookupNotifier(ref.read(beneficiariesRemoteProvider)),
);

class PhoneLookupNotifier extends StateNotifier<PhoneLookupState> {
  final BeneficiariesRemoteDatasource _remote;

  PhoneLookupNotifier(this._remote) : super(const PhoneLookupState());

  void reset() => state = const PhoneLookupState();

  Future<void> lookup(String phone) async {
    if (phone.length < 9) return;

    state = state.copyWith(status: PhoneLookupStatus.loading, user: null);

    try {
      final user = await _remote.findUserByPhone(phone);
      state = user != null
          ? state.copyWith(status: PhoneLookupStatus.found, user: user)
          : state.copyWith(status: PhoneLookupStatus.notFound);
    } catch (e) {
      state = state.copyWith(
        status: PhoneLookupStatus.error,
        error: 'Lookup failed. Please try again.',
      );
    }
  }
}

// ── Beneficiaries list ────────────────────────────────────────────────────────

final beneficiariesProvider =
    AsyncNotifierProvider<BeneficiariesNotifier, List<Beneficiary>>(
  BeneficiariesNotifier.new,
);

class BeneficiariesNotifier extends AsyncNotifier<List<Beneficiary>> {
  BeneficiariesRemoteDatasource get _remote =>
      ref.read(beneficiariesRemoteProvider);

  @override
  Future<List<Beneficiary>> build() => _remote.fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_remote.fetchAll);
  }

  /// Optimistic insert — rolls back on failure.
  Future<void> add({
    required String contactUserId,
    required String name,
    required String phone,
    String? nickname,
  }) async {
    final previous = state;

    try {
      final inserted = await _remote.insert(
        contactUserId: contactUserId,
        name: name,
        phone: phone,
        nickname: nickname,
      );

      // Prepend to list instantly
      state = AsyncData([inserted, ...state.value ?? []]);
    } catch (e) {
      state = previous; // rollback
      rethrow;
    }
  }

  Future<void> remove(String beneficiaryId) async {
    final previous = state;
    // Optimistic remove
    state = AsyncData(
      (state.value ?? []).where((b) => b.id != beneficiaryId).toList(),
    );
    try {
      await _remote.delete(beneficiaryId);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> toggleFavorite(String beneficiaryId, bool value) async {
    final previous = state;
    state = AsyncData(
      (state.value ?? []).map((b) {
        return b.id == beneficiaryId ? b.copyWith(isFavorite: value) : b;
      }).toList(),
    );
    try {
      await _remote.toggleFavorite(beneficiaryId, value);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}