import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class CalendarTutorialScreen extends StatefulWidget {
  /// 튜토리얼 완료 후 호출되는 콜백
  final VoidCallback onFinished;

  const CalendarTutorialScreen({super.key, required this.onFinished});

  @override
  State<CalendarTutorialScreen> createState() => _CalendarTutorialScreenState();
}

class _CalendarTutorialScreenState extends State<CalendarTutorialScreen>
    with SingleTickerProviderStateMixin {
  static const _pages = [
    _TutorialPage(
      label: '자신에게 생긴 연차를 캘린더에\n자유롭게 등록하세요',
      imagePath: 'assets/icons/calendar_tutorial1.png',
    ),
    _TutorialPage(
      label: '등록 과정에서 자신의 일정과\n사용한 시간을 계획하세요',
      imagePath: 'assets/icons/calendar_tutorial2.png',
    ),
    _TutorialPage(
      label: '등록한 연차의\n세부계획을 확인하세요',
      imagePath: 'assets/icons/calendar_tutorial3.png',
    ),
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _entranceController;
  late final Animation<double> _labelFade;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _imageFade;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _bottomFade;
  late final Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _labelFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _labelSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _imageFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );
    _imageSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
          ),
        );

    _bottomFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    if (_currentPage == _pages.length - 1) {
      widget.onFinished();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 85),

            // ── 레이블 ────────────────────────────────────────────────────────
            FadeTransition(
              opacity: _labelFade,
              child: SlideTransition(
                position: _labelSlide,
                child: Text(
                  _pages[_currentPage].label,
                  textAlign: TextAlign.center,
                  style: pretendard(
                    weight: 600,
                    size: 24,
                    color: AppColors.textGray11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── 가운데 이미지 (하단 버튼과 46 간격, 기기 대응) ──────────────
            Expanded(
              child: FadeTransition(
                opacity: _imageFade,
                child: SlideTransition(
                  position: _imageSlide,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 46),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.orientationOf(context) ==
                                  Orientation.landscape
                              ? MediaQuery.sizeOf(context).width * 0.88
                              : MediaQuery.sizeOf(context).shortestSide * 0.88,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gradientHeight = constraints.maxHeight * 0.15;
                            return Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: _pages.length,
                                  onPageChanged: (page) =>
                                      setState(() => _currentPage = page),
                                  itemBuilder: (context, index) {
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        _pages[index].imagePath,
                                        width: constraints.maxWidth,
                                      ),
                                    );
                                  },
                                ),
                                // 하단 페이드 아웃 그라데이션
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  height: gradientHeight,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Color(0xFFF1F1F1),
                                          Color(0x00F1F1F1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 최하단 이전 / 페이지 인디케이터 / 다음 ─────────────────────
            FadeTransition(
              opacity: _bottomFade,
              child: SlideTransition(
                position: _bottomSlide,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    children: [
                      // 이전 버튼 — 오른쪽 버튼과 동일 너비 확보
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _NavButton(
                            label: '이전',
                            enabled: _currentPage > 0,
                            onTap: _goToPrevious,
                          ),
                        ),
                      ),

                      // 페이지 인디케이터 — 항상 정가운데 고정
                      Row(
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.brandColor
                                  : AppColors.textGrayCC,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      // 다음 / 시작하기 버튼 — 왼쪽 버튼과 동일 너비 확보
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _NavButton(
                            label: _currentPage == _pages.length - 1
                                ? '시작하기'
                                : '다음',
                            enabled: true,
                            onTap: _goToNext,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage {
  final String label;
  final String imagePath;

  const _TutorialPage({required this.label, required this.imagePath});
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Text(
          label,
          style: pretendard(
            weight: 600,
            size: 15,
            color: enabled ? AppColors.brandColor : AppColors.textGrayCC,
          ),
        ),
      ),
    );
  }
}
