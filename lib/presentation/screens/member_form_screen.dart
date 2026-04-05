import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../bloc/member/member_bloc.dart';
import '../../bloc/member/member_event.dart';
import '../../bloc/women/women_member_bloc.dart';
import '../../data/models/member_model.dart';

class MemberFormScreen extends StatefulWidget {
  final MemberModel? member;
  final bool isWomen;
  const MemberFormScreen({super.key, this.member, this.isWomen = false});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _cpr, _phone, _birthday,
      _referral, _benefit, _cash, _creditCard;
  String _membership = '';
  String _package = '';
  String _recept = '';
  String _status = 'active';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  static const _membershipOptions = ['1 day', '1 month', '1 year', '2 weeks', '3 month', '6 month', 'special'];
  static const _packageOptions = ['2in1', 'Boxing', 'crossfit', 'gym', 'gym & Box'];
  static const _receptOptions = ['Sultan', 'Harris', 'Mikel', 'Abubakar', 'Andrey', 'Ashiraf', 'Astemir', 'Fahad', 'Nik', 'Zahra'];
  static const _statusOptions = ['active', 'inactive', 'frozen'];

  String? _matchDropdown(String value, List<String> options) {
    if (value.isEmpty) return null;
    // Exact match
    if (options.contains(value)) return value;
    // Case-insensitive match
    for (final o in options) {
      if (o.toLowerCase() == value.toLowerCase()) return o;
    }
    return null;
  }

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _name       = TextEditingController(text: m?.name ?? '');
    _cpr        = TextEditingController(text: m?.cpr ?? '');
    _phone      = TextEditingController(text: m?.phone ?? '');
    _birthday   = TextEditingController(text: m?.birthday ?? '');
    _referral   = TextEditingController(text: m?.referral ?? '');
    _benefit    = TextEditingController(text: m?.benefit ?? '');
    _cash       = TextEditingController(text: m?.cash ?? '');
    _creditCard = TextEditingController(text: m?.creditCard ?? '');
    if (m != null) {
      _membership = _matchDropdown(m.membership, _membershipOptions) ?? '';
      _package    = _matchDropdown(m.package, _packageOptions) ?? '';
      _recept     = _matchDropdown(m.recept, _receptOptions) ?? '';
      _status     = _matchDropdown(m.status, _statusOptions) ?? 'active';
      _startDate  = m.startDate;
      _endDate    = m.endDate;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _cpr.dispose(); _phone.dispose(); _birthday.dispose();
    _referral.dispose(); _benefit.dispose();
    _cash.dispose(); _creditCard.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final member = MemberModel(
      id:           widget.member?.id ?? '',
      cpr:          _cpr.text.trim(),
      name:         _name.text.trim(),
      birthday:     _birthday.text.trim(),
      phone:        _phone.text.trim(),
      membership:   _membership,
      referral:     _referral.text.trim(),
      package:      _package,
      startDate:    _startDate,
      endDate:      _endDate,
      recept:       _recept,
      benefit:      _benefit.text.trim(),
      cash:         _cash.text.trim(),
      creditCard:   _creditCard.text.trim(),
      status:       _status,
      createdBy:    widget.member?.createdBy ?? adminId,
      lastEditedBy: adminId,
    );
    if (_isEditing) {
      if (widget.isWomen) {
        context.read<WomenMemberBloc>().add(UpdateMember(member));
      } else {
        context.read<MemberBloc>().add(UpdateMember(member));
      }
    } else {
      if (widget.isWomen) {
        context.read<WomenMemberBloc>().add(AddMember(member));
      } else {
        context.read<MemberBloc>().add(AddMember(member));
      }
    }
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: keyboard,
        validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Member' : 'Add Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _field('Full Name', _name, required: true),
              _field('CPR', _cpr),
              _field('Phone', _phone, keyboard: TextInputType.phone),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _birthday,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _birthday.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    }
                  },
                ),
              ),

              const Text('Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _matchDropdown(_membership, _membershipOptions),
                  decoration: const InputDecoration(labelText: 'Membership', border: OutlineInputBorder()),
                  items: _membershipOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1))))
                      .toList(),
                  onChanged: (v) => setState(() => _membership = v ?? ''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _matchDropdown(_package, _packageOptions),
                  decoration: const InputDecoration(labelText: 'Package', border: OutlineInputBorder()),
                  items: _packageOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _package = v ?? ''),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _matchDropdown(_status, _statusOptions),
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: _statusOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('Start: ${_startDate.toLocal().toString().split(' ')[0]}'),
                      onPressed: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('End: ${_endDate.toLocal().toString().split(' ')[0]}'),
                      onPressed: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _matchDropdown(_recept, _receptOptions),
                  decoration: const InputDecoration(labelText: 'Recept', border: OutlineInputBorder()),
                  items: _receptOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _recept = v ?? ''),
                ),
              ),
              _field('Benefit', _benefit),
              _field('Cash', _cash, keyboard: TextInputType.number),
              _field('Credit Card', _creditCard, keyboard: TextInputType.number),

              const Text('Other', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _field('Referral (how they found us)', _referral),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save Changes' : 'Add Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
