import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/contacts/quick_send_contact_model.dart';


class ContactsLocalDatasource {
  static const _key = 'quick_send_contacts';

  Future<List<QuickSendContact>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded
        .map((e) => QuickSendContact.fromJson(e))
        .toList();
  }

  Future<void> saveContacts(List<QuickSendContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(contacts.map((e) => e.toJson()).toList()),
    );
  }
}
