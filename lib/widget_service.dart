import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Keys shared between Flutter and the native widget code.
/// Keep these identical on both sides — one typo here and the widget
/// silently shows stale or default data, with no error anywhere.
class WidgetKeys {
  static const counter = 'counter_value';
  static const isDark = 'is_dark_mode';
  static const lastUpdated = 'last_updated';
}

/// Native widget identifiers. These must match:
/// - Android: the <receiver android:name="..."> in AndroidManifest.xml
/// - iOS: the `kind` string in the WidgetKit StaticConfiguration
class WidgetNames {
  static const android = 'CounterWidgetProvider';
  static const ios = 'CounterWidgetExtension';
}

class HomeWidgetService {
  static Future<void> init() async {
    await HomeWidget.setAppGroupId('group.com.example.homewidgetcounterdemo');
  }

  static Future<void> saveCounter(int value) async {
    await HomeWidget.saveWidgetData<String>(WidgetKeys.counter, '$value');
    await HomeWidget.saveWidgetData<String>(
      WidgetKeys.lastUpdated,
      DateTime.now().toIso8601String(),
    );
    await _refresh();
  }

  static Future<void> saveTheme(bool isDark) async {
    await HomeWidget.saveWidgetData<bool>(WidgetKeys.isDark, isDark);
    await _refresh();
  }

  static Future<int> loadCounter() async {
    final stored = await HomeWidget.getWidgetData<String>(
      WidgetKeys.counter,
      defaultValue: '0',
    );
    return int.tryParse(stored ?? '0') ?? 0;
  }

  // NEW — needed so both the app and the background callback can read
  // back the current theme flag.
  static Future<bool> loadIsDark() async {
    return await HomeWidget.getWidgetData<bool>(
          WidgetKeys.isDark,
          defaultValue: false,
        ) ??
        false;
  }

  static Future<void> _refresh() async {
    try {
      await HomeWidget.updateWidget(
        androidName: WidgetNames.android,
        iOSName: WidgetNames.ios,
      );
    } catch (e) {
      debugPrint('Widget refresh failed: $e');
    }
  }
}