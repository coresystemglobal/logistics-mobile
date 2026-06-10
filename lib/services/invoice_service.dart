import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  final _api = ApiClient.instance;

  Future<List<InvoiceModel>> getInvoices({int page = 1, int limit = 20}) async {
    final response = await _api.get(
      ApiEndpoints.invoices,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final list = response['invoices'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvoiceModel> generateInvoice({
    required String tenantId,
    required double amount,
    DateTime? dueDate,
  }) async {
    final response = await _api.post(ApiEndpoints.generateInvoice, data: {
      'tenant_id': tenantId,
      'amount': amount,
      if (dueDate != null) 'due_date': dueDate.toIso8601String(),
    });
    final data = response['invoice'] ?? response['data'] ?? response;
    return InvoiceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<InvoiceModel>> getOverdueInvoices() async {
    final response = await _api.get(ApiEndpoints.overdueInvoices);
    final list = response['invoices'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvoiceModel> markAsPaid(String invoiceId) async {
    final response =
        await _api.put(ApiEndpoints.markInvoicePaid(invoiceId));
    final data = response['invoice'] ?? response['data'] ?? response;
    return InvoiceModel.fromJson(data as Map<String, dynamic>);
  }
}
