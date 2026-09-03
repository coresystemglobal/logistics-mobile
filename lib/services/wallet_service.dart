import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/wallet_model.dart';

class WalletService {
  final _api = ApiClient.instance;

  Future<WalletModel> getBalance() async {
    final response = await _api.get(ApiEndpoints.walletBalance);
    final data = response['wallet'] ?? response['data'] ?? response;
    return WalletModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<WalletTransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final list = response['transactions'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Step 1: Initialise a Paystack funding session for a personal wallet.
  /// Returns `{ payment: { checkout_url, access_code, reference, provider } }`.
  Future<Map<String, dynamic>> initializeFunding({
    required double amount,
    required String provider,
    String? callbackUrl,
  }) async {
    final response = await _api.post(
      ApiEndpoints.walletFundInitialize,
      data: {
        'amount': amount,
        'provider': provider,
        if (callbackUrl != null) 'callback_url': callbackUrl,
      },
    );
    return response;
  }

  /// Step 1b: Initialise a Paystack checkout for a business wallet.
  /// Provider is always Paystack — no param needed.
  Future<Map<String, dynamic>> initializeBusinessFunding({
    required double amount,
    String? callbackUrl,
  }) async {
    final response = await _api.post(
      ApiEndpoints.walletBusinessFundInitialize,
      data: {
        'amount': amount,
        if (callbackUrl != null) 'callback_url': callbackUrl,
      },
    );
    return response;
  }

  /// Step 2: Verify a completed funding transaction by reference.
  Future<Map<String, dynamic>> verifyFunding({
    required String reference,
    required String provider,
  }) async {
    final response = await _api.get(
      ApiEndpoints.walletFundVerify,
      queryParameters: {'reference': reference, 'provider': provider},
    );
    return response;
  }
}
