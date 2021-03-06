import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/dashboard.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

class DashboardCalendarWidget extends StatefulWidget {
  final Map<DateTime, List> events;

  DashboardCalendarWidget({
    Key key,
    @required this.events,
  }) : super(key: key);

  @override
  State<DashboardCalendarWidget> createState() => _State();
}

class _State extends State<DashboardCalendarWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _today;
  DateTime _selected;
  CalendarFormat _calendarFormat;

  final TextStyle dayTileStyle = TextStyle(
    color: Colors.white,
    fontWeight: LunaUI.FONT_WEIGHT_BOLD,
    fontSize: LunaUI.FONT_SIZE_SUBTITLE,
  );
  final TextStyle outsideDayTileStyle = TextStyle(
    color: Colors.white54,
    fontWeight: LunaUI.FONT_WEIGHT_BOLD,
    fontSize: LunaUI.FONT_SIZE_SUBTITLE,
  );
  final TextStyle unavailableTitleStyle = TextStyle(
    color: Colors.white12,
    fontWeight: LunaUI.FONT_WEIGHT_BOLD,
    fontSize: LunaUI.FONT_SIZE_SUBTITLE,
  );
  final TextStyle weekdayTitleStyle = TextStyle(
    color: LunaColours.accent,
    fontWeight: LunaUI.FONT_WEIGHT_BOLD,
    fontSize: LunaUI.FONT_SIZE_SUBTITLE,
  );

  List _selectedEvents;

  @override
  void initState() {
    super.initState();
    DateTime _floored = context.read<DashboardState>().today.lunaFloor;
    _selected = _floored;
    _today = _floored;
    _selectedEvents = widget.events[_floored] ?? [];
    _calendarFormat = (DashboardDatabaseValue.CALENDAR_STARTING_SIZE.data
            as CalendarStartingSize)
        .data;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    HapticFeedback.selectionClick();
    if (mounted)
      setState(() {
        _selected = selected.lunaFloor;
        _selectedEvents = widget.events[selected.lunaFloor];
      });
  }

  @override
  Widget build(BuildContext context) {
    return LunaScaffold(
        scaffoldKey: _scaffoldKey,
        body: Selector<DashboardState, CalendarStartingType>(
          selector: (_, state) => state.calendarStartingType,
          builder: (context, startingType, _) {
            if (startingType == CalendarStartingType.CALENDAR) {
              return Padding(
                child: Column(
                  children: [
                    _calendar(),
                    LunaDivider(),
                    _calendarList(),
                  ],
                ),
                padding: EdgeInsets.only(top: LunaUI.MARGIN_CARD.top),
              );
            }
            return _schedule();
          },
        ));
  }

  Widget _calendar() {
    return ValueListenableBuilder(
      valueListenable: Database.lunaSeaBox.listenable(keys: [
        DashboardDatabaseValue.CALENDAR_STARTING_DAY.key,
        DashboardDatabaseValue.CALENDAR_STARTING_SIZE.key,
      ]),
      builder: (context, box, _) {
        DateTime firstDay = context.watch<DashboardState>().today.subtract(
              Duration(days: DashboardDatabaseValue.CALENDAR_DAYS_PAST.data),
            );
        DateTime lastDay = context.watch<DashboardState>().today.add(
              Duration(days: DashboardDatabaseValue.CALENDAR_DAYS_FUTURE.data),
            );
        return SafeArea(
          child: LunaCard(
            context: context,
            child: Padding(
              child: TableCalendar(
                rowHeight: 48.0,
                rangeSelectionMode: RangeSelectionMode.disabled,
                simpleSwipeConfig: SimpleSwipeConfig(
                  verticalThreshold: 10.0,
                ),
                focusedDay: _selected,
                firstDay: firstDay,
                lastDay: lastDay,
                //events: widget.events,
                headerVisible: false,
                startingDayOfWeek: (DashboardDatabaseValue
                        .CALENDAR_STARTING_DAY.data as CalendarStartingDay)
                    .data,
                selectedDayPredicate: (date) =>
                    date?.lunaFloor == _selected?.lunaFloor,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  isTodayHighlighted: true,
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: LunaColours.accent.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: LunaColours.accent,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: LunaColours.primary.withOpacity(0.60),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: dayTileStyle,
                  defaultTextStyle: dayTileStyle,
                  disabledTextStyle: unavailableTitleStyle,
                  outsideTextStyle: outsideDayTileStyle,
                  selectedTextStyle: TextStyle(
                    color: LunaColours.accent,
                    fontWeight: LunaUI.FONT_WEIGHT_BOLD,
                  ),
                  todayTextStyle: dayTileStyle,
                ),
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: weekdayTitleStyle,
                  weekdayStyle: weekdayTitleStyle,
                ),
                eventLoader: (date) => widget.events[date.lunaFloor],
                calendarFormat: _calendarFormat,
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.twoWeeks: '2 Weeks',
                  CalendarFormat.week: 'Week',
                },
                onDaySelected: _onDaySelected,
              ),
              padding: LunaUI.MARGIN_DEFAULT
                  .subtract(EdgeInsets.symmetric(horizontal: 6.0)),
            ),
          ),
        );
      },
    );
  }

  Widget _calendarList() {
    if ((_selectedEvents?.length ?? 0) == 0)
      return Expanded(
        child: LunaListView(
          controller: DashboardNavigationBar.scrollControllers[1],
          children: [
            LunaMessage.inList(text: 'dashboard.NoNewContent'.tr()),
          ],
          padding:
              MediaQuery.of(context).padding.copyWith(top: 0.0, bottom: 8.0),
        ),
      );
    return Expanded(
      child: LunaListView(
        controller: DashboardNavigationBar.scrollControllers[1],
        children: _selectedEvents.map(_entry).toList(),
        padding: MediaQuery.of(context).padding.copyWith(top: 0.0, bottom: 8.0),
      ),
    );
  }

  Widget _schedule() {
    if ((widget.events?.length ?? 0) == 0)
      return LunaListView(
        controller: DashboardNavigationBar.scrollControllers[1],
        children: [
          LunaMessage.inList(text: 'dashboard.NoNewContent'.tr()),
        ],
      );
    return LunaListView(
      controller: DashboardNavigationBar.scrollControllers[1],
      children: _buildDays().expand((element) => element).toList(),
    );
  }

  List<List<Widget>> _buildDays() {
    List<List<Widget>> days = [];
    List<DateTime> keys = widget.events.keys.toList();
    keys.sort();
    for (var key in keys) {
      if (key.isAfter(_today.subtract(Duration(days: 1))) &&
          widget.events[key].isNotEmpty) days.add(_day(key));
    }
    return days;
  }

  List<Widget> _day(DateTime day) {
    List<Widget> listCards = [];
    for (int i = 0; i < widget.events[day].length; i++)
      listCards.add(_entry(widget.events[day][i]));
    return [
      LunaHeader(text: DateFormat('EEEE / MMMM dd, y').format(day)),
      ...listCards,
    ];
  }

  Widget _entry(dynamic event) {
    Map headers;
    switch (event.runtimeType) {
      case CalendarLidarrData:
        headers = Database.currentProfileObject.getLidarr()['headers'];
        break;
      case CalendarRadarrData:
        headers = Database.currentProfileObject.getRadarr()['headers'];
        break;
      case CalendarSonarrData:
        headers = Database.currentProfileObject.getSonarr()['headers'];
        break;
      default:
        headers = {};
        break;
    }
    return LunaListTile(
      context: context,
      title: LunaText.title(text: event.title),
      subtitle: RichText(
        text: event.subtitle,
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 2,
      ),
      trailing: event.trailing(context),
      onTap: () async => event.enterContent(context),
      contentPadding: true,
      decoration: LunaCardDecoration(
        uri: event.bannerURI,
        headers: headers,
      ),
    );
  }
}
