// transaction_model.dart

enum TransactionType { sent, recieved, transferred }

class Transaction {
  final String id;
  final String transaction;
  final String title;
  final bool read;
  final bool successful;
  final double? amount;
  final TransactionType type;
  final DateTime created;

  const Transaction({
    required this.id,
    required this.transaction,
    required this.title,
    required this.read,
    required this.successful,
    this.amount,
    required this.type,
    required this.created,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transaction: json['transaction'],
      title: json['title'],
      read: json['read'] ?? false,
      successful: json['successful'] ?? false,
      amount: json['amount']?.toDouble(),
      type: getTransactionType(json['type'] as String),
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction': transaction,
      'title': title,
      'read': read,
      'successful': successful,
      'amount': amount,
      'type': type.toString().split('.').last,
      'created': created.toIso8601String(),
    };
  }

  static TransactionType getTransactionType(String type) {
    switch (type) {
      case 'sent':
        return TransactionType.sent;
      case 'recieved':
        return TransactionType.recieved;
      case 'transferred':
        return TransactionType.transferred;
      default:
        throw ArgumentError('Invalid transaction type: $type');
    }
  }
}

// transaction_state.dart

enum TransactionStatus { initial, loading, success, failure }

class TransactionState {
  final List<Transaction> transactions;
  final TransactionStatus status;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.status = TransactionStatus.initial,
    this.error,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    TransactionStatus? status,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionState &&
        other.transactions == transactions &&
        other.status == status &&
        other.error == error;
  }

  @override
  int get hashCode => transactions.hashCode ^ status.hashCode ^ error.hashCode;
}
