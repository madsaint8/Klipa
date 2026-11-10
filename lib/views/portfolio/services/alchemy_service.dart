import 'package:dio/dio.dart';
import 'blockchain_service.dart';

abstract class AlchemyService implements BlockchainService {

    final Dio dio;

    AlchemyService(this.dio);

}

/*
//TODO: implement:

eth_getBalance
alchemy_getTokenBalances
alchemy_getTokenMetadata
alchemy_getAssetTransfers
getNFTsForOwner

*/