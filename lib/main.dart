import 'package:bus_hunter/api/bus_api.dart';
import 'package:bus_hunter/api/bus_obj.dart';
import 'package:bus_hunter/map/apple_maps.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

class _MyHomePageState extends State<MyHomePage> {
  List<BusRoute>? routes;
  BusRoute? currRoute;
  List<BusPoint>? currRoutePoints;

  void initRoutes() async {
    routes = await getRoutes();
    setState(() {
      logger.i('Attained routes, array size ${routes?.length}');
    });
  }

  void onRouteSelected(BusRoute route) async {
    currRoute = route;
    logger.i('Selected route ${route.name}');
    List<BusRoutePattern> patterns = await getRoutePatterns(route.key);
    currRoutePoints = [];
    for (BusRoutePattern pattern in patterns) {
      List<BusPoint> points = await getPatternPoints(pattern.key);
      currRoutePoints?.addAll(points);
    }

    setState(() {
      logger.i('Attained route points, array size ${currRoutePoints?.length}');
    });
  }

  _MyHomePageState() {
    initRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.homePageTitle),
      ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        panel: GridView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          children: (routes ?? [])
              .map<Widget>((BusRoute element) => ElevatedButton(
                    onPressed: () => onRouteSelected(element),
                    child: Text(element.name),
                  ))
              .toList(),
        ),
        body: AppleMaps(currRoutePoints ?? []),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
