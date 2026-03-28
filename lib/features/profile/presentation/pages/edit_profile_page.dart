import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/l10n/app_localizations.dart';
import '../../../../components/inputs/up_location_dropdowns.dart';
import '../../../../core/constants/up_locations.dart';

import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedMaritalStatus;
  DateTime? _selectedDateOfBirth;

  bool _submitted = false;

  static const List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const List<String> bloodGroupOptions = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
  static const List<String> maritalStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        _loadUser(state.user);
      }
    });
  }

  void _loadUser(AuthUserModel user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _motherNameController.text = user.motherName ?? '';
    _fatherNameController.text = user.fatherName ?? '';
    _heightController.text = user.height ?? '';
    _weightController.text = user.weight ?? '';
    _notesController.text = user.inbornDiseasesAndNotes ?? '';

    _selectedState = user.state;
    _selectedCity = user.district;
    
    _selectedGender = genderOptions.contains(user.gender) ? user.gender : null;
    _selectedBloodGroup = bloodGroupOptions.contains(user.bloodGroup) ? user.bloodGroup : null;
    _selectedMaritalStatus = maritalStatusOptions.contains(user.maritalStatus) ? user.maritalStatus : null;
    
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDateOfBirth = DateTime.parse(user.dateOfBirth!);
      } catch (e) {
        _selectedDateOfBirth = null;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final missingField = _selectedDateOfBirth == null
        ? 'date of birth'
        : _isBlank(_selectedState)
            ? 'state'
            : _isBlank(_selectedCity)
                ? 'city'
                : _isBlank(_selectedGender)
                    ? 'gender'
                    : _isBlank(_selectedBloodGroup)
                        ? 'blood group'
                        : _isBlank(_selectedMaritalStatus)
                            ? 'marital status'
                            : null;

    if (missingField != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select $missingField')),
      );
      return;
    }
    _submitted = true;

    context.read<AuthCubit>().updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _selectedDateOfBirth!.toIso8601String().split('T')[0],
      stateName: _selectedState?.trim(),
      district: _selectedCity?.trim(),
      motherName: _motherNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      height: _heightController.text.trim(),
      weight: _weightController.text.trim(),
      inbornDiseasesAndNotes: _notesController.text.trim(),
      maritalStatus: _selectedMaritalStatus!,
      bloodGroup: _selectedBloodGroup!,
      gender: _selectedGender!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          l10n.editProfileTitle,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is AuthAuthenticated && _submitted) {
            _submitted = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.profileUpdatedSuccess)),
            );
            context.pop();
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _LabeledField(
                label: l10n.firstName,
                controller: _firstNameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.mandatoryNameError : null,
              ),
              _LabeledField(
                label: l10n.lastName,
                controller: _lastNameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.mandatoryNameError : null,
              ),
              _DatePickerField(
                label: l10n.dateOfBirth,
                selectedDate: _selectedDateOfBirth,
                onDateSelected: (date) => setState(() => _selectedDateOfBirth = date),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UpLocationDropdowns(
                  selectedState: UpLocations.resolveState(_selectedState),
                  selectedCity: UpLocations.resolveCity(_selectedCity),
                  allowAllOptions: false,
                  includeSelectedIfMissing: false,
                  decorationBuilder: (label) => InputDecoration(
                    labelText: label,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    isDense: true,
                  ),
                  onStateChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                ),
              ),
              _LabeledField(label: l10n.motherName, controller: _motherNameController),
              _LabeledField(label: l10n.fatherName, controller: _fatherNameController),
              _LabeledField(label: l10n.height, controller: _heightController),
              _LabeledField(label: l10n.weight, controller: _weightController),
              _DropdownField(
                label: l10n.profileGender,
                value: _selectedGender,
                items: genderOptions,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              _DropdownField(
                label: l10n.profileBlood,
                value: _selectedBloodGroup,
                items: bloodGroupOptions,
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
              ),
              _DropdownField(
                label: l10n.maritalStatus,
                value: _selectedMaritalStatus,
                items: maritalStatusOptions,
                onChanged: (value) => setState(() => _selectedMaritalStatus = value),
              ),
              _LabeledField(
                label: l10n.inbornDiseasesNotes,
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.ambientShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(l10n.saveProfile),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: value,
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              validator: (v) => v == null ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select Date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selectedDate != null ? AppColors.onSurface : AppColors.outlineVariant,
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
