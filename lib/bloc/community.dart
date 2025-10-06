// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class PrayerCommunity {
  String id;
  String community;
  String description;
  int members;
  List allMembers;
  RecordModel leader;
  String? image;
  bool? isClosed;
  PrayerCommunity({
    required this.id,
    required this.community,
    required this.description,
    required this.members,
    required this.allMembers,
    required this.leader,
    this.image,
    this.isClosed,
  });

  PrayerCommunity copyWith({
    String? id,
    String? community,
    String? description,
    int? members,
    List? allMembers,
    RecordModel? leader,
  }) {
    return PrayerCommunity(
      id: id ?? this.id,
      community: community ?? this.community,
      description: description ?? this.description,
      members: members ?? this.members,
      allMembers: allMembers ?? this.allMembers,
      leader: leader ?? this.leader,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'community': community,
      'description': description,
      'members': members,
      'allMembers': allMembers,
      'leader': leader,
    };
  }

  factory PrayerCommunity.fromMap(Map<String, dynamic> map) {
    return PrayerCommunity(
        id: map['id'] as String,
        community: map['community'] as String,
        description: map['description'] as String,
        members: map['members'] as int,
        allMembers: [],
        image: map['image'] != null ? map['image'] as String : null,
        leader: RecordModel.fromJson(map['leader']),
        isClosed: map['isClosed']);
  }

  String toJson() => json.encode(toMap());

  factory PrayerCommunity.fromJson(String source) =>
      PrayerCommunity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PrayerCommunity(id: $id, community: $community, description: $description, members: $members, allMembers: $allMembers, leader: $leader)';
  }

  @override
  bool operator ==(covariant PrayerCommunity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.community == community &&
        other.description == description &&
        other.members == members &&
        other.allMembers == allMembers;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        community.hashCode ^
        description.hashCode ^
        members.hashCode ^
        allMembers.hashCode ^
        leader.hashCode;
  }
}
