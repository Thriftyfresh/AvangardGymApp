import 'package:equatable/equatable.dart';
import '../../data/models/admin_model.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final List<AdminModel> admins;
  AdminLoaded(this.admins);
  @override
  List<Object?> get props => [admins];
}
class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
