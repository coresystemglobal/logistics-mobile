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
        balance: num.tryParse(json['balance']?.toString() ?? '')?.toDouble() ?? 0.0,
        creditLimit: num.tryParse(
              (json['credit_limit'] ?? json['creditLimit'])?.toString() ?? ''
            )?.toDouble() ?? -2000.0,
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
        amount: num.tryParse(json['amount']?.toString() ?? '')?.toDouble() ?? 0.0,
        description: json['description'],
        referenceId: json['reference_id']?.toString() ?? json['reference']?.toString(),
        createdAt: (json['created_at'] ?? json['createdAt']) != null
            ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
            : null,
      );

  bool get isCredit => type == 'CREDIT';
}
