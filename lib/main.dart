import 'dart:async';
import 'package:bus_hunter/mapped_bus_data.dart';
import 'package:bus_hunter/route_state_manager.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/map/apple_maps.dart';
import 'package:bus_hunter/timetable.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  Logger.level = Level.info;
  runApp(const MyApp());
}

Logger logger = Logger(
  printer: PrettyPrinter(),
  output: ConsoleOutput(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ja'), // Japanese
        Locale('zh') // Chinese
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

typedef BusRouteData = (List<BusRoutePattern>, List<BusPoint>);

int a = 0;

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  RouteStateManager routeStateManager = RouteStateManager();
  String? loadingStatus;
  bool? isLoading = false;

  Timer? timer;

  AppleMapController? mapController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        logger.i('App resumed');
        if (routeStateManager.routeSelected) {
          timer?.cancel();
          isLoading = true;
          rebuildConnectionAndStartPolling();
          // run in background to prepare
          rebuildConnection(hub: Hub.time);
        }
      });
    }
  }

  Future<void> rebuildConnectionAndStartPolling() async {
    await rebuildConnection();
    startBusPolling();
  }

  @override
  initState() {
    super.initState();
    _fabHeight = _initFabHeight;
    initAppElementsWhileLoading().then((value) async {
      setState(() {
        isLoading = true;
      });
      await startServerConnection();
      // run in background to prepare
      startServerConnection(hub: Hub.time);
      routeStateManager.changeRouteGroup(
          routeStateManager.currRouteGroup, setCurrentStateBasedOnRouteStatus);
      setState(() {
        isLoading = false;
      });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  void setCurrentStateBasedOnRouteStatus(RouteStateManagerLoadingStat status) {
    switch (status) {
      case RouteStateManagerLoadingStat.loading:
        setState(() {
          loadingStatus = "";
        });
        break;
      case RouteStateManagerLoadingStat.loadingMore:
        setState(() {
          loadingStatus = AppLocalizations.of(context)!.busRouteLoadingStatus;
        });
        break;
      case RouteStateManagerLoadingStat.done:
        setState(() {
          loadingStatus = null;
        });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initAppElementsWhileLoading() async {
    setState(() {
      isLoading = true;
    });
    initBusDirectionIcon();
    await routeStateManager.loadFavorites();
    setState(() {
      isLoading = false;
    });
  }

  MappedBusData get busData => routeStateManager.busData;
  List<Bus>? get buses => routeStateManager.buses;

  final _waitDuration = const Duration(seconds: 4);
  // This function assumes currRoute is not null
  Future<void> pollBus(BusRoute currRoute) async {
    logger.t('Polling bus ${currRoute.name}');
    await routeStateManager.retrieveBuses();
    logger.t('Got ${buses?.length} buses');
    setState(() {});
  }

  Future<void> startBusPolling({String withMessage = ''}) async {
    BusRoute? currRoute = routeStateManager.currBusRoute;

    setState(() {
      isLoading = true;
    });
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        calculateLatLngFromBusPoints(await routeStateManager.retrievePoints()),
        70));
    logger.t('Starting bus polling for route ${currRoute.name}');
    bool complete = true;

    Future<void> runPolling() async {
      if (complete) {
        complete = false;
        await pollBus(currRoute).whenComplete(() => complete = true);
      }
    }

    await runPolling();
    timer?.cancel();
    timer = Timer.periodic(_waitDuration, (Timer t) {
      runPolling();
    });
    setState(() {
      isLoading = false;
    });
  }

  void routeSelected(String routeKey) async {
    routeStateManager.changeRoute(routeKey);
    logger.t('Selected route $routeKey');
    panelController.close();
    await startBusPolling();
  }

  Widget _buildPanel(ScrollController sc) {
    final twoByTwoBusRouteWidgets = [];
    for (int i = 0; i < busData.routes.length; i += 2) {
      twoByTwoBusRouteWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BusRouteWidget(
              busData: busData,
              route: busData.routes[i],
              onRouteSelected: routeSelected),
          if (i + 1 < busData.routes.length) const SizedBox(width: 20),
          if (i + 1 < busData.routes.length)
            BusRouteWidget(
                busData: busData,
                route: busData.routes[i + 1],
                onRouteSelected: routeSelected),
        ],
      ));
      twoByTwoBusRouteWidgets.add(const SizedBox(height: 20));
    }

    getGroupNameFromIndex(int index) {
      if (index == RouteStateManager.favoritesIndex) {
        return AppLocalizations.of(context)!.favorites;
      } else {
        return [
          AppLocalizations.of(context)!.onCampus,
          AppLocalizations.of(context)!.offCampus,
          AppLocalizations.of(context)!.gameday
        ][index];
      }
    }

    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
            padding: const EdgeInsets.all(20),
            controller: sc,
            children: [
              Row(
                key: const Key("busRouteSelectionMenu"),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.busRouteSelectionMenuTitle,
                      style: Theme.of(context).textTheme.displaySmall),
                  DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      items: routeStateManager.groupIndices
                          .map((group) => DropdownMenuItem(
                              key: Key(getGroupNameFromIndex(group)),
                              value: group,
                              child: Text(getGroupNameFromIndex(group))))
                          .toList(),
                      value: routeStateManager.currRouteGroup,
                      onChanged: (value) {
                        setState(() {
                          timer?.cancel();
                        });
                        routeStateManager.changeRouteGroup(
                            value, setCurrentStateBasedOnRouteStatus);
                      })
                ],
              ),
              const SizedBox(height: 20),
              ...twoByTwoBusRouteWidgets,
              Text(loadingStatus ?? "",
                  style: Theme.of(context).textTheme.bodyMedium),
            ]));
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController panelController = PanelController();
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;

  //TODO: Add button to slide up bottom panel programmatically
  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    // if (buses?.isEmpty ?? false) {
    //   buses =
    //       _generateTestBusInDebug() != null ? [_generateTestBusInDebug()!] : [];
    // }
    return Stack(children: [
      Scaffold(
        key: scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     scaffoldKey.currentState?.openDrawer();
        //   },
        //   child: const Icon(Icons.menu),
        // ),
        drawer: Drawer(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text(
                    AppLocalizations.of(context)!.homePageTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('shezhi'),
                  enabled: true,
                  onTap: () {},
                )
              ],
            )),
        body: Stack(children: [
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            backdropEnabled: true,
            panelBuilder: (sc) => _buildPanel(sc),
            controller: panelController,
            body: AppleMaps(routeStateManager.points,
                buses: buses ?? [], routeColor: routeStateManager.routeColor,
                onMapCreated: (AppleMapController controller) {
              mapController = controller;
            }),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          routeStateManager.routeSelected
              ? Positioned(
                  right: 20.0,
                  bottom: _fabHeight,
                  child: Row(children: [
                    FloatingActionButton(
                      heroTag: 'timetable',
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          timer?.cancel();
                        });
                        Navigator.of(context)
                            .push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) {
                            return TimeTable(
                                routeShortName:
                                    routeStateManager.currBusRoute.shortName);
                          },
                        ))
                            .then((value) {
                          setState(() {
                            rebuildConnectionAndStartPolling();
                          });
                        });
                      },
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'favorite',
                      onPressed: () {
                        setState(() {
                          if (routeStateManager.isCurrentRouteFavorite()) {
                            routeStateManager
                                .unFavorite(setCurrentStateBasedOnRouteStatus);
                          } else {
                            routeStateManager.favorite();
                          }
                        });
                      },
                      backgroundColor: Colors.white,
                      child: Icon(
                        routeStateManager.isCurrentRouteFavorite()
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ]),
                )
              : Container(),
        ]),
      ),
      if (busData.routes.isEmpty || isLoading == true || loadingStatus == "")
        ModalBarrier(dismissible: false, color: Colors.black.withAlpha(100)),
      if (busData.routes.isEmpty || isLoading == true || loadingStatus == "")
        const Center(
          child: CircularProgressIndicator(),
        ),
    ]);
  }
}

class BusRouteWidget extends StatelessWidget {
  const BusRouteWidget({
    super.key,
    required this.busData,
    required this.route,
    required this.onRouteSelected,
  });

  final MappedBusData busData;
  final BusRoute route;
  final Function(String p1) onRouteSelected;

  @override
  Widget build(BuildContext context) {
    Color routeColor = busData.getRouteColor(route.key);
    Color textColor =
        routeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Expanded(
        child: ElevatedButton(
            onPressed: () => onRouteSelected(route.key),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              backgroundColor: routeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Column(
              children: [
                Text(route.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor)),
                Text(
                  route.shortName,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )));
  }
}

Bus? _generateTestBusInDebug() {
  if (kDebugMode) {
    return Bus(
      key: "1",
      location: BusLocation(
          latitude: 30.6187,
          longitude: -96.3365,
          heading: 2 * 3.14,
          speed: 0,
          lastGpsDate: DateTime.now()),
      name: "bus 1",
      vehicleType: "bus",
      passengerCapacity: 1,
      passengerLoad: 2,
      routeKey: '1',
      patternKey: 'f',
      patternColor: "0000000",
      patternName: "pattern 1",
      tripKey: "1",
      attributes: [],
      amenities: [],
      routeName: '',
      routeShortName: '',
      patternDestination: '',
      directionName: '',
      isTripper: false,
      workItemKey: '',
      routeStatus: BusRouteStatus(color: "", status: 'm'),
      opStatus: BusOpStatus(status: 'status', color: 'color'),
      nextStopDeparture: BusStopDeparture(
          stopKey: 'stopKey',
          stopCode: 'stopCode',
          tripPointKey: 'tripPointKey',
          patternPointKey: 'patternPointKey',
          scheduledDeparture: DateTime.now(),
          estimatedDeparture: DateTime.now(),
          hasDeparted: false,
          stopName: 'stopName'),
    );
  }
  return null;
}
