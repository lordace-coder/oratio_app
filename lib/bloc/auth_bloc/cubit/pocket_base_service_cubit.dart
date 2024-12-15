import 'package:bloc/bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class BackendService {
  final PocketBase pb;
  BackendService(this.pb);
}

class PocketBaseServiceCubit extends Cubit<BackendService> {
  PocketBaseServiceCubit(PocketBase pb) : super(BackendService(pb));
}
