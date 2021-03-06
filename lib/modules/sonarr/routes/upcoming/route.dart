import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrUpcomingRoute extends StatefulWidget {
  @override
  State<SonarrUpcomingRoute> createState() => _State();
}

class _State extends State<SonarrUpcomingRoute>
    with AutomaticKeepAliveClientMixin, LunaLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  Future<void> loadCallback() async {
    context.read<SonarrState>().resetUpcoming();
    await context.read<SonarrState>().upcoming;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LunaScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return LunaRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: Selector<SonarrState, Future<List<SonarrCalendar>>>(
        selector: (_, state) => state.upcoming,
        builder: (context, future, _) => FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<List<SonarrCalendar>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting) {
                LunaLogger().error('Unable to fetch Sonarr upcoming episodes',
                    snapshot.error, snapshot.stackTrace);
              }
              return LunaMessage.error(onTap: _refreshKey.currentState?.show);
            }
            if (snapshot.hasData) return _episodes(snapshot.data);
            return LunaLoader();
          },
        ),
      ),
    );
  }

  Widget _episodes(List<SonarrCalendar> upcoming) {
    if ((upcoming?.length ?? 0) == 0)
      return LunaMessage(
        text: 'No Episodes Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    // Split episodes into days into a map
    Map<String, Map<String, dynamic>> _episodeMap =
        upcoming.fold({}, (map, entry) {
      if (entry.airDateUtc == null) return map;
      String _date = DateFormat('y-MM-dd').format(entry.airDateUtc.toLocal());
      if (!map.containsKey(_date))
        map[_date] = {
          'date': DateFormat('EEEE / MMMM dd, y')
              .format(entry.airDateUtc.toLocal()),
          'entries': [],
        };
      (map[_date]['entries'] as List).add(entry);
      return map;
    });
    // Build the widgets
    List<List<Widget>> _episodeWidgets = [];
    _episodeMap.keys.toList()
      ..sort()
      ..forEach((key) => {
            _episodeWidgets.add(_buildDay(
              (_episodeMap[key]['date'] as String),
              (_episodeMap[key]['entries'] as List).cast<SonarrCalendar>(),
            )),
          });
    // Return the list
    return LunaListView(
      controller: SonarrNavigationBar.scrollControllers[1],
      children: _episodeWidgets.expand((e) => e).toList(),
    );
  }

  List<Widget> _buildDay(String date, List<SonarrCalendar> upcoming) => [
        LunaHeader(text: date),
        ...List.generate(
          upcoming.length,
          (index) => SonarrUpcomingTile(record: upcoming[index]),
        ),
      ];
}
