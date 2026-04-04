import 'package:equatable/equatable.dart';
import '../../data/models/member_model.dart';

abstract class MemberState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {}
class MemberLoading extends MemberState {}
class MemberLoaded extends MemberState {
  final List<MemberModel> members;
  final Map<String, int>? stats;
  final List<MemberModel>? expiringSoonList;
  
  // Cached computed values
  late final int _total;
  late final int _active;
  late final int _inactive;
  late final int _frozen;
  late final List<MemberModel> _expiringSoon;

  MemberLoaded(this.members, {this.stats, this.expiringSoonList}) {
    // Cache expensive computations
    if (stats != null) {
      _total = stats!['total'] ?? members.length;
      _active = stats!['active'] ?? 0;
      _inactive = stats!['inactive'] ?? 0;
      _frozen = stats!['frozen'] ?? 0;
    } else {
      _total = members.length;
      _active = members.where((m) => m.status == 'active').length;
      _inactive = members.where((m) => m.status == 'inactive').length;
      _frozen = members.where((m) => m.status == 'frozen').length;
    }
    
    if (expiringSoonList != null) {
      _expiringSoon = expiringSoonList!;
    } else {
      _expiringSoon = members.where((m) {
        final daysLeft = m.endDate.difference(DateTime.now()).inDays;
        return daysLeft <= 7 && daysLeft >= 0 && m.status == 'active';
      }).toList();
    }
  }

  // Use cached values instead of recomputing
  int get total => _total;
  int get active => _active;
  int get inactive => _inactive;
  int get frozen => _frozen;
  List<MemberModel> get expiringSoon => _expiringSoon;

  @override
  List<Object?> get props => [members, stats, expiringSoonList];
}

class MemberError extends MemberState {
  final String message;
  MemberError(this.message);
  @override
  List<Object?> get props => [message];
}
