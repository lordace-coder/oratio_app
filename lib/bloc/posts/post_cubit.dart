import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/posts/post_state.dart';
import 'package:pocketbase/pocketbase.dart';

class PostHelper {
  final PocketBase _pocketBase;
  int _currentPage = 1;
  List<Post> _currentPosts = [];
  static const int _perPage = 30;

  PostHelper(this._pocketBase);

  Future<List<Post>> fetchPosts({bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _currentPosts = [];
    }

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

    return _currentPosts;
  }

  Future<List<Post>> getCommunityPosts(String communityId) async {
    final records = await _pocketBase.collection('posts').getList(
          expand: 'community',
          sort: '-created',
          filter: "community = '$communityId'",
          perPage: 20,
        );

    return records.items.map((i) => Post.fromRecord(i, _pocketBase)).toList();
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    await _pocketBase.collection('posts').create(body: data);
    _currentPage = 1;
    await fetchPosts(); // Refresh the post list
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _pocketBase.collection('posts').update(id, body: data);
  }

  Future<void> deletePost(String id) async {
    await _pocketBase.collection('posts').delete(id);
    await fetchPosts(); // Refresh the post list
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

  Future<RecordModel> getPost(String id) async {
    return await _pocketBase
        .collection('posts')
        .getOne(id, expand: 'community');
  }
}
