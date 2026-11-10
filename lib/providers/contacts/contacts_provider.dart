import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../data/models/contacts/quick_send_contact_model.dart';
import '../../data/datasources/local/contacts_local_datasource.dart';
import '../../data/datasources/remote/contacts_remote_datasource.dart';

final contactsRepositoryProvider = Provider(
  (ref) => ContactsRepository(
    ContactsLocalDatasource(),
    ContactsRemoteDatasource(),
  ),
);

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<QuickSendContact>>(
        ContactsNotifier.new);

class ContactsNotifier extends AsyncNotifier<List<QuickSendContact>> {
  @override
  Future<List<QuickSendContact>> build() async {
    return ref.read(contactsRepositoryProvider).loadContacts();
  }

  // Future<void> addContact(QuickSendContact contact) async {
  //   state = const AsyncLoading();
  //   await ref.read(contactsRepositoryProvider).addContact(contact);
  //   state = AsyncData([...state.value ?? [], contact]);
  // }

  Future<void> addContact(QuickSendContact contact) async {
    final current = state.value ?? [];

    // Optimistic update
    state = AsyncData([...current, contact]);

    try {
      await ref.read(contactsRepositoryProvider).addContact(contact);
    } catch (e) {
      // Rollback if failed
      state = AsyncData(current);
      rethrow;
    }
  }

  // forces a full reload from repository
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contactsRepositoryProvider).loadContacts(),
    );
  }
}
