import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;
  static const titles = [
    'Discover Trending\nReal Estate',
    'Chat Property Owner\nDirectly On Arzo',
    'In-App Property\nTour Scheduler',
  ];
  static const descriptions = [
    'Exploring the Booming World of Real Estate: Discovering the Latest Trends and Insights of real estate for sale.',
    'Connecting Property Seekers with Owners: Chat Directly on Arzo for a Seamless Real Estate Experience.',
    'Effortlessly Schedule Property Tours: Explore Your Dream Home with Arzo’s In-App Scheduler.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * .52,
                  child: Container(
                    color: context.header,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          right: -115,
                          bottom: -105,
                          width: 610,
                          child: Image.asset(
                            'assets/images/${['onboarding', 'onboarding_chat', 'onboarding_tour'][_index]}.png',
                          ),
                        ),
                        Positioned(
                          right: -30,
                          bottom: -2,
                          width: 240,
                          child: Image.asset(
                            'assets/images/onboarding_house.png',
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: -3,
                          width: 65,
                          child: Image.asset('assets/images/tree.png'),
                        ),
                        Positioned(
                          left: 30,
                          top: 100,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: blue.withValues(alpha: .1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Color(0xFF6C9FFD),
                              size: 29,
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () =>
                                  AppScope.of(context).finishOnboarding(),
                              child: const Text('Skip'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 26, 26, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const BrandMark(size: 23),
                              const SizedBox(width: 10),
                              Text(
                                ['DISCOVER', 'CONNECT', 'CONNECT'][_index],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              ...List.generate(
                                3,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(left: 5),
                                  width: i == _index ? 17 : 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: i == _index ? blue : context.line,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(titles[_index], style: titleStyle(30)),
                          const SizedBox(height: 16),
                          Text(
                            descriptions[_index],
                            style: const TextStyle(
                              fontSize: 15,
                              color: muted,
                              height: 1.75,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Spacer(),
                          PrimaryButton(
                            _index == 2 ? 'Get Started' : 'Next',
                            onPressed: () {
                              if (_index < 2) {
                                setState(() => _index++);
                              } else {
                                AppScope.of(context).finishOnboarding();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
