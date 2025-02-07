import 'package:bloc/bloc.dart';

/// MetaDataCubit is a cubit for storing a map of any type of data.
/// 
/// This cubit can be used to manage the state of a map, providing
/// a simple way to update and retrieve the current state.
class MetaDataCubit extends Cubit<Map<String, dynamic>> {
  /// Creates a MetaDataCubit with an initial state.
  MetaDataCubit(Map<String, dynamic> initialState) : super(initialState);

  /// Updates the state with the new data.
  void updateData(String key, dynamic value) {
    state[key] = value;
    emit(Map<String, dynamic>.from(state));
  }

  /// Removes data from the state.
  void removeData(String key) {
    state.remove(key);
    emit(Map<String, dynamic>.from(state));
  }
}
