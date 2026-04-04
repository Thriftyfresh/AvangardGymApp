import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/audit_repository.dart';
import 'audit_event.dart';
import 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository _repo = AuditRepository();

  AuditBloc() : super(AuditInitial()) {
    on<LoadAuditLogs>(_onLoadAuditLogs);
  }

  Future<void> _onLoadAuditLogs(LoadAuditLogs event, Emitter<AuditState> emit) async {
    emit(AuditLoading());
    try {
      final logs = await _repo.getLogs();
      emit(AuditLoaded(logs));
    } catch (e) {
      emit(AuditError(e.toString()));
    }
  }
}
