import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paywave/data/models/wallet/wallet_model.dart';

import '../data/models/transaction/transaction_model.dart';


class PaywaveApi {
  final String baseUrl;
  final String serviceKey; //  secure storage on server, not client — for demo only

  PaywaveApi({required this.baseUrl, required this.serviceKey});

  Future<WalletModel> createWallet(String userId, {String currency = 'ZAR'}) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/wallets/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'currency': currency}));
    if (resp.statusCode != 200) throw Exception('create wallet failed: ${resp.body}');
    final data = jsonDecode(resp.body);
    return WalletModel.fromJson(data['wallet']);
  }

  Future<TransactionModel> p2pTransfer(String fromWallet, String toWallet, int amountCents, {int feeCents = 0, String? reference}) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/transactions/p2p'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_wallet': fromWallet,
          'to_wallet': toWallet,
          'amount_cents': amountCents,
          'fee_cents': feeCents,
          'reference': reference
        }));
    if (resp.statusCode != 200) throw Exception('transfer failed: ${resp.body}');
    final data = jsonDecode(resp.body);
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> cashInStart(String walletId, int amountCents, {String? reference}) async {
    final resp = await http.post(Uri.parse('$baseUrl/api/transactions/cash-in/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'wallet_id': walletId, 'amount_cents': amountCents, 'reference': reference}));
    if (resp.statusCode != 200) throw Exception('cash-in start failed: ${resp.body}');
    final data = jsonDecode(resp.body);
    return TransactionModel.fromJson(data);
  }

  //  do NOT call settle from client — provider webhook should call settle.
}
