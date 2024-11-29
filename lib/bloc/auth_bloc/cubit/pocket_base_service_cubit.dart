import 'package:bloc/bloc.dart';
import 'package:oratio_app/networkProvider/constants.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  final PocketBase pb;
  BackendService(this.pb);
}

class PocketBaseServiceCubit extends Cubit<BackendService> {
  PocketBaseServiceCubit(PocketBase pb) : super(BackendService(pb));
}
