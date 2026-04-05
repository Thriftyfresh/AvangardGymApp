import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/women_sheets_repository.dart';
import '../sync/sync_event.dart';
import '../sync/sync_state.dart';

class WomenSyncBloc extends Bloc<SyncEvent, SyncState> {
  final WomenSheetsRepository _repo = WomenSheetsRepository();

  WomenSyncBloc() : super(SyncInitial()) {
    on<SyncFromSheets>(_onSync);
  }

  Future<void> _onSync(SyncFromSheets event, Emitter<SyncState> emit) async {
    emit(SyncLoading());
    try {
      final result = await _repo.syncMembers();
      emit(SyncSuccess(added: result.added, skipped: result.skipped, updated: result.updated));
    } catch (e) {
      emit(SyncError(e.toString()));
    }
  }
}
