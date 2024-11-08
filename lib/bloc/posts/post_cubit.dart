import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:pocketbase/pocketbase.dart';

class PostCubit extends Cubit<PostState> {
  final PocketBase _pocketBase;

  PostCubit(this._pocketBase) : super(PostInitial());

  Future<void> fetchPosts() async {
    emit(PostLoading());

    try {
      final records =
          await _pocketBase.collection('posts').getList(expand: 'community');
          // fetch prayer requests
      emit(PostLoaded(records.items
          .map((record) => Post.fromRecord(record, _pocketBase))
          .toList(),[]));
    } catch (e) {
      print(e);
      emit(PostError(e.toString()));
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    emit(PostLoading());

    try {
      await _pocketBase.collection('posts').create(body: data);
      await fetchPosts(); // Refresh the post list
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    emit(PostLoading());

    try {
      await _pocketBase.collection('posts').update(id, body: data);
      await fetchPosts(); // Refresh the post list
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String id) async {
    emit(PostLoading());

    try {
      await _pocketBase.collection('posts').delete(id);
      await fetchPosts(); // Refresh the post list
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
