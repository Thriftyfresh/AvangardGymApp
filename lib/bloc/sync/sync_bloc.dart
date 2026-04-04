import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sheets_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SheetsRepository _repo = SheetsRepository();

  SyncBloc() : super(SyncInitial()) {
    on<SyncFromSheets>(_onSyncFromSheets);
  }

  Future<void> _onSyncFromSheets(SyncFromSheets event, Emitter<SyncState> emit) async {
    emit(SyncLoading());
    try {
      final result = await _repo.syncMembers();
      emit(SyncSuccess(added: result.added, skipped: result.skipped, updated: result.updated));
    } catch (e) {
      emit(SyncError(e.toString()));
    }
  }
}
