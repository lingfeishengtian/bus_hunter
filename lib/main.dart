import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/map/apple_maps.dart';
import 'package:bus_hunter/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  Logger.level = Level.debug;
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

class MappedBusData {
  HashMap<BusRoute, BusRouteData> data;

  MappedBusData() : data = HashMap();

  void _addEntry(
      BusRoute route, List<BusRoutePattern> patterns, List<BusPoint> points) {
    data.addEntries([MapEntry(route, (patterns, points))]);
  }

  Future<void> addRouteAndRetrieveData(BusRoute route) async {
    List<BusRoutePattern> patterns = await getRoutePatterns(route.key);
    List<BusPoint> points = [];
    _addEntry(route, patterns, []);
    logger.i('Added route ${route.name} with ${patterns.length} patterns and '
        '${points.length} points');
    return;
  }

  int numOfRoutes() {
    return data.length;
  }

  BusRoute? route(String key) {
    return data.keys.firstWhereOrNull((element) => element.key == key);
  }

  List<BusRoutePattern>? patterns(String key) {
    return data[route(key)]?.$1;
  }

  // Future<List<BusPoint>?> points(String key) async {
  //   if (data[route(key)]?.$2.isEmpty ?? false) {
  //     for (BusRoutePattern pattern in patterns(key) ?? []) {
  //       final p = await getPatternPoints(pattern.key);
  //       print('Adding ${p.length} points for pattern ${pattern.name}');
  //       data[route(key)]?.$2.addAll(p);
  //     }
  //   }
  //   return data[route(key)]?.$2;
  // }
  Future<void> retrievePoints(String key) async {
    a++;
    if (data[route(key)]?.$2.isEmpty ?? false) {
      for (BusRoutePattern pattern in patterns(key) ?? []) {
        final p = await getPatternPoints(pattern.key);
        logger.i('Adding ${p.length} points for pattern ${pattern.name}');
        data[route(key)]?.$2.addAll(p);
      }
    }
  }

  List<BusPoint>? forceGetPoints(String key) {
    return data[route(key)]?.$2;
  }

  List<BusRoute> get routes {
    return data.keys.toList().sortedBy((element) => element.shortName);
  }

  Color getRouteColor(String key) {
    return hexToColor(patterns(key)?.first.lineDisplayInfo.color ?? "#000000");
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // MappedBusData busData = MappedBusData();
  String? currRouteKey;
  String? loadingStatus;
  bool? isLoading = false;

  Map<RouteGroups, MappedBusData> routeData = {
    RouteGroups.onCampus: MappedBusData(),
    RouteGroups.offCampus: MappedBusData(),
    RouteGroups.gameday: MappedBusData(),
  };
  RouteGroups currRouteGroup = RouteGroups.values.first;

  List<Bus>? buses = [];
  Timer? timer;

  AppleMapController? mapController;

  @override
  initState() {
    super.initState();
    startServerConnection().then((value) => initRoutes());
    // startServerConnection();
    initRoutes();
    initIcon();
  }

  Future<void> initIcon() async {
    setState(() {
      isLoading = true;
    });
    await initBusDirectionIcon();
    setState(() {
      isLoading = false;
    });
  }

  MappedBusData get busData {
    return routeData[currRouteGroup]!;
  }

  void initRoutes() async {
    if (busData.routes.isNotEmpty || loadingStatus != null) {
      return;
    }
    List<Future<void>> futures = [];
    futures.add(getRouteByGroup(currRouteGroup).then((routes) async {
      List<Future<void>> innerFutures = [];
      for (BusRoute route in routes) {
        innerFutures.add(
            busData.addRouteAndRetrieveData(route).then((value) => setState(() {
                  loadingStatus =
                      AppLocalizations.of(context)!.busRouteLoadingStatus;
                })));
      }
      await Future.wait(innerFutures);
    }));
    //delay a second
    //   await Future.delayed(const Duration(seconds: 1), () {});
    // }

    await Future.wait(futures);
    logger.d('Finished loading routes');
    setState(() {
      loadingStatus = null;
    });
  }

  // This function assumes currRoute is not null
  void pollBus(BusRoute currRoute) {
    logger.i('Polling bus ${currRoute.name}');
    getBuses(currRoute.shortName).then((List<Bus> value) {
      logger.i('Attained buses, array size ${value.length}');
      setState(() {
        buses = value;
      });
    });
  }

  // This function assumes currRoute is not null
  void startBusPolling() {
    BusRoute? currRoute = busData.route(currRouteKey!);

    if (currRoute == null) {
      logger.e('currRoute is null!');
      return;
    }

    if (timer != null) {
      timer!.cancel();
    }

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        calculateLatLngFromBusPoints(
            busData.forceGetPoints(currRoute.key) ?? []),
        70));
    logger.i('Starting bus polling for route ${currRoute.name}');
    pollBus(currRoute);
    timer = Timer.periodic(
        const Duration(seconds: 6), (Timer t) => pollBus(currRoute));
  }

  void onRouteSelected(String routeKey) async {
    currRouteKey = routeKey;
    logger.i('Selected route $routeKey');
    setState(() {
      isLoading = true;
    });
    await busData.retrievePoints(routeKey);
    setState(() {
      isLoading = false;
    });
    startBusPolling();
    setState(() {
      logger.i('Attained route points and start polling bus location.');
    });
  }

  Widget _generateBusRouteWidget(BusRoute route) {
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

  Widget _buildPanel(ScrollController sc) {
    final twoByTwoBusRouteWidgets = [];
    for (int i = 0; i < busData.routes.length; i += 2) {
      twoByTwoBusRouteWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _generateBusRouteWidget(busData.routes[i]),
          if (i + 1 < busData.routes.length) const SizedBox(width: 20),
          if (i + 1 < busData.routes.length)
            _generateBusRouteWidget(busData.routes[i + 1]),
        ],
      ));
      twoByTwoBusRouteWidgets.add(const SizedBox(height: 20));
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
                      items: RouteGroups.values
                          .map((group) => DropdownMenuItem(
                              key: Key(group.key),
                              value: group,
                              child: Text(group.name)))
                          .toList(),
                      value: currRouteGroup,
                      onChanged: (value) => setState(() {
                            currRouteGroup = value as RouteGroups;
                            initRoutes();
                          })),
                ],
              ),
              const SizedBox(height: 20),
              ...twoByTwoBusRouteWidgets,
              Text(loadingStatus ?? "",
                  style: Theme.of(context).textTheme.bodyMedium),
            ]));
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  //TODO: Add button to slide up bottom panel programmatically
  @override
  Widget build(BuildContext context) {
    if (buses?.isEmpty ?? false) {
      buses =
          _generateTestBusInDebug() != null ? [_generateTestBusInDebug()!] : [];
    }
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
        body: SlidingUpPanel(
          backdropEnabled: true,
          panelBuilder: (sc) => _buildPanel(sc),
          body: AppleMaps(
              busData.forceGetPoints(currRouteKey ?? "") ?? [], buses ?? [],
              routeColor: busData.getRouteColor(currRouteKey ?? ""),
              onMapCreated: (AppleMapController controller) {
            mapController = controller;
          }),
        ),
      ),
      if (busData.numOfRoutes() == 0 || isLoading == true)
        ModalBarrier(dismissible: false, color: Colors.black.withAlpha(100)),
      if (busData.numOfRoutes() == 0 || isLoading == true)
        const Center(
          child: CircularProgressIndicator(),
        ),
    ]);
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
