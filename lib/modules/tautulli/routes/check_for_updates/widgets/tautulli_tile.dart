import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/tautulli.dart';

class TautulliCheckForUpdatesTautulliTile extends StatelessWidget {
  final TautulliUpdateCheck update;

  TautulliCheckForUpdatesTautulliTile({
    Key key,
    @required this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LunaListTile(
      context: context,
      title: LunaText.title(text: 'Tautulli'),
      subtitle: _subtitle(),
      trailing: _trailing(),
      contentPadding: true,
    );
  }

  Widget _trailing() {
    return Column(
      children: [
        LunaIconButton(
          icon: LunaIcons.tautulli,
          color: LunaColours().byListIndex(1),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _subtitle() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.white70,
          fontSize: LunaUI.FONT_SIZE_SUBTITLE,
        ),
        children: <TextSpan>[
          if (!update.update)
            TextSpan(
              text: 'No Updates Available\n',
              style: TextStyle(
                color: LunaColours.accent,
                fontWeight: LunaUI.FONT_WEIGHT_BOLD,
              ),
            ),
          if (update.update)
            TextSpan(
              text: 'Update Available\n',
              style: TextStyle(
                color: LunaColours.orange,
                fontWeight: LunaUI.FONT_WEIGHT_BOLD,
              ),
            ),
          if (update.update)
            TextSpan(
              text:
                  'Current Version: ${update.currentRelease ?? update.currentVersion?.substring(0, min(7, update.currentVersion?.length ?? 0)) ?? 'Unknown'}\n',
            ),
          if (update.update)
            TextSpan(
              text:
                  'Latest Version: ${update.latestRelease ?? update.latestVersion?.substring(0, min(7, update.latestVersion?.length ?? 0)) ?? 'Unknown'}\n',
            ),
          TextSpan(text: 'Install Type: ${update.installType}'),
        ],
      ),
      overflow: TextOverflow.fade,
      maxLines: 4,
    );
  }
}
