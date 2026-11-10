import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthBalanceService {
  static final _client = Web3Client(
    'https://rpc.ankr.com/eth_sepolia/1976c2335554294ebc8c727e1dfda17f090ac53c75abe3173fcbef72f95281b0', // mainnet
    Client(),
  );

  static Future<double> getEthBalance(String address) async {
    final ethAddress = EthereumAddress.fromHex(address);
    final balanceWei = await _client.getBalance(ethAddress);
    return balanceWei.getValueInUnit(EtherUnit.ether);
  }
}
