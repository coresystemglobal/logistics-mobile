class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double creditLimit;
  final bool isSuspended;
  final DateTime? updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.creditLimit,
    required this.isSuspended,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        creditLimit: (json['credit_limit'] ?? json['creditLimit'] as num?)
                ?.toDouble() ??
            0.0,
        isSuspended: json['is_suspended'] ?? json['isSuspended'] ?? false,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
      );

  bool get isNegative => balance < 0;
}

class WalletTransactionModel {
  final String id;
  final String type;      // CREDIT, DEBIT
  final double amount;
  final String? description;
  final String? referenceId;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id']?.toString() ?? '',
        type: json['type'] ?? 'CREDIT',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        description: json['description'],
        referenceId: json['reference_id']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  bool get isCredit => type == 'CREDIT';
}
