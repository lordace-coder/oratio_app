part of 'profile_data_cubit.dart';

class Profile {
  RecordModel user;
  String userId;
  List<RecordModel> parish;
  String contact;
  List<RecordModel> community;
  RecordModel? parishLeading;
  Profile({
    required this.user,
    required this.userId,
    required this.parish,
    required this.contact,
    required this.community,
    this.parishLeading,
  });

  Profile copyWith({
    RecordModel? user,
    String? userId,
    List<RecordModel>? parish,
    String? contact,
    List<RecordModel>? community,
  }) {
    return Profile(
      user: user ?? this.user,
      userId: userId ?? this.userId,
      parish: parish ?? <RecordModel>[],
      contact: contact ?? this.contact,
      community: community ?? this.community,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      user: RecordModel.fromJson(json['user']),
      userId: json['userId'],
      parish:
          (json['parish'] as List).map((e) => RecordModel.fromJson(e)).toList(),
      contact: json['contact'],
      community: (json['community'] as List)
          .map((e) => RecordModel.fromJson(e))
          .toList(),
      parishLeading: json['parishLeading'] != null
          ? RecordModel.fromJson(json['parishLeading'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'userId': userId,
      'parish': parish.map((e) => e.toJson()).toList(),
      'contact': contact,
      'community': community.map((e) => e.toJson()).toList(),
      'parishLeading': parishLeading?.toJson(),
    };
  }

  factory Profile.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Profile.fromJson(json);
  }

  String toJsonString() {
    final Map<String, dynamic> json = toJson();
    return jsonEncode(json);
  }
}

@immutable
sealed class ProfileDataState {}

final class ProfileDataInitial extends ProfileDataState {}

final class ProfileDataLoading extends ProfileDataState {}

final class ProfileDataError extends ProfileDataState {
  final String error;

  ProfileDataError(this.error);
}

final class ProfileDataLoaded extends ProfileDataState {
  final Profile profile;
  final Profile? guestProfile;

  ProfileDataLoaded({required this.profile, this.guestProfile});
}
