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
  Map<String, dynamic>? prayer;
  PrayerCommunity({
    required this.id,
    required this.community,
    required this.description,
    required this.members,
    required this.allMembers,
    required this.leader,
    this.image,
    this.prayer,
    this.isClosed,
  }) {
    print('PrayerCommunity created with prayer: $prayer');
  }

  PrayerCommunity copyWith({
    String? id,
    String? community,
    String? description,
    int? members,
    List? allMembers,
    RecordModel? leader,
    String? image,
    Map<String, dynamic>? prayer,
    bool? isClosed,
  }) {
    return PrayerCommunity(
      id: id ?? this.id,
      community: community ?? this.community,
      description: description ?? this.description,
      members: members ?? this.members,
      allMembers: allMembers ?? this.allMembers,
      leader: leader ?? this.leader,
      image: image ?? this.image,
      prayer: prayer ?? this.prayer,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'community': community,
      'description': description,
      'members': members,
      'allMembers': allMembers,
      'leader': leader.toJson(),
      'image': image,
      'prayer': prayer,
      'isClosed': isClosed,
    };
  }

  factory PrayerCommunity.fromMap(Map<String, dynamic> map) {
    print('=== PRAYER PARSING START ===');
    print('Prayer data from backend: ${map['prayer']}');
    print('Prayer data type: ${map['prayer'].runtimeType}');
    print('Is null? ${map['prayer'] == null}');
    print('Is empty string? ${map['prayer'] == ''}');
    print('Is String? ${map['prayer'] is String}');
    print('Is Map? ${map['prayer'] is Map}');

    // Parse prayer - it might be a JSON string from PocketBase
    Map<String, dynamic>? prayerData;
    if (map['prayer'] != null && map['prayer'] != '') {
      print('Passed null/empty check');

      if (map['prayer'] is String && (map['prayer'] as String).isNotEmpty) {
        print('Treating as String');
        // If it's a string, try to decode it
        try {
          final decoded = json.decode(map['prayer'] as String);
          prayerData = Map<String, dynamic>.from(decoded as Map);
          print('Decoded prayer from string: $prayerData');
        } catch (e) {
          print('Error decoding prayer JSON: $e');
          prayerData = null;
        }
      } else if (map['prayer'] is Map) {
        print('Treating as Map');
        // If it's already a map, use it directly
        prayerData = Map<String, dynamic>.from(map['prayer'] as Map);
        print('Prayer already a map: $prayerData');
      } else {
        print(
            'Prayer is neither String nor Map - type: ${map['prayer'].runtimeType}');
      }
    } else {
      print('Failed null/empty check');
    }

    print('Final prayerData being assigned: $prayerData');
    print('=== PRAYER PARSING END ===');

    return PrayerCommunity(
      id: map['id'] as String,
      community: map['community'] as String,
      description: map['description'] as String,
      members: map['members'] as int,
      allMembers: map['allMembers'] ?? [],
      image: map['image'] != null && (map['image'] as String).isNotEmpty
          ? map['image'] as String
          : null,
      leader: map['leader'] is RecordModel
          ? map['leader'] as RecordModel
          : RecordModel.fromJson(map['leader']),
      prayer: prayerData,
      isClosed: map['isClosed'] as bool?,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrayerCommunity.fromJson(String source) =>
      PrayerCommunity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PrayerCommunity(id: $id, community: $community, description: $description, members: $members, allMembers: $allMembers, leader: $leader, image: $image, prayer: $prayer, isClosed: $isClosed)';
  }

  @override
  bool operator ==(covariant PrayerCommunity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.community == community &&
        other.description == description &&
        other.members == members &&
        other.allMembers == allMembers &&
        other.leader == leader &&
        other.image == image &&
        other.prayer == prayer &&
        other.isClosed == isClosed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        community.hashCode ^
        description.hashCode ^
        members.hashCode ^
        allMembers.hashCode ^
        leader.hashCode ^
        image.hashCode ^
        prayer.hashCode ^
        isClosed.hashCode;
  }

  // Helper methods for prayer map
  String? get prayerTitle => prayer?['title'] as String?;
  String? get prayerText => prayer?['prayer'] as String?;

  bool get hasPrayer {
    print('Checking prayer validity: $prayer');
    return (prayer != null &&
        prayer!.containsKey('title') &&
        prayer!.containsKey('prayer') &&
        prayer!['title'] != null &&
        prayer!['prayer'] != null &&
        (prayer!['title'] as String).isNotEmpty &&
        (prayer!['prayer'] as String).isNotEmpty);
  }

  Map<String, String>? get prayerAsStringMap {
    if (!hasPrayer) return null;
    return {
      'title': prayer!['title']?.toString() ?? '',
      'prayer': prayer!['prayer']?.toString() ?? '',
    };
  }
}
