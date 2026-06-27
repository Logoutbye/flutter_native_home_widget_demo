import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'counter_state.dart';
import 'widget_service.dart';

/// Runs in a background isolate when the user taps a button on the widget
/// while the app isn't in the foreground. Must stay top-level (or static)
/// and tagged with @pragma('vm:entry-point'), or release builds will
/// tree-shake it away and your widget buttons will silently do nothing.
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;
  switch (uri.host) {
    case 'increment':
      final current = await HomeWidgetService.loadCounter();
      await HomeWidgetService.saveCounter(current + 1);
      break;
    case 'decrement':
      final current = await HomeWidgetService.loadCounter();
      await HomeWidgetService.saveCounter(current > 0 ? current - 1 : 0);
      break;
    case 'toggletheme':
      final isDark = await HomeWidgetService.loadIsDark();
      await HomeWidgetService.saveTheme(!isDark);
      break;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidgetService.init();
  await HomeWidget.registerInteractivityCallback(backgroundCallback);
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Widget Counter Demo',
      home: CounterHomePage(),
    );
  }
}

class CounterHomePage extends StatefulWidget {
  const CounterHomePage({super.key});

  @override
  State<CounterHomePage> createState() => _CounterHomePageState();
}

class _CounterHomePageState extends State<CounterHomePage>
    with WidgetsBindingObserver {
  final CounterState _state = CounterState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _state.addListener(() => setState(() {}));
    _state.loadInitial();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    // The widget can change the counter while the app is closed.
    // Pull the latest value the moment the app comes back to front.
    if (appState == AppLifecycleState.resumed) {
      _state.syncFromWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _state.isDark;
    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Widget Counter'),
          actions: [
            IconButton(
              tooltip: 'Toggle theme (syncs to widget too)',
              icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: _state.toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_state.count}', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Add this widget to your home screen, then tap +/- '
                  'there too — it stays in sync both ways.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: 'dec',
              onPressed: _state.decrement,
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 24),
            FloatingActionButton(
              heroTag: 'inc',
              onPressed: _state.increment,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
