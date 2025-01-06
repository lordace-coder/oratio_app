import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/priest_bloc/event.dart';
import 'package:oratio_app/bloc/priest_bloc/state.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';

class PriestBloc extends Bloc<PriestEvent, PriestState> {
  PriestBloc() : super(PriestState()) {
    //FETCH TRANSACTIONS
    on<FetchTransactionsEvent>((event, emit) async {
      final data = await getTransactions(event.ctx);
      final newState = PriestState();
      newState.transactions = data;
      emit(newState);
    });
    
  }
}
