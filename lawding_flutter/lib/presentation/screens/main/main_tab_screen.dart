import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/services/analytics_service.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_scaffold.dart';

/// 탭 아이템 정보를 담는 클래스
class TabItemInfo {
  final String title;
  final Widget icon;
  final Widget? activeIcon;
  final Widget screen;
  final VoidCallback? onTabActivated; // 탭이 활성화될 때 호출되는 콜백

  const TabItemInfo({
    required this.title,
    required this.icon,
    this.activeIcon,
    required this.screen,
    this.onTabActivated,
  });
}

class MainTabScreen extends ConsumerStatefulWidget {
  final List<TabItemInfo> tabs;
  final int initialIndex;

  const MainTabScreen({super.key, required this.tabs, this.initialIndex = 0});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // 초기 탭의 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tabs[_currentIndex].onTabActivated?.call();
    });
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    // 하단 탭바 직접 탭 시에도 provider 동기화
    // → 외부에서 activeTabIndexProvider를 set할 때 이미 같은 값이면 리스너가 미발동하는 문제 방지
    if (ref.read(activeTabIndexProvider) != index) {
      ref.read(activeTabIndexProvider.notifier).state = index;
    }

    AnalyticsService().logTabChanged(
      index: index,
      tabName: widget.tabs[index].title,
    );
    widget.tabs[index].onTabActivated?.call();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeTabIndexProvider, (_, next) => _onTabChanged(next));
    return CustomScaffold(
          backgroundColor: Colors.white,
          useDefaultAppBar: false,
          dismissKeyboardOnTap: false,
          body: IndexedStack(
            index: _currentIndex,
            children: widget.tabs.map((tab) => tab.screen).toList(),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabChanged,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    selectedItemColor: AppColors.brandColor,
                    unselectedItemColor: AppColors.textGray99,
                    selectedFontSize: 10,
                    unselectedFontSize: 10,
                    selectedLabelStyle: pretendard(weight: 600, size: 10),
                    unselectedLabelStyle: pretendard(weight: 600, size: 10),
                    items: widget.tabs.map((tab) {
                      return BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: tab.icon,
                        ),
                        activeIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: tab.activeIcon ?? tab.icon,
                        ),
                        label: tab.title,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
