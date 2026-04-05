import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/women_member_repository.dart';
import '../member/member_event.dart';
import '../member/member_state.dart';

class WomenMemberBloc extends Bloc<MemberEvent, MemberState> {
  final WomenMemberRepository _repo = WomenMemberRepository();

  WomenMemberBloc() : super(MemberInitial()) {
    on<LoadMembers>(_onLoad);
    on<AddMember>(_onAdd);
    on<UpdateMember>(_onUpdate);
    on<DeleteMember>(_onDelete);
  }

  Future<void> _onLoad(LoadMembers event, Emitter<MemberState> emit) async {
    emit(MemberLoading());
    try {
      final members = await _repo.getMembers();
      emit(MemberLoaded(members));
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onAdd(AddMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.addMember(event.member);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.updateMember(event.member);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.deleteMember(event.memberId);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }
}
