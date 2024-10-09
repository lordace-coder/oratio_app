part of 'user_cubit.dart';

class UserModel {
  int id;
  String username;
  String email;
  String? first_name;
  String? last_name;
  String? profile_picture;
  bool is_staff;
  int balance = 0;
  int completed_tasks_count;
  int completed_surveys_count;
  int referrers_count;
  String referral_code;
  Map? exchangeRates;
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.first_name,
    this.last_name,
    this.profile_picture,
    required this.is_staff,
    required this.balance,
    required this.completed_tasks_count,
    required this.completed_surveys_count,
    required this.referrers_count,
    required this.referral_code,
    this.exchangeRates,
  });

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? first_name,
    String? last_name,
    String? profile_picture,
    bool? is_staff,
    int? balance,
    int? completed_tasks_count,
    int? completed_surveys_count,
    int? referrers_count,
    String? referral_code,
    Map? exchangeRates,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      profile_picture: profile_picture ?? this.profile_picture,
      is_staff: is_staff ?? this.is_staff,
      balance: balance ?? this.balance,
      completed_tasks_count:
          completed_tasks_count ?? this.completed_tasks_count,
      completed_surveys_count:
          completed_surveys_count ?? this.completed_surveys_count,
      referrers_count: referrers_count ?? this.referrers_count,
      referral_code: referral_code ?? this.referral_code,
      exchangeRates: exchangeRates ?? this.exchangeRates,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'profile_picture': profile_picture,
      'is_staff': is_staff,
      'balance': balance,
      'completed_tasks_count': completed_tasks_count,
      'completed_surveys_count': completed_surveys_count,
      'referrers_count': referrers_count,
      'referral_code': referral_code,
      'exchangeRates': exchangeRates,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      first_name:
          map['first_name'] != null ? map['first_name'] as String : null,
      last_name: map['last_name'] != null ? map['last_name'] as String : null,
      profile_picture: map['profile_picture'] != null
          ? map['profile_picture'] as String
          : null,
      is_staff: map['is_staff'] as bool,
      balance: map['balance'] as int,
      completed_tasks_count: map['completed_tasks_count'] as int,
      completed_surveys_count: map['completed_surveys_count'] as int,
      referrers_count: map['referrers_count'] as int,
      referral_code: map['referral_code'] as String,
      exchangeRates: map['exchangeRates'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, first_name: $first_name, last_name: $last_name, profile_picture: $profile_picture, is_staff: $is_staff, balance: $balance, completed_tasks_count: $completed_tasks_count, completed_surveys_count: $completed_surveys_count, referrers_count: $referrers_count, referral_code: $referral_code, exchangeRates: $exchangeRates)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.email == email &&
        other.first_name == first_name &&
        other.last_name == last_name &&
        other.profile_picture == profile_picture &&
        other.is_staff == is_staff &&
        other.balance == balance &&
        other.completed_tasks_count == completed_tasks_count &&
        other.completed_surveys_count == completed_surveys_count &&
        other.referrers_count == referrers_count &&
        other.referral_code == referral_code &&
        other.exchangeRates == exchangeRates;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        first_name.hashCode ^
        last_name.hashCode ^
        profile_picture.hashCode ^
        is_staff.hashCode ^
        balance.hashCode ^
        completed_tasks_count.hashCode ^
        completed_surveys_count.hashCode ^
        referrers_count.hashCode ^
        referral_code.hashCode ^
        exchangeRates.hashCode;
  }
}
