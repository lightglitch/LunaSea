import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';

class TautulliUserDetailsNavigationBar extends StatelessWidget {
  final PageController pageController;
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());

  static const List<IconData> icons = [
    LunaIcons.user,
    LunaIcons.history,
    Icons.sync,
    Icons.computer,
  ];

  static const List<String> titles = [
    'Profile',
    'History',
    'Synced',
    'IPs',
  ];

  TautulliUserDetailsNavigationBar({
    Key key,
    @required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LunaBottomNavigationBar(
      pageController: pageController,
      scrollControllers: scrollControllers,
      icons: icons,
      titles: titles,
    );
  }
}
