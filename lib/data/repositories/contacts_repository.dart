import '../datasources/local/contacts_local_datasource.dart';
import '../datasources/remote/contacts_remote_datasource.dart';
import '../models/contacts/quick_send_contact_model.dart';

class ContactsRepository {
  ContactsRepository(this._local, this._remote);

  final ContactsLocalDatasource _local;
  final ContactsRemoteDatasource _remote;

  Future<List<QuickSendContact>> loadContacts() async {
    try {
      final remote = await _remote.fetchContacts();
      await _local.saveContacts(remote);
      return remote;
    } catch (_) {
      return _local.getContacts();
    }
  }

  Future<void> addContact(QuickSendContact contact) async {
    await _remote.addContact(contact);
    final local = await _local.getContacts();
    await _local.saveContacts([...local, contact]);
  }
}
