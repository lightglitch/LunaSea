import 'package:flutter/material.dart';

class LunaReorderableListView extends StatelessWidget {
    final List<Widget> children;
    final EdgeInsetsGeometry padding;
    final ScrollPhysics physics;
    final ScrollController controller;
    final void Function(int, int) onReorder;

    LunaReorderableListView({
        Key key,
        @required this.children,
        @required this.controller,
        @required this.onReorder,
        this.padding,
        this.physics = const AlwaysScrollableScrollPhysics(),
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scrollbar(
            controller: controller,
            child: ReorderableListView(
                scrollController: controller,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: children,
                padding: padding ?? MediaQuery.of(context).padding.add(EdgeInsets.symmetric(vertical: 8.0)),
                physics: physics,
                onReorder: onReorder,
            ),
        );
    }
}