import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'core/theme/app_colors.dart';
import 'core/providers/locale_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _kenBurnsController;
  late Animation<double> _kenBurnsAnimation;

  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();

    // 10-second Ken Burns zoom effect
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();
    _kenBurnsAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _kenBurnsController, curve: Curves.easeOut),
    );

    // 2-second heartbeat animation
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
    ]).animate(_heartbeatController);
  }

  @override
  void dispose() {
    _kenBurnsController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Ken Burns
          AnimatedBuilder(
            animation: _kenBurnsAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _kenBurnsAnimation.value,
                child: CachedNetworkImage(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAONo5DrR31PRMGeCNUazgxHMeSgf__-2vkDjCHXZz0pctmQ4Yoz553T9G7NQ83TLYYn7j99qOw2ySWiBZd_ITxDHluDAYScNlkcJ0bAqtvoS9iz8-3NSXbn-9xK3c65IzXabK0XLUBzip-PyB93K4I5KlcAH8ZeVfGQE4RZidV5g6vj96ma5mEsuIEILQyVgvz10pgmbm79o9hLAGr-HEoaXcsAMYsLZvfp_VklHGQa_mD6dhUDhiBy2it0Kw-T5GYkvtpN8XigueL',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.primaryContainer),
                  errorWidget: (context, url, error) => Container(color: AppColors.primaryContainer),
                ),
              );
            },
          ),

          // Dark/Green Glass Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Organic Blobs Background Orbs
          Positioned(
            top: -40,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // Top Right Language Toggle
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 24.0),
                    child: InkWell(
                      onTap: () {
                        context.read<LocaleProvider>().toggleLocale();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'EN',
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  width: 1,
                                  height: 12,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                Text(
                                  'हिंदी',
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.language_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Center Branding Area
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AURA Logo with Heartbeat
                    AnimatedBuilder(
                      animation: _heartbeatAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartbeatAnimation.value,
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 64,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aura',
                      style: GoogleFonts.baloo2(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Message
                    Text(
                      'Welcome to your health sanctuary.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'आपके स्वास्थ्य का नया ठिकाना।',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading || state is AuthInitial;
                      
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryContainer],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.push('/login');
                                    },
                                    borderRadius: BorderRadius.circular(100),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(width: 24), // Spacer for centering text
                                          Text(
                                            'Get Started',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Powered by Aura AI Badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'POWERED BY AURA AI',
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
