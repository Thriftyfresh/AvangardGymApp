import 'package:equatable/equatable.dart';
import '../../data/models/audit_log_model.dart';

abstract class AuditState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuditInitial extends AuditState {}
class AuditLoading extends AuditState {}
class AuditLoaded extends AuditState {
  final List<AuditLog> logs;
  AuditLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}
class AuditError extends AuditState {
  final String message;
  AuditError(this.message);
  @override
  List<Object?> get props => [message];
}
