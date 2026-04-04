import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo = AdminRepository();

  AdminBloc() : super(AdminInitial()) {
    on<LoadAdmins>(_onLoadAdmins);
    on<AddAdmin>(_onAddAdmin);
    on<DeleteAdmin>(_onDeleteAdmin);
    on<UpdateAdminRole>(_onUpdateAdminRole);
  }

  Future<void> _onLoadAdmins(LoadAdmins event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    await emit.forEach(
      _repo.getAdmins(),
      onData: (admins) => AdminLoaded(admins),
      onError: (e, _) => AdminError(e.toString()),
    );
  }

  Future<void> _onAddAdmin(AddAdmin event, Emitter<AdminState> emit) async {
    try {
      await _repo.addAdmin(
        email: event.email,
        name: event.name,
        role: event.role,
        currentAdminEmail: event.currentAdminEmail,
        currentAdminPassword: event.currentAdminPassword,
      );
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteAdmin(DeleteAdmin event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteAdmin(event.adminId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateAdminRole(UpdateAdminRole event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateRole(event.adminId, event.role);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
