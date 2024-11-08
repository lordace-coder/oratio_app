// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class PrayerCommunity {
  String id;
  String community;
  String description;
  int members;
  Map leader;
  PrayerCommunity({
    required this.id,
    required this.community,
    required this.description,
    required this.members,
    required this.leader,
  });

  PrayerCommunity copyWith({
    String? id,
    String? community,
    String? description,
    int? members,
    Map? leader,
  }) {
    return PrayerCommunity(
      id: id ?? this.id,
      community: community ?? this.community,
      description: description ?? this.description,
      members: members ?? this.members,
      leader: leader ?? this.leader,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'community': community,
      'description': description,
      'members': members,
      'leader': leader,
    };
  }

  factory PrayerCommunity.fromMap(Map<String, dynamic> map) {
    return PrayerCommunity(
        id: map['id'] as String,
        community: map['community'] as String,
        description: map['description'] as String,
        members: map['members'] as int,
        leader: Map.from(
          (map['leader'] as Map),
        ));
  }

  String toJson() => json.encode(toMap());

  factory PrayerCommunity.fromJson(String source) =>
      PrayerCommunity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PrayerCommunity(id: $id, community: $community, description: $description, members: $members, leader: $leader)';
  }

  @override
  bool operator ==(covariant PrayerCommunity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.community == community &&
        other.description == description &&
        other.members == members &&
        mapEquals(other.leader, leader);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        community.hashCode ^
        description.hashCode ^
        members.hashCode ^
        leader.hashCode;
  }
}
