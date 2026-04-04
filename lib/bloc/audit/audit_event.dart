import 'package:equatable/equatable.dart';

abstract class AuditEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAuditLogs extends AuditEvent {}
