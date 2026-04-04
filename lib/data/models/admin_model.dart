import 'package:equatable/equatable.dart';

class AdminModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // superadmin | admin

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role,
  };

  factory AdminModel.fromMap(String id, Map<String, dynamic> map) => AdminModel(
    id: id,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? 'admin',
  );

  @override
  List<Object?> get props => [id, email, role];
}
