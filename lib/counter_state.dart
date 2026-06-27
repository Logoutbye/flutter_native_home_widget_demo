import 'package:flutter/foundation.dart';
import 'widget_service.dart';

class CounterState extends ChangeNotifier {
  int _count = 0;
  bool _isDark = false;

  int get count => _count;
  bool get isDark => _isDark;

  Future<void> loadInitial() async {
    _count = await HomeWidgetService.loadCounter();
    _isDark = await HomeWidgetService.loadIsDark();
    notifyListeners();
  }

  Future<void> increment() async {
    _count++;
    notifyListeners();
    await HomeWidgetService.saveCounter(_count);
  }

  Future<void> decrement() async {
    if (_count == 0) return;
    _count--;
    notifyListeners();
    await HomeWidgetService.saveCounter(_count);
  }

  Future<void> syncFromWidget() async {
    final widgetCount = await HomeWidgetService.loadCounter();
    final widgetIsDark = await HomeWidgetService.loadIsDark();
    var changed = false;
    if (widgetCount != _count) {
      _count = widgetCount;
      changed = true;
    }
    if (widgetIsDark != _isDark) {
      _isDark = widgetIsDark;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    await HomeWidgetService.saveTheme(_isDark);
  }
}
