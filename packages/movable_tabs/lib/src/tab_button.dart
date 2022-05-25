import 'package:flutter/material.dart';

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
