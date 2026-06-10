class InvoiceModel {
  final String id;
  final String tenantId;
  final double amount;
  final String status; // PENDING | PAID | OVERDUE
  final String? invoiceNumber;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const InvoiceModel({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.status,
    this.invoiceNumber,
    this.dueDate,
    this.paidAt,
    this.createdAt,
  });

  bool get isPaid => status == 'PAID';
  bool get isOverdue => status == 'OVERDUE';
  bool get isPending => status == 'PENDING';

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id']?.toString() ?? '',
        tenantId: json['tenant_id']?.toString() ?? json['tenantId']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] ?? 'PENDING',
        invoiceNumber: json['invoice_number']?.toString() ?? json['invoiceNumber']?.toString(),
        dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
        paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      );
}
