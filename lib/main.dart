import 'dart:async';
import 'dart:collection';
import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';
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

class MappedBusData {
  HashMap<BusRoute, BusRouteData> data;
  MappedBusData() : data = HashMap();

  void _addEntry(
      BusRoute route, List<BusRoutePattern> patterns, List<BusPoint> points) {
    data.addEntries([MapEntry(route, (patterns, points))]);
  }

  // Will throw an error if pattern is empty for this route. In addition it will not add the route
  Future<void> addRouteAndRetrieveData(BusRoute route) async {
    List<BusRoutePattern> patterns = await getRoutePatterns(route.key);
    List<BusPoint> points = [];
    if (patterns.isEmpty) {
      throw Exception('Empty patterns for route ${route.name}');
    }
    _addEntry(route, patterns, []);
    logger.t('Added route ${route.name} with ${patterns.length} patterns and '
        '${points.length} points');
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

  Future<List<BusPoint>?> points(String key) async {
    if (data[route(key)]?.$2.isEmpty ?? false) {
      List<Future<void>> futures = [];
      for (BusRoutePattern pattern in patterns(key) ?? []) {
        futures.add(getPatternPoints(pattern.key).then((p) {
          if (p.isEmpty) {
            logger.e('Empty points for pattern ${pattern.name}');
          }
          logger.t('Adding ${p.length} points for pattern ${pattern.name}');
          data[route(key)]?.$2.addAll(p);
        }));
      }
      await Future.wait(futures);
    }
    return data[route(key)]?.$2;
  }
  // Future<void> retrievePoints(String key) async {
  //   if (data[route(key)]?.$2.isEmpty ?? false) {
  //     List<Future<void>> futures = [];
  //     for (BusRoutePattern pattern in patterns(key) ?? []) {
  //       futures.add(getPatternPoints(pattern.key).then((p) {
  //         if (p.isEmpty) {
  //           logger.e('Empty points for pattern ${pattern.name}');
  //         }
  //         logger.t('Adding ${p.length} points for pattern ${pattern.name}');
  //         data[route(key)]?.$2.addAll(p);
  //       }));
  //     }
  //     await Future.wait(futures);
  //   }
  // }

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String? currRouteKey;
  String? loadingStatus;
  bool? isLoading = false;

  Map<int, MappedBusData> routeData = {
    RouteGroups.onCampus.index: MappedBusData(),
    RouteGroups.offCampus.index: MappedBusData(),
    RouteGroups.gameday.index: MappedBusData(),
  };
  final MappedBusData _favorites = MappedBusData();
  int currRouteGroup = 0;

  List<Bus>? buses = [];
  Timer? timer;

  AppleMapController? mapController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        logger.i('App resumed');
        if (currRouteKey != null) {
          startBusPolling(withMessage: 'from resume');
        }
      });
    }
  }

  @override
  initState() {
    super.initState();
    _fabHeight = _initFabHeight;
    initAppElementsWhileLoading().then((value) async {
      await startServerConnection();
      initRoutes();
    });
    WidgetsBinding.instance.addObserver(this);
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
    prefs = await SharedPreferences.getInstance();
    final List<BusRoute> favorites = (prefs.getStringList('favorites') ?? [])
        .map((e) => BusRoute.fromJson(jsonDecode(e)))
        .toList();
    if (favorites.isNotEmpty) {
      currRouteGroup = -1;
      _favorites.data.addEntries(favorites.map((e) => MapEntry(e, ([], []))));
    }
    setState(() {
      isLoading = false;
    });
  }

  void saveFavorites() {
    prefs.setStringList(
        'favorites', _favorites.routes.map((e) => jsonEncode(e)).toList());
  }

  MappedBusData get busData {
    if (currRouteGroup < 0) {
      return _favorites;
    }
    return routeData[currRouteGroup]!;
  }

  void initRoutes() async {
    if (busData.routes.isNotEmpty) {
      return;
    }
    List<Future<void>> futures = [];
    if (currRouteGroup < 0) {
      logger.t('Entering favorites mode');
      for (BusRoute route in _favorites.routes) {
        futures.add(busData
            .addRouteAndRetrieveData(route)
            .then((value) => setState(() {
                  loadingStatus =
                      AppLocalizations.of(context)!.busRouteLoadingStatus;
                }))
            .onError((error, stackTrace) {
          logger.e(
              'Error adding route ${route.name}, failed with "$error", removing favorite');
          _favorites.routes.remove(route);
          saveFavorites();
        }));
      }
    } else {
      await getRouteByGroup(RouteGroups.values[currRouteGroup])
          .then((routes) async {
        for (BusRoute route in routes) {
          futures.add(busData
              .addRouteAndRetrieveData(route)
              .then((value) => setState(() {
                    loadingStatus =
                        AppLocalizations.of(context)!.busRouteLoadingStatus;
                  }))
              .onError((error, stackTrace) {
            logger.e('Error adding route ${route.name}, failed with "$error"');
            // TODO: If route group is favorite, remove it from favorite
          }));
        }
      });

      await Future.wait(futures);
      logger.t('Finished loading routes');
      setState(() {
        loadingStatus = null;
      });
    }
  }

  final _waitDuration = const Duration(seconds: 3);
  // This function assumes currRoute is not null
  Future<void> pollBus(BusRoute currRoute) async {
    logger.d('Polling bus ${currRoute.name}');
    buses = await getBuses(currRoute.shortName);
    logger.d('Got ${buses?.length} buses');
    setState(() {});
  }

  // This function assumes currRoute is not null
  Future<void> startBusPolling({String withMessage = ''}) async {
    BusRoute? currRoute = busData.route(currRouteKey!);

    if (currRoute == null) {
      logger.e('currRoute is null!');
      return;
    }

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        calculateLatLngFromBusPoints(await busData.points(currRoute.key) ?? []),
        70));
    logger.t('Starting bus polling for route ${currRoute.name}');
    bool complete = true;
    await pollBus(currRoute);
    timer?.cancel();
    timer = Timer.periodic(_waitDuration, (Timer t) {
      if (complete) {
        complete = false;
        pollBus(currRoute).whenComplete(() => complete = true);
      }
    });
  }

  void onRouteSelected(String routeKey) async {
    currRouteKey = routeKey;
    logger.t('Selected route $routeKey');
    setState(() {
      isLoading = true;
    });
    await startBusPolling();
    setState(() {
      logger.t('Attained route points and start polling bus location.');
      isLoading = false;
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

    final List<int> items = [];
    if (_favorites.routes.isNotEmpty) {
      items.add(0);
    }
    for (var element in RouteGroups.values) {
      items.add(element.index);
    }

    getGroupNameFromIndex(int index) {
      if (index < 0) {
        return 'Favorites';
      } else {
        return RouteGroups.values[index].name;
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
                      items: items
                          .map((group) => DropdownMenuItem(
                              key: Key(getGroupNameFromIndex(group)),
                              value: group,
                              child: Text(getGroupNameFromIndex(group))))
                          .toList(),
                      value: currRouteGroup,
                      onChanged: (value) => setState(() {
                            currRouteGroup = value as int;
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
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;

  //TODO: Add button to slide up bottom panel programmatically
  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
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
        body: Stack(children: [
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            backdropEnabled: true,
            panelBuilder: (sc) => _buildPanel(sc),
            body: AppleMaps(
                busData.forceGetPoints(currRouteKey ?? "") ?? [], buses ?? [],
                routeColor: busData.getRouteColor(currRouteKey ?? ""),
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
          Positioned(
            right: 20.0,
            bottom: _fabHeight,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: Icon(
                Icons.star_border_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ]),
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
