import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBeneficiaryController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Set<String> _existingContactIds = {};
  Map<String, dynamic>? _selectedContact;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get filteredUsers => _filteredUsers;
  Set<String> get existingContactIds => _existingContactIds;
  Map<String, dynamic>? get selectedContact => _selectedContact;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  AddBeneficiaryController() {
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ── Data Loading ──────────────────────────────────────────────────────────

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      // Load in parallel: all users + existing contacts
      final results = await Future.wait([
        _supabase
            .from('users')
            .select('id, full_name, phone, profile_pic')
            .neq('id', currentUserId) // exclude self
            .order('full_name'),
        _supabase
            .from('contacts')
            .select('contact_user_id')
            .eq('user_id', currentUserId),
      ]);

      final users = List<Map<String, dynamic>>.from(results[0] as List);
      final contacts = List<Map<String, dynamic>>.from(results[1] as List);

      _existingContactIds =
          contacts.map((c) => c['contact_user_id'] as String).toSet();

      _allUsers = users;
      _applyFilter();
    } on PostgrestException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load contacts. Please try again.';
      debugPrint('LoadUsers error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredUsers = _allUsers.where((user) {
      final name = (user['full_name'] as String? ?? '').toLowerCase();
      final phone = (user['phone'] as String? ?? '').toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectContact(Map<String, dynamic> user) {
    _selectedContact = user;
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedContact = null;
    _error = null;
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// Returns true on success, false on failure.
  Future<bool> addBeneficiary() async {
    final contact = _selectedContact;
    final currentUserId = _supabase.auth.currentUser?.id;

    if (contact == null || currentUserId == null) return false;

    if (contact['id'] == currentUserId) {
      _error = 'You cannot add yourself as a beneficiary.';
      notifyListeners();
      return false;
    }

    if (_existingContactIds.contains(contact['id'] as String)) {
      _error = 'This person is already in your contacts.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('contacts').insert({
        'user_id': currentUserId,
        'contact_user_id': contact['id'],
        'name': contact['full_name'] ?? '',
        'phone': contact['phone'] ?? '',
        'is_favorite': false,
      });

      _existingContactIds.add(contact['id'] as String);
      return true;
    } on PostgrestException catch (e) {
      // ✅ Log the real error code + message
      debugPrint('❌ PostgrestException code: ${e.code}');
      debugPrint('❌ PostgrestException message: ${e.message}');
      debugPrint('❌ PostgrestException details: ${e.details}');
      debugPrint('❌ PostgrestException hint: ${e.hint}');

      _error = switch (e.code) {
        '23505' => 'This person is already in your contacts.',
        '23503' => 'User account not found.',
        '23514' => 'You cannot add yourself as a beneficiary.',
        '42501' => 'Permission denied. Check RLS policies.', // ✅ RLS error
        _ => 'Error ${e.code}: ${e.message}', // ✅ show raw error
      };
      return false;
    } catch (e, stack) {
      debugPrint('❌ Unknown error: $e');
      debugPrint(stack.toString());
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
