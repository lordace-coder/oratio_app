part of 'profile_data_cubit.dart';

class Profile {
  RecordModel user;
  String userId;
  List<RecordModel> parish;
  String contact;
  List<RecordModel> community;
  Profile({
    required this.user,
    required this.userId,
    required this.parish,
    required this.contact,
    required this.community,
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
}

@immutable
sealed class ProfileDataState {}

final class ProfileDataInitial extends ProfileDataState {}

final class ProfileDataLoading extends ProfileDataState {}

final class ProfileDataError extends ProfileDataState {
  final String error;

  ProfileDataError(this.error) {
    NotificationService.showError('Error occured loading profile $error');
  }
}

final class ProfileDataLoaded extends ProfileDataState {
  final Profile profile;
  final Profile? guestProfile;

  ProfileDataLoaded({required this.profile, this.guestProfile});
}
