// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

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

// mass booking model

class MassBooking {
  final String id;
  final DateTime startTime;
  final RecordModel? parish;
  final String? intention;
  final bool confirmed;
  final bool usedCallback;
  final List<RecordModel> attendees;
  final bool anonymous;
  final DateTime? endTime;
  final RecordModel payment;
  final DateTime created;
  final DateTime updated;

  MassBooking({
    required this.id,
    required this.startTime,
    this.parish,
    required this.intention,
    this.confirmed = false,
    this.usedCallback = false,
    this.attendees = const [],
    this.anonymous = false,
    this.endTime,
    required this.payment,
    required this.created,
    required this.updated,
  });

  factory MassBooking.fromRecordModel(RecordModel record) {
    final expand = record.expand;

    // developer.log(
    //     "MassBooking fields: startTime=${record.data['startTime']}, intention=${record.data['intention']}, parish=${expand['parish']}, confirmed=${record.data['confirmed']}, usedCallback=${record.data['used_callback']}, attendees=${expand['attendees']}, anonymous=${record.data['anonymous']}, endTime=${record.data['endTime']}, payment=${expand['payment']}, created=${record.data['created']}, updated=${record.data['updated']}");
    return MassBooking(
      id: record.id,
      startTime: DateTime.parse(record.data['startTime'] as String),
      parish:
          (expand['parish'] is List && (expand['parish'] as List).isNotEmpty)
              ? (expand['parish'] as List)[0]
              : null,
      intention: record.data['intention'] != null
          ? record.data['intention'] as String
          : '',
      confirmed: record.data['confirmed'] as bool? ?? false,
      usedCallback: record.data['used_callback'] as bool? ?? false,
      attendees: (expand['attendees'] is List && expand['attendees'] != null)
          ? (expand['attendees'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? RecordModel.fromJson(e)
                  : e as RecordModel)
              .toList()
          : [],
      anonymous: record.data['anonymous'] as bool? ?? false,
      endTime: record.data['endTime'] != null
          ? DateTime.parse(record.data['endTime'] as String)
          : null,
      payment: expand['payment']?[0] == null
          ? RecordModel(id: '', data: {}, expand: {})
          : (expand['payment'] is List &&
                  (expand['payment'] as List).isNotEmpty)
              ? (expand['payment'] as List)[0]
              : RecordModel(id: '', data: {}, expand: {}),
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'parish': parish?.id,
      'intention': intention,
      'confirmed': confirmed,
      'used_callback': usedCallback,
      'attendees': attendees.map((e) => e.id).toList(),
      'anonymous': anonymous,
      'endTime': endTime?.toIso8601String(),
      'payment': payment.id,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  MassBooking copyWith({
    String? id,
    DateTime? startTime,
    RecordModel? parish,
    String? intention,
    bool? confirmed,
    bool? usedCallback,
    List<RecordModel>? attendees,
    bool? anonymous,
    DateTime? endTime,
    RecordModel? payment,
    DateTime? created,
    DateTime? updated,
  }) {
    return MassBooking(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      parish: parish ?? this.parish,
      intention: intention ?? this.intention,
      confirmed: confirmed ?? this.confirmed,
      usedCallback: usedCallback ?? this.usedCallback,
      attendees: attendees ?? this.attendees,
      anonymous: anonymous ?? this.anonymous,
      endTime: endTime ?? this.endTime,
      payment: payment ?? this.payment,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'MassBooking(id: $id, startTime: $startTime, intention: $intention, confirmed: $confirmed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MassBooking &&
        other.id == id &&
        other.startTime == startTime &&
        other.parish == parish &&
        other.intention == intention &&
        other.confirmed == confirmed &&
        other.usedCallback == usedCallback &&
        other.attendees == attendees &&
        other.anonymous == anonymous &&
        other.endTime == endTime &&
        other.payment == payment &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      startTime,
      parish,
      intention,
      confirmed,
      usedCallback,
      attendees,
      anonymous,
      endTime,
      payment,
      created,
      updated,
    );
  }
}

// retreat model

class Retreat {
  final String id;
  final RecordModel user;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? description;
  final RecordModel payment;
  final DateTime created;
  final DateTime updated;

  Retreat({
    required this.id,
    required this.user,
    this.startTime,
    this.endTime,
    this.description,
    required this.payment,
    required this.created,
    required this.updated,
  });

  factory Retreat.fromRecordModel(RecordModel record) {
    final expand = record.expand;
    debugPrint(
        "Retreat fields: startTime=${record.data['startTime']}, endTime=${record.data['endTime']}, description=${record.data['description']}, user=${expand['user']}, payment=${expand['payment']}, created=${record.data['created']}, updated=${record.data['updated']}");
    return Retreat(
      id: record.id,
      user: (expand['user'] is List && (expand['user'] as List).isNotEmpty)
          ? (expand['user'] as List)[0]
          : RecordModel(id: '', data: {}, expand: {}),
      startTime: record.data['startTime'] != null
          ? DateTime.parse(record.data['startTime'] as String)
          : null,
      endTime: record.data['endTime'] != null
          ? DateTime.parse(record.data['endTime'] as String)
          : null,
      description: record.data['description'] != null
          ? record.data['description'] as String
          : '',
      payment:
          (expand['payment'] is List && (expand['payment'] as List).isNotEmpty)
              ? (expand['payment'] as List)[0]
              : RecordModel(id: '', data: {}, expand: {}),
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.id,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'description': description,
      'payment': payment.id,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Retreat copyWith({
    String? id,
    RecordModel? user,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    RecordModel? payment,
    DateTime? created,
    DateTime? updated,
  }) {
    return Retreat(
      id: id ?? this.id,
      user: user ?? this.user,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      payment: payment ?? this.payment,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Retreat(id: $id, startTime: $startTime, endTime: $endTime, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Retreat &&
        other.id == id &&
        other.user == user &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.description == description &&
        other.payment == payment &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      user,
      startTime,
      endTime,
      description,
      payment,
      created,
      updated,
    );
  }
}
// transaction_state.dart

enum TransactionStatus { initial, loading, success, failure }

class TransactionState {
  final List<PaymentDispute> disputes;
  final TransactionStatus status;
  final String? error;
  final List<MassBooking> booking;
  final List<Retreat> retreat;

  const TransactionState(
      {this.disputes = const [],
      this.status = TransactionStatus.initial,
      this.error,
      this.booking = const [],
      this.retreat = const []});

  TransactionState copyWith({
    List<PaymentDispute>? disputes,
    TransactionStatus? status,
    String? error,
    List<MassBooking>? bookings,
    List<Retreat>? retreats,
  }) {
    return TransactionState(
      disputes: disputes ?? this.disputes,
      status: status ?? this.status,
      error: error ?? this.error,
      retreat: retreats ?? retreat,
      booking: bookings ?? booking,
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
