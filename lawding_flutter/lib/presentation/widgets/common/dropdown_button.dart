import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class CustomDropdownButton<T> extends StatefulWidget {
  final String? selectedValue;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T> onChanged;
  final String placeholder;

  const CustomDropdownButton({
    super.key,
    this.selectedValue,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.placeholder = '선택',
  });

  @override
  State<CustomDropdownButton<T>> createState() =>
      _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _animationController!.forward();

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.95 + (0.05 * _animationController!.value),
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: _animationController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final itemTitle = widget.itemBuilder(item);
                          final isSelected = itemTitle == widget.selectedValue;

                          return InkWell(
                            onTap: () {
                              widget.onChanged(item);
                              _removeOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: index < widget.items.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Text(
                                itemTitle,
                                style: pretendard(
                                  weight: isSelected ? 600 : 500,
                                  size: 15,
                                  color: isSelected
                                      ? AppColors.brandColor
                                      : AppColors.primaryTextColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() async {
    await _animationController!.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: 144,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.selectedValue ?? widget.placeholder,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: pretendard(weight: 500, size: 15).copyWith(
                    color: widget.selectedValue != null
                        ? AppColors.primaryTextColor
                        : AppColors.textGrayCC,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.textGrayCC,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
