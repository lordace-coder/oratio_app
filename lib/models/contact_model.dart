import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 1) // Changed typeId to 1
class ContactModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String avatar;

  @HiveField(3)
  final String firstName;

  @HiveField(4)
  final String lastName;

  @HiveField(5)
  final String phoneNumber;

  @HiveField(6)
  final bool priest;

  @HiveField(7)
  final bool staff;

  ContactModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.priest,
    required this.staff,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      priest: json['priest'],
      staff: json['staff'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'priest': priest,
      'staff': staff,
    };
  }
}
