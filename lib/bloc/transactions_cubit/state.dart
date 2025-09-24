// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

// transaction_model.dart

class PaymentDispute {
  final String id;
  final bool confirmed;
  final String proof;
  final int amount;
  final String transaction_ref;
  final String bank_name;
  final String account_name;
  final DateTime created;
  PaymentDispute({
    required this.id,
    required this.confirmed,
    required this.proof,
    required this.amount,
    required this.transaction_ref,
    required this.bank_name,
    required this.account_name,
    required this.created,
  });

  PaymentDispute copyWith({
    String? id,
    bool? confirmed,
    String? proof,
    int? amount,
    String? transaction_ref,
    String? bank_name,
    String? account_name,
    DateTime? created,
  }) {
    return PaymentDispute(
      id: id ?? this.id,
      confirmed: confirmed ?? this.confirmed,
      proof: proof ?? this.proof,
      amount: amount ?? this.amount,
      transaction_ref: transaction_ref ?? this.transaction_ref,
      bank_name: bank_name ?? this.bank_name,
      account_name: account_name ?? this.account_name,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'confirmed': confirmed,
      'proof': proof,
      'amount': amount,
      'transaction_ref': transaction_ref,
      'bank_name': bank_name,
      'account_name': account_name,
      'created': created.millisecondsSinceEpoch,
    };
  }

  factory PaymentDispute.fromMap(Map<String, dynamic> map) {
    debugPrint("map data $map");
    return PaymentDispute(
      id: map['id'] as String,
      confirmed: map['confirmed'] as bool,
      proof: map['proof'] as String,
      amount: map['amount'] as int,
      transaction_ref: map['transaction_ref'] as String,
      bank_name: map['bank_name'] as String,
      account_name: map['account_name'] as String,
      created: DateTime.parse(map['created'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentDispute.fromJson(String source) =>
      PaymentDispute.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentDispute(id: $id, confirmed: $confirmed, proof: $proof, amount: $amount, transaction_ref: $transaction_ref, bank_name: $bank_name, account_name: $account_name, created: $created)';
  }

  @override
  bool operator ==(covariant PaymentDispute other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.confirmed == confirmed &&
        other.proof == proof &&
        other.amount == amount &&
        other.transaction_ref == transaction_ref &&
        other.bank_name == bank_name &&
        other.account_name == account_name &&
        other.created == created;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        confirmed.hashCode ^
        proof.hashCode ^
        amount.hashCode ^
        transaction_ref.hashCode ^
        bank_name.hashCode ^
        account_name.hashCode ^
        created.hashCode;
  }
}

// transaction_state.dart

enum TransactionStatus { initial, loading, success, failure }

class TransactionState {
  final List<PaymentDispute> disputes;
  final TransactionStatus status;
  final String? error;

  const TransactionState({
    this.disputes = const [],
    this.status = TransactionStatus.initial,
    this.error,
  });

  TransactionState copyWith({
    List<PaymentDispute>? disputes,
    TransactionStatus? status,
    String? error,
  }) {
    return TransactionState(
      disputes: disputes ?? this.disputes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionState &&
        other.disputes == disputes &&
        other.status == status &&
        other.error == error;
  }

  @override
  int get hashCode => disputes.hashCode ^ status.hashCode ^ error.hashCode;
}
