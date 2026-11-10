import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/contacts/quick_send_contact_model.dart';

class ContactsRemoteDatasource {
  final _client = Supabase.instance.client;

  Future<List<QuickSendContact>> fetchContacts() async {
    final userId = _client.auth.currentUser!.id;

    final res = await _client
        .from('contacts')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (res as List)
        .map((e) => QuickSendContact.fromJson(e))
        .toList();
  }

  Future<void> addContact(QuickSendContact contact) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('contacts').insert({
      ...contact.toJson(),
      'user_id': userId,
    });
  }
}
