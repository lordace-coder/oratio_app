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

      final records = await pocketBase
          .collection('payment_disputes')
          .getFullList(
              sort: '-created',
              filter: "user ~ '${pocketBase.authStore.model.id}'");
      final bookingRecords = await pocketBase
          .collection("mass_booking")
          .getFullList(
              sort: '-created',
              filter: "user ~ '${pocketBase.authStore.model.id}'",
              expand: "parish,mass_type,attendees,payment");

      final retreatRecords = await pocketBase.collection("retreat").getFullList(
          sort: '-created',
          filter: "user ~ '${pocketBase.authStore.model.id}'",
          expand: "retreat,payment");

      List<PaymentDispute> transactions = [];
      List<MassBooking> bookings = [];
      List<Retreat> retreats = [];
      List<String> castErrors = [];

      // disputes
      try {
        transactions = records
            .map((record) => PaymentDispute.fromMap(record.toJson()))
            .toList();
      } catch (e) {
        final errorMsg = 'PaymentDispute cast error: $e';
        castErrors.add(errorMsg);
        print(errorMsg);
        transactions = [];
      }
      // mass bookings
      try {
        bookings = bookingRecords
            .map((record) => MassBooking.fromRecordModel(record))
            .toList();
      } catch (e) {
        final errorMsg = 'MassBooking cast error: $e';
        castErrors.add(errorMsg);
        print(errorMsg);
        bookings = [];
      }
      // retreats
      try {
        retreats = retreatRecords
            .map((record) => Retreat.fromRecordModel(record))
            .toList();
      } catch (e) {
        final errorMsg = 'Retreat cast error: $e';
        castErrors.add(errorMsg);
        print(errorMsg);
        retreats = [];
      }

      emit(state.copyWith(
        disputes: transactions,
        bookings: bookings,
        retreats: retreats,
        status: TransactionStatus.success,
        error: castErrors.isNotEmpty ? castErrors.join('; ') : null,
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
