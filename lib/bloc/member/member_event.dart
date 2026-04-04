import 'package:equatable/equatable.dart';
import '../../data/models/member_model.dart';

abstract class MemberEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMembers extends MemberEvent {}

class AddMember extends MemberEvent {
  final MemberModel member;
  AddMember(this.member);
  @override
  List<Object?> get props => [member];
}

class UpdateMember extends MemberEvent {
  final MemberModel member;
  UpdateMember(this.member);
  @override
  List<Object?> get props => [member];
}

class DeleteMember extends MemberEvent {
  final String memberId;
  DeleteMember(this.memberId);
  @override
  List<Object?> get props => [memberId];
}
