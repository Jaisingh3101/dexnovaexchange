import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isPreview;
  const OnboardingScreen({super.key, this.isPreview = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<String> _slides = [
    'assets/oboarding1.png',
    'assets/onboarding2.png',
    'assets/obboarding3.png',
  ];

  final ctrl = PageController();
  int page = 0;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void _skipToExchange() {
    if (widget.isPreview) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  void _continueToWelcome() {
    if (widget.isPreview) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  void _goToPage(int index) {
    ctrl.animateToPage(
      index.clamp(0, _slides.length - 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = page == _slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: ctrl,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => page = i),
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                        child: Image.asset(
                          _slides[i],
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 14,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _skipToExchange,
                          borderRadius: BorderRadius.circular(20),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5FA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE4E6F0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D14182B),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF474C61),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          GestureDetector(
                            onTap: () => _goToPage(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == page ? 26 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                gradient: i == page
                                    ? AppColors.primaryGradient
                                    : null,
                                color: i == page
                                    ? null
                                    : const Color(0xFFD8DCE8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (page > 0) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _goToPage(page - 1),
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE4E6F0),
                                  ),
                                ),
                                child: const Center(
                                  child: FIcon(
                                    Flaticons.arrowLeft,
                                    size: 16,
                                    color: Color(0xFF34394D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: GradientButton(
                            label: lastPage ? 'Get Started' : 'Next',
                            icon: Flaticons.arrowRight,
                            height: 46,
                            onPressed: () {
                              if (!lastPage) {
                                _goToPage(page + 1);
                              } else {
                                _continueToWelcome();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
