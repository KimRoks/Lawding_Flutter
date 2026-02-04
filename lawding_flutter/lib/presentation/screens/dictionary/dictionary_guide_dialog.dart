import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class DictionaryGuideDialog extends StatelessWidget {
  const DictionaryGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isLandscape = screenSize.width > screenSize.height;

    // 화면 크기에 따른 반응형 값 계산
    final dialogMaxWidth = isTablet ? 600.0 : double.infinity;
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final verticalPadding = isLandscape ? 24.0 : 32.0;
    final titleSize = isTablet ? 24.0 : 20.0;
    final textSize = isTablet ? 16.0 : 15.0;
    final buttonPadding = isTablet ? 18.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isLandscape ? 40 : 80,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  isLandscape ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '연차 사전 사용 안내',
                      style: pretendard(
                        weight: 700,
                        size: titleSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16 : 24),
                    _buildGuideItem(
                      '본 어플리케이션은 참고용이며, 실제 연차 발생일수 및 관련 내용은 회사 규정 및 관계 법령에 따라 상이할 수 있습니다.',
                      textSize,
                    ),
                    SizedBox(height: isLandscape ? 12 : 16),
                    _buildGuideItem(
                      '이 앱에서 제공하는 정보는 연차유급휴가 산정에 참고 목적으로 제공된 것입니다. 법률적 자문이나 해석을 위한 자료가 아니며, 제작자는 그 결과에 대해 어떠한 책임도 지지 않습니다.',
                      textSize,
                    ),
                    SizedBox(height: isLandscape ? 12 : 16),
                    _buildGuideItem(
                      '구체적인 사안이나 사건과 관련해서는 본 사이트 내용을 근거로 어떠한 행위(작위 또는 부작위)도 하지 마시기 바랍니다. 어떠한 행위라도 본 제작자는 민·형사상 책임을 지지 않습니다.',
                      textSize,
                    ),
                    SizedBox(height: isLandscape ? 12 : 16),
                    _buildGuideItem(
                      '최종 해석 및 적용은 회사 규정과 관계 법령에 따릅니다.',
                      textSize,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                isLandscape ? 16 : 24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '이해했습니다',
                    style: pretendard(
                      weight: 700,
                      size: textSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, double textSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: textSize * 1.4,
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: pretendard(
              weight: 500,
              size: textSize,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
