import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}
class SyncLoading extends SyncState {}
class SyncSuccess extends SyncState {
  final int added;
  final int skipped;
  final int updated;
  SyncSuccess({required this.added, required this.skipped, required this.updated});
  @override
  List<Object?> get props => [added, skipped, updated];
}
class SyncError extends SyncState {
  final String message;
  SyncError(this.message);
  @override
  List<Object?> get props => [message];
}
