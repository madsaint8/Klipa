import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/beneficiaries/beneficiary_model.dart';

class BeneficiariesRemoteDatasource {
  final _supabase = Supabase.instance.client;

  String get _currentUserId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }

  Future<List<Beneficiary>> fetchAll() async {
    final data = await _supabase
        .from('beneficiaries')
        .select('''
          id, user_id, contact_user_id, nickname, is_favorite, created_at,
          beneficiary_user:contact_user_id (
            id, full_name, phone, profile_pic
          )
        ''')
        .eq('user_id', _currentUserId)
        .order('is_favorite', ascending: false)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Look up a user by phone number — returns null if not found.
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    final data = await _supabase
        .from('users')
        .select('id, full_name, phone, profile_pic')
        .eq('phone', normalized)
        .neq('id', _currentUserId)
        .maybeSingle();

    return data;
  }

  Future<Beneficiary> insert({
    required String contactUserId,
    required String name,
    required String phone,
    String? nickname,
  }) async {
    final data = await _supabase
        .from('beneficiaries')
        .insert({
          'user_id': _currentUserId,
          'contact_user_id': contactUserId,
          'name': name,
          'phone': phone,
          'nickname': nickname,
          'is_favorite': false,
        })
        .select('''
          id, user_id, contact_user_id, nickname, is_favorite, created_at,
          beneficiary_user:contact_user_id (
            id, full_name, phone, profile_pic
          )
        ''')
        .single();

    return Beneficiary.fromJson(data);
  }

  Future<void> delete(String beneficiaryId) async {
    await _supabase
        .from('beneficiaries')
        .delete()
        .eq('id', beneficiaryId)
        .eq('user_id', _currentUserId);
  }

  Future<void> toggleFavorite(String beneficiaryId, bool value) async {
    await _supabase
        .from('beneficiaries')
        .update({'is_favorite': value})
        .eq('id', beneficiaryId)
        .eq('user_id', _currentUserId);
  }
}