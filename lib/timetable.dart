import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

class TimeTable extends StatefulWidget {
  final String routeShortName;

  const TimeTable({super.key, required this.routeShortName});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> with TickerProviderStateMixin {
  late AnimationController _primary, _secondary;
  late Animation<double> _animationPrimary, _animationSecondary;
  List<BusTimeTable>? _timeTable;
  int index = 0;
  bool showExpiredTimes = true;

  @override
  void initState() {
    //Primaty
    _primary =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationPrimary = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _primary, curve: Curves.easeOut));
    //Secondary
    _secondary =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationSecondary = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _secondary, curve: Curves.easeOut));
    _primary.forward();
    super.initState();

    retrieveTable();
    showExpiredTimes = prefs.getBool('showExpiredTimes') ?? true;
  }

  void retrieveTable() async {
    _timeTable = await getTimeTable(
        widget.routeShortName, '${time.year}-${time.month}-${time.day}');
    setState(() {});
  }

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  // cannot be generated when _timetable is null
  Row _buildSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropdownButton<int>(
          value: index,
          onChanged: (int? newValue) {
            setState(() {
              index = newValue ?? 0;
            });
          },
          items: _timeTable?.map((BusTimeTable e) {
                return DropdownMenuItem<int>(
                  value: _timeTable?.indexOf(e) ?? 0,
                  child: Text(e.destination),
                );
              }).toList() ??
              [],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.showExpiredTimes),
            const SizedBox(
              width: 10,
            ),
            Switch(
              value: showExpiredTimes,
              onChanged: (bool newValue) {
                setState(() {
                  showExpiredTimes = newValue;
                  prefs.setBool('showExpiredTimes', newValue);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDialog(Widget child) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  DateTime time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CupertinoFullscreenDialogTransition(
      primaryRouteAnimation: _animationPrimary,
      secondaryRouteAnimation: _animationSecondary,
      linearTransition: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${AppLocalizations.of(context)!.busRouteSelectionMenuTitle} ${widget.routeShortName}',
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _primary.reverse();
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            },
          ),
        ),
        body: Stack(
          children: [
            if (_timeTable != null)
              SingleChildScrollView(
                  child: Column(
                children: [
                  Row(children: [
                    Expanded(child: Container()),
                    Text(
                      AppLocalizations.of(context)!.date,
                      style: const TextStyle(
                        fontSize: 22.0,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    CupertinoButton(
                      // Display a CupertinoDatePicker in time picker mode.
                      onPressed: () => _showDialog(
                        CupertinoDatePicker(
                          initialDateTime: time,
                          mode: CupertinoDatePickerMode.date,
                          showDayOfWeek: true,
                          use24hFormat: false,
                          // This is called when the user changes the time.
                          onDateTimeChanged: (DateTime newTime) {
                            setState(() {
                              time = newTime;
                            });
                          },
                        ),
                      ).then((value) {
                        setState(() {
                          _timeTable = null;
                          retrieveTable();
                        });
                      }),
                      // In this example, the time value is formatted manually.
                      // You can use the intl package to format the value based on
                      // the user's locale settings.
                      child: Text(
                        '${time.month}-${time.day}-${time.year}',
                        style: const TextStyle(
                          fontSize: 22.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(child: Container()),
                  ]),
                  _buildSettingsRow(),
                  SafeArea(
                      child:
                          _buildTableFromHTML(_timeTable?[index].html ?? '')),
                ],
              )),
            if (_timeTable == null)
              ModalBarrier(
                  dismissible: false, color: Colors.black.withAlpha(100)),
            if (_timeTable == null)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableFromHTML(String html) {
    if (html.isEmpty) {
      return Container();
    }
    final parsed = parse("<table>$html</table>");
    if (parsed.getElementsByTagName('thead').isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noBusServiceFound,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      );
    }
    final heads =
        parsed.getElementsByTagName('thead').first.getElementsByTagName('th');
    final table = parsed.getElementsByTagName('tbody').first;
    final rows = table.getElementsByTagName('tr');

    List<TableRow> tableRows = [];

    // first add headers
    List<TableCell> tableCells = [];
    for (final head in heads) {
      tableCells.add(TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(head.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17))),
      ));
    }
    tableRows.add(TableRow(
      children: tableCells,
    ));

    // then add rows
    for (final row in rows) {
      final cells = row.getElementsByTagName('td');
      tableCells = [];

      bool empty = true;
      for (final cell in cells) {
        if (cell.children.isEmpty) {
          tableCells.add(const TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Text('',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16))),
          ));
        } else {
          final dateString = cell.children.first.attributes['datetime'];
          final date = DateFormat('M/d/y hh:mm:ss aaa').parse(dateString ?? '');
          final setNowDate = DateTime.now();
          final isBeforeAndDontShowExpired =
              date.isBefore(setNowDate) && !showExpiredTimes;
          if (date.isAfter(setNowDate) && empty) {
            empty = false;
          }
          tableCells.add(TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(isBeforeAndDontShowExpired ? '' : cell.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16))),
          ));
        }
      }
      if (empty && !showExpiredTimes) {
        continue;
      }
      tableRows.add(TableRow(
        children: tableCells,
      ));
    }

    return Table(
      border: const TableBorder(horizontalInside: BorderSide(width: 1)),
      children: tableRows,
    );
  }
}
