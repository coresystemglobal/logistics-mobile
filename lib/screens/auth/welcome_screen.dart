import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  static const _slides = [
    _WelcomeSlide(
      title: 'Send your items,\nanywhere.',
      body: 'Book a delivery in seconds.\nReal-time tracking. Zero stress.',
      icon: Icons.inventory_2_outlined,
      iconBg: AppColors.accentLight,
      iconColor: AppColors.accent,
    ),
    _WelcomeSlide(
      title: 'Track in real-time.',
      body: 'Watch your package move\nfrom pickup to delivery.',
      icon: Icons.location_on_outlined,
      iconBg: Color(0xFFE8F0FE),
      iconColor: AppColors.iosBlue,
    ),
    _WelcomeSlide(
      title: 'Safe, fast\ndelivery.',
      body: 'Trusted riders. Verified routes.\nEvery delivery, on time.',
      icon: Icons.speed_outlined,
      iconBg: Color(0xFFE9F7EF),
      iconColor: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/auth/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Hero area (top ~52%)
          SizedBox(
            height: size.height * 0.52,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _HeroArea(slide: _slides[i]),
            ),
          ),
          // Bottom card slides up
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.52,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            height: 6,
                            width: isActive ? 24 : 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      // Text
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey(_currentPage),
                            children: [
                              Text(
                                _slides[_currentPage].title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.21,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _slides[_currentPage].body,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  color: AppColors.textTertiary,
                                  height: 1.47,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: TrakaButton(
                          label: _currentPage == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _nextPage,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => context.push('/auth/login'),
                        child: Text(
                          'Already have an account? Sign in',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.iosBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArea extends StatelessWidget {
  final _WelcomeSlide slide;
  const _HeroArea({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1.06),
            duration: const Duration(milliseconds: 2200),
            curve: Curves.easeInOut,
            builder: (_, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: slide.iconBg.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: slide.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, color: slide.iconColor, size: 56),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSlide {
  final String title;
  final String body;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _WelcomeSlide({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}
