import 'package:flutter/material.dart';

typedef OnMovedCallback = void Function(int from, int to);

class MovableTabBar extends StatelessWidget implements PreferredSizeWidget {
  MovableTabBar({
    super.key,
    required this.count,
    required this.builder,
    required this.onMoved,
    double? preferredHeight,
  }) : preferredSize = Size.fromHeight(preferredHeight ?? kToolbarHeight);

  final int count;
  final IndexedWidgetBuilder builder;
  final OnMovedCallback onMoved;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ReorderableListView.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            final isLast = index >= count - 1;
            return ReorderableDragStartListener(
              key: ValueKey(index),
              index: index,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: constraints.maxWidth / count - (!isLast ? 1 : 0),
                    child: builder(context, index),
                  ),
                  if (!isLast) const VerticalDivider(width: 1),
                ],
              ),
            );
          },
          buildDefaultDragHandles: false,
          onReorder: (from, to) {
            final newIndex = to > from ? to - 1 : to;
            onMoved.call(from, newIndex);
          },
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
        );
      },
    );
  }
}
