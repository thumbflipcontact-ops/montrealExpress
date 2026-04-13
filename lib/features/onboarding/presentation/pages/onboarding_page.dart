import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/features/auth/presentation/pages/login_page.dart';
import 'package:abdoul_express/core/services/onboarding_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Bienvenue sur\nAbdoulExpress',
      'description':
          'Découvrez une nouvelle façon de faire vos achats au Niger. Simple, rapide et fiable.',
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.primaryMain, // Terracotta
    },
    {
      'title': 'Livraison\nRapide',
      'description':
          'Recevez vos commandes en un temps record, directement chez vous ou au bureau.',
      'icon': Icons.rocket_launch_outlined,
      'color': AppColors.tertiaryMain, // Olive Green
    },
    {
      'title': 'Paiement\nSécurisé',
      'description':
          'Payez en toute tranquillité via Mobile Money, Carte Bancaire ou à la livraison.',
      'icon': Icons.lock_outline,
      'color': AppColors.goldAccent, // Gold
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage]['color'].withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage]['color'].withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(
                        context,
                        _pages[index],
                        index == _currentPage,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? _pages[_currentPage]['color']
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Bottom Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentPage < _pages.length - 1)
                              TextButton(
                                onPressed: () {
                                  _pageController.jumpToPage(_pages.length - 1);
                                },
                                child: Text(
                                  'Passer',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 60), // Spacer for alignment

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 60,
                              width: _currentPage == _pages.length - 1
                                  ? 200
                                  : 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_currentPage < _pages.length - 1) {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeOutQuart,
                                    );
                                  } else {
                                    // Mark onboarding as complete
                                    await OnboardingService()
                                        .completeOnboarding();

                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _pages[_currentPage]['color'],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 8,
                                  shadowColor: _pages[_currentPage]['color']
                                      .withValues(alpha: 0.5),
                                ),
                                child: _currentPage == _pages.length - 1
                                    ? const Text(
                                        'Commencer',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    Map<String, dynamic> page,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            height: isActive ? 280 : 240,
            width: isActive ? 280 : 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: page['color'].withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page['icon'], size: 120, color: page['color']),
          ),
          const SizedBox(height: 64),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isActive ? 1.0 : 0.0,
            child: Column(
              children: [
                Text(
                  page['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
