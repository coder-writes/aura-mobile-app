import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/l10n/app_localizations.dart';
import '../../../../components/ui/aura_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../appointments/presentation/pages/doctor_list_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../scan/presentation/pages/scan_page.dart';
import 'dashboard_screen.dart';

class HomePage extends StatefulWidget {
  final int initialTabIndex;

  const HomePage({super.key, this.initialTabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get auth user to pass state/district to DoctorListScreen
    final authState = context.watch<AuthCubit>().state;
    String? userState;
    String? userDistrict;

    if (authState is AuthAuthenticated) {
      userState = authState.user.state;
      userDistrict = authState.user.district;
    }

    final screens = [
      DashboardScreen(onTabChange: _onTabChanged),
      const ScanPage(),
      DoctorListScreen(userState: userState, userDistrict: userDistrict),
      Scaffold(body: Center(child: Text(l10n.abhaPlaceholder))),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true, // Crucial for floating glassmorphic nav bar
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: AuraBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
