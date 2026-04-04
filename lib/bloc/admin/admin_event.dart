import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAdmins extends AdminEvent {}

class AddAdmin extends AdminEvent {
  final String email;
  final String name;
  final String role;
  final String currentAdminEmail;
  final String currentAdminPassword;
  AddAdmin({required this.email, required this.name, required this.role, required this.currentAdminEmail, required this.currentAdminPassword});
  @override
  List<Object?> get props => [email, name, role];
}

class DeleteAdmin extends AdminEvent {
  final String adminId;
  DeleteAdmin(this.adminId);
  @override
  List<Object?> get props => [adminId];
}

class UpdateAdminRole extends AdminEvent {
  final String adminId;
  final String role;
  UpdateAdminRole({required this.adminId, required this.role});
  @override
  List<Object?> get props => [adminId, role];
}
