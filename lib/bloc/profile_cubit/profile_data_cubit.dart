import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:oratio_app/ace_toasts/ace_toasts.dart';
import 'package:pocketbase/pocketbase.dart';

part 'profile_data_state.dart';

class ProfileDataCubit extends Cubit<ProfileDataState> {
  final PocketBase pb;
  ProfileDataCubit(this.pb) : super(ProfileDataInitial());

  Future getMyProfile() async {
    if (state is ProfileDataLoaded) {
      emit(ProfileDataLoading());
    }

    try {
// check if user is a priest
      RecordModel? myParish;
      if ((pb.authStore.model as RecordModel).getBoolValue('priest')) {
        // get parish he is leading
        final data = (await pb
                .collection('parish')
                .getList(filter: 'priest = "${pb.authStore.model.id}" '))
            .items;
        if (data.isNotEmpty) {
          myParish = data.first;
        } else {
          print('no parish for priest = "${pb.authStore.model.id}" ');
          try {
            NotificationService.showWarning(
                'This account is not connected to any parish, This may cause some errors',
                duration: const Duration(seconds: 7));
          } catch (e) {}
        }
      }

      final profile = Profile(
          user: pb.authStore.model,
          userId: pb.authStore.model.id,
          parish: [],
          parishLeading: myParish,
          contact: '',
          community: []);
      final parishAttending = await pb.collection('parish').getFullList(
          filter:
              'members ~ "${profile.userId}" || priest = "${profile.userId}"');
      final communities = await pb.collection('prayer_community').getFullList(
          fields: "community,id",
          filter:
              'members ~ "${profile.userId}" || leader = "${profile.userId}"');
      profile.community = communities;
      profile.parish = parishAttending;
      profile.contact =
          (pb.authStore.model as RecordModel).getStringValue("phone_number");
      Profile? guestProfile;
      if (state is ProfileDataLoaded) {
        guestProfile = (state as ProfileDataLoaded).guestProfile;
      }
      emit(ProfileDataLoaded(
        profile: profile,
        guestProfile: guestProfile,
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

      Profile? myProfile;
      if (state is ProfileDataLoaded) {
        myProfile = (state as ProfileDataLoaded).profile;
      } else {
        await getMyProfile();
        myProfile = (state as ProfileDataLoaded).profile;
      }

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
