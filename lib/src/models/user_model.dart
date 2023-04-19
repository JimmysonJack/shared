import 'package:flutter/material.dart';

class User {
  String email;
  String? name;
  String? phone;
  User({required this.email, required this.name, this.phone});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'phone': phone,
    };
  }
}

// @JsonSerializable()
class TileFields {
  IconData icon;
  String title;
  String url;
  List<String> permissions;

  TileFields(
      {required this.icon,
      required this.title,
      required this.url,
      required this.permissions});

  // factory TileFields.fromJson(Map<String, dynamic> json) =>
  //     _$TileFieldsFromJson(json);

  // Map<String, dynamic> toJson() => _$TileFieldsToJson(this);
}
