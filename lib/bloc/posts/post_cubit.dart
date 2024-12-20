import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:pocketbase/pocketbase.dart';

class PostCubit extends Cubit<PostState> {
  final PocketBase _pocketBase;
  int _currentPage = 1;
  List<Post> _currentPosts = [];
  static const int _perPage = 30;

  PostCubit(this._pocketBase) : super(PostInitial());

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (!loadMore) {
      emit(PostLoading());
      _currentPage = 1;
      _currentPosts = [];
    }

    try {
      final records = await _pocketBase.collection('posts').getList(
            expand: 'community',
            sort: '-created',
            page: _currentPage,
            perPage: _perPage,
          );

      final newPosts = records.items
          .map((record) => Post.fromRecord(record, _pocketBase))
          .toList();

      if (loadMore) {
        _currentPosts.addAll(newPosts);
      } else {
        _currentPosts = newPosts;
      }

      _currentPage++;

      emit(PostLoaded(_currentPosts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> loadMorePosts() async {
    if (state is PostLoaded) {
      await fetchPosts(loadMore: true);
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    emit(PostLoading());
    try {
      await _pocketBase.collection('posts').create(body: data);
      _currentPage = 1;
      await fetchPosts(); // Refresh the post list
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
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

  Future<void> likePost(String id) async {
    await updatePost(id, {
      'likes+': [_pocketBase.authStore.model.id]
    });
  }

  Future<void> dislikePost(String id) async {
    await updatePost(id, {
      'likes-': [_pocketBase.authStore.model.id]
    });
  }
}
