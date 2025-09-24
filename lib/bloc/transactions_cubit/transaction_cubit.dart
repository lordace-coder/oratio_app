// transaction_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/transactions_cubit/state.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart'; // Add this import

class TransactionCubit extends Cubit<TransactionState> {
  final PocketBase pocketBase;

  TransactionCubit({required this.pocketBase})
      : super(const TransactionState());

  Future<void> fetchTransactions() async {
    try {
      if (state.disputes.isEmpty) {
        emit(state.copyWith(status: TransactionStatus.loading));
      }

      final records =
          await pocketBase.collection('payment_disputes').getFullList(
                sort: '-created',
              );

      final transactions = records
          .map((record) => PaymentDispute.fromMap(record.toJson()))
          .toList();

      emit(state.copyWith(
        disputes: transactions,
        status: TransactionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> fetchParishTransactions() async {
    try {
      if (state.disputes.isEmpty) {
        emit(state.copyWith(status: TransactionStatus.loading));
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final records =
          await pocketBase.collection('transaction_history').getFullList(
                sort: '-created',
                filter:
                    'created >= "${DateFormat('yyyy-MM-dd').format(startOfMonth)}" && created <= "${DateFormat('yyyy-MM-dd').format(endOfMonth)}"',
              );

      final transactions = records
          .map((record) => PaymentDispute.fromMap(record.toJson()))
          .toList();

      emit(state.copyWith(
        disputes: transactions,
        status: TransactionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        error: e.toString(),
      ));
      rethrow;
    }
  }
}
