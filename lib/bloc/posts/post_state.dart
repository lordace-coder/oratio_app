import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';
// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

// Define the Post class
class Post extends Equatable {
  final String id;
  final String post;
  final List<String> likes;
  final String? community;
  final String? communityId;
  final String? image;
  final List commentCount;
  final String date;

  ///author refers to the owner of the post whether parish or community or a single user
  final RecordModel author;
  const Post({
    required this.author,
    required this.communityId,
    required this.commentCount,
    required this.id,
    required this.post,
    required this.likes,
    this.community,
    required this.date,
    this.image,
  });

  String? getAvatar(BuildContext context) {
    final pb = getPocketBaseFromContext(context);
    final avatarUrl =
        pb.getFileUrl(author, author.getStringValue('image')).toString();
    if (avatarUrl.isEmpty) {
      return null;
    }
    return avatarUrl;
  }

  @override
  List<Object?> get props => [id, post, likes, community, image];

  factory Post.fromRecord(RecordModel record, PocketBase pb) {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
    return Post(
      date: formatDateTimeToHoursAgo(format.parse(record.created)),
      commentCount: record.getListValue('comment'),
      id: record.id,
      post: record.getStringValue('post'),
      likes: List<String>.from(record.getListValue('likes')),
      community: record.expand['community']?.first.getStringValue('community'),
      image: pb.getFileUrl(record, record.data['image']).toString(),
      communityId: record.getStringValue('community'),
      author: record.expand['community']!.first,
    );
  }
}

// Define your state and event classes
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;

  const PostLoaded(
    this.posts,
  );

  @override
  List<Object?> get props => [posts];
}

class PostError extends PostState {
  final String error;

  PostError(this.error) {
    NotificationService.showError('An error occured Fetchin Feeds');
  }

  @override
  List<Object?> get props => [error];
}

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class FetchPosts extends PostEvent {}

class CreatePost extends PostEvent {
  final Map<String, dynamic> data;

  const CreatePost(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdatePost extends PostEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdatePost(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeletePost extends PostEvent {
  final String id;

  const DeletePost(this.id);

  @override
  List<Object?> get props => [id];
}
