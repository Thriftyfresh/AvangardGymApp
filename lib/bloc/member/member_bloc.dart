import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/member_repository.dart';
import 'member_event.dart';
import 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final MemberRepository _repo = MemberRepository();

  MemberBloc() : super(MemberInitial()) {
    on<LoadMembers>(_onLoadMembers);
    on<AddMember>(_onAddMember);
    on<UpdateMember>(_onUpdateMember);
    on<DeleteMember>(_onDeleteMember);
  }

  Future<void> _onLoadMembers(LoadMembers event, Emitter<MemberState> emit) async {
    emit(MemberLoading());
    try {
      final members = await _repo.getMembers();
      emit(MemberLoaded(members));
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onAddMember(AddMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.addMember(event.member);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onUpdateMember(UpdateMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.updateMember(event.member);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onDeleteMember(DeleteMember event, Emitter<MemberState> emit) async {
    try {
      await _repo.deleteMember(event.memberId);
      add(LoadMembers());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }
}
