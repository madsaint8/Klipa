import '../models/wallet/wallet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';

class WalletRepository {
  final supabase = Supabase.instance.client;

  
  Future getUserWallet() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException('User not authenticated');
      }

      final response = await supabase 
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();
      
      return WalletModel.fromJson(response);
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }
  
  Future getWalletByEmail(String email) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      if (response == null) return null;
      
      final walletResponse = await supabase
          .from('wallets')
          .select()
          .eq('user_id', response['id'])
          .maybeSingle();
      
      if (walletResponse == null) return null;
      
      return WalletModel.fromJson(walletResponse);
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }
  
  Stream watchWallet() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw AppException('User not authenticated');
    }

    return supabase
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => WalletModel.fromJson(data.first));
  }
  Future<WalletModel?> getWallet() async {
    try {
      final data = await getWallet();
      if (data != null) {
        return WalletModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}