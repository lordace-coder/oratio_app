import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:oratio_app/helpers/snackbars.dart';
import 'package:pocketbase/pocketbase.dart';

part 'profile_data_state.dart';

class ProfileDataCubit extends Cubit<ProfileDataState> {
  final PocketBase pb;
  ProfileDataCubit(this.pb) : super(ProfileDataInitial());

  Future getMyProfile() async {
    emit(ProfileDataLoading());

    try {
      final profile = Profile(
          user: pb.authStore.model,
          userId: pb.authStore.model.id,
          parish: [],
          contact: '',
          community: []);
      final parishAttending = await pb.collection('parish').getFullList(
          filter:
              'members ~ "${profile.userId}" || priest = "${profile.userId}"');
      final communities = await pb.collection('prayer_community').getFullList(
          fields: "community",
          filter:
              'members ~ "${profile.userId}" || leader = "${profile.userId}"');
      profile.community = communities;
      print(profile.community);

      profile.parish = parishAttending;
      profile.contact =
          (pb.authStore.model as RecordModel).getStringValue("phone_number");
      emit(ProfileDataLoaded(
        profile: profile,
      ));
    } catch (e) {
      emit(ProfileDataError('$e'));
      rethrow;
    }
  }

  Future visitProfile(String id) async {
    emit(ProfileDataLoading());
    try {
      final profileOfOtherUser = await pb.collection('users').getOne(id);
      final profile = Profile(
          user: profileOfOtherUser,
          userId: profileOfOtherUser.id,
          parish: [],
          contact: '',
          community: []);

      final parishAttending = await pb.collection('parish').getFullList(
          filter:
              'members ~ "${profile.userId}" || priest = "${profile.userId}"');

      final communities = await pb.collection('prayer_community').getList(
          filter:
              'members ~ "${profile.userId}" || leader = "${profile.userId}"');

      final myProfile = Profile(
          user: pb.authStore.model,
          userId: pb.authStore.model.id,
          parish: [],
          contact: '',
          community: []);
      emit(ProfileDataLoaded(
          profile: myProfile,
          guestProfile: Profile(
              user: profileOfOtherUser,
              userId: id,
              parish: parishAttending,
              contact: 'contact',
              community: communities.items)));
    } catch (e) {
      emit(ProfileDataError('$e'));
      rethrow;
    }
  }
}
