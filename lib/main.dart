import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
              useMaterial3: true,
            ),
            home: const MyHomePage(title: 'HomePage')));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
        switchInCurve: Curves.easeInCirc,
        switchOutCurve: Curves.easeOutCirc,
        // transitionBuilder: (child,animation) => SlideTransition(position: animation.drive(Tween(begin: begin, end: end)),
        // child:child)

      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          // Use a more mobile-friendly layout with BottomNavigationBar
          // on narrow screens.
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                child: BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favorites',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              )
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                  child: NavigationRail(
                      destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.home), label: Text("Home")),
                    NavigationRailDestination(
                        icon: Icon(Icons.favorite), label: Text("Favorites"))
                  ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                      extended: constraints.maxWidth >= 600)),
              Expanded(child: mainArea),
            ],
          );
        }
      }),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavourites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var pair = appState.current.asCamelCase;
    IconData icon;
    if (appState.favorites.contains(appState.current)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          const Text(
            'Click Button to Generate a random Word',
          ),
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                pair,
                style: style,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourites();
                },
                icon: Icon(icon),
                label: const Text("Like"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: const Text("Next")),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pari in appState.favorites)
          ListTile(
            title: Text(pari.asCamelCase),
            leading: const Icon(Icons.favorite),
          )
      ],
    );
  }
}
