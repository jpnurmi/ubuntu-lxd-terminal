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

class MovableTabButton extends StatelessWidget {
  const MovableTabButton({
    super.key,
    this.icon,
    this.label,
    this.tooltip,
    this.selected,
    this.onPressed,
    this.onClosed,
  });

  final Widget? icon;
  final Widget? label;
  final String? tooltip;
  final bool? selected;
  final VoidCallback? onPressed;
  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      preferBelow: true,
      message: tooltip ?? '',
      child: TextButton(
        key: key,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const BeveledRectangleBorder(),
          primary: selected == true
              ? theme.tabBarTheme.labelColor
              : theme.tabBarTheme.unselectedLabelColor,
        ),
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: selected == true ? 3 : 1,
              color: selected == true
                  ? Theme.of(context).indicatorColor
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: DefaultTextStyle.of(context).style,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: icon!,
                  ),
                if (label != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.center,
                        child: label!,
                      ),
                    ),
                  ),
                if (onClosed != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).colorScheme.onPrimary,
                    iconSize: 16,
                    splashRadius: 16,
                    onPressed: onClosed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
