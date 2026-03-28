import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../components/inputs/up_location_dropdowns.dart';
import '../../../../../core/constants/up_locations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../cubit/doctor_list_cubit.dart';
import '../widgets/doctor_card.dart';
import 'booking_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String? userState;
  final String? userDistrict;

  const DoctorListScreen({
    super.key,
    this.userState,
    this.userDistrict,
  });

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String? _selectedSpecialty;

  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _syncFromUserPreset();
    // Fetch doctors on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorListCubit>().fetchDoctors(
            state: _selectedState,
            district: _selectedCity,
          );
    });
  }

  @override
  void didUpdateWidget(covariant DoctorListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userState != widget.userState ||
        oldWidget.userDistrict != widget.userDistrict) {
      _syncFromUserPreset();
      _selectedSpecialty = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DoctorListCubit>().fetchDoctors(
              state: _selectedState,
              district: _selectedCity,
            );
      });
    }
  }

  void _syncFromUserPreset() {
    _selectedState = UpLocations.resolveState(widget.userState);
    _selectedCity = _resolveCityFromUser(_selectedState, widget.userDistrict);
  }

  String? _resolveCityFromUser(String? state, String? rawCity) {
    if (state == null) return null;
    return UpLocations.resolveCity(rawCity);
  }

  void _applyLocationFilter() {
    setState(() => _selectedSpecialty = null);
    context.read<DoctorListCubit>().fetchDoctors(
          state: _selectedState,
          district: _selectedCity,
        );
  }

  void _clearLocationFilter() {
    setState(() {
      _selectedState = null;
      _selectedCity = null;
      _selectedSpecialty = null;
    });
    context.read<DoctorListCubit>().fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
       
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BlocBuilder<DoctorListCubit, DoctorListState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Priority Status Banner
                      _buildPriorityBanner(),
                      const SizedBox(height: 16),
                      _buildLocationFilterCard(),
                      const SizedBox(height: 20),

                      if (state is DoctorListLoaded) ...[
                        Text(
                          'Filter by Specialty',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _filterPill(
                                'All Doctors',
                                _selectedSpecialty == null,
                                () {
                                  setState(() => _selectedSpecialty = null);
                                  context.read<DoctorListCubit>().resetFilter();
                                },
                              ),
                              ...state.getUniqueSpecialties().map(
                                (specialty) => _filterPill(
                                  specialty,
                                  _selectedSpecialty == specialty,
                                  () {
                                    setState(() => _selectedSpecialty = specialty);
                                    context
                                        .read<DoctorListCubit>()
                                        .filterBySpecialty(specialty);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Section Header
                      if (state is DoctorListLoaded && state.doctors.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Rated Specialists',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryContainer,
                                  ),
                                ),
                                Text(
                                  '— विशेषज्ञ डॉक्टर',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (state is DoctorListLoading && state.previousDoctors.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Refreshing doctors...',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          BlocBuilder<DoctorListCubit, DoctorListState>(
            builder: (context, state) {
              if (state is DoctorListLoading) {
                if (state.previousDoctors.isNotEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doctor = state.previousDoctors[index];
                          return Opacity(
                            opacity: 0.85,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DoctorCard(
                                doctor: doctor,
                                onBookNow: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingScreen(doctor: doctor),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        childCount: state.previousDoctors.length,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _DoctorCardSkeleton(),
                      ),
                      childCount: 4,
                    ),
                  ),
                );
              } else if (state is DoctorListError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text('Error Loading Doctors', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DoctorListCubit>().fetchDoctors(
                                  state: _selectedState,
                                  district: _selectedCity,
                                );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is DoctorListLoaded && state.doctors.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No doctors found', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                );
              } else if (state is DoctorListLoaded) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doctor = state.doctors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DoctorCard(
                            doctor: doctor,
                            onBookNow: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(doctor: doctor),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: state.doctors.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildPriorityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFEA619).withValues(alpha: 0.1),
            const Color(0xFFFEA619).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFEA619).withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEA619),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFEA619).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ You have Priority Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text("You'll be seen first in the queue.", style: AppTextStyles.bodySmall),
                Text(
                  'आपको प्राथमिकता दी जाएगी - आप पहले देखे जाएंगे',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilterCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Filter by location',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          UpLocationDropdowns(
            selectedState: _selectedState,
            selectedCity: _selectedCity,
            decorationBuilder: _filterInputDecoration,
            allowAllOptions: true,
            onStateChanged: (value) {
              setState(() {
                _selectedState = value;
                _selectedCity = null; // Clear city when state changes
              });
              _applyLocationFilter(); // Automatic search
            },
            onCityChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
              _applyLocationFilter(); // Automatic search
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearLocationFilter,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear Filters'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _filterInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _filterPill(String label, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onTap(),
        selected: isActive,
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _DoctorCardSkeleton extends StatelessWidget {
  const _DoctorCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 120, color: AppColors.surfaceContainerHighest),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 90, color: AppColors.surfaceContainerHighest),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 10, width: 80, color: AppColors.surfaceContainerHighest),
              Container(height: 36, width: 110, color: AppColors.surfaceContainerHighest),
            ],
          ),
        ],
      ),
    );
  }
}
