package com.example.home_widget_counter_demo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CounterWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.counter_widget).apply {

                val count = widgetData.getString("counter_value", "0") ?: "0"
                setTextViewText(R.id.counter_text, count)

                val isDark = widgetData.getBoolean("is_dark_mode", false)
                val bgColor = if (isDark) 0xFF1C1C1E.toInt() else 0xFFFFFFFF.toInt()
                val textColor = if (isDark) 0xFFFFFFFF.toInt() else 0xFF000000.toInt()
                setInt(R.id.widget_root, "setBackgroundColor", bgColor)
                setTextColor(R.id.counter_text, textColor)
                setTextColor(R.id.label_text, textColor)

                setOnClickPendingIntent(
                    R.id.decrement_button,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context, Uri.parse("counterdemo://decrement")
                    )
                )
                setOnClickPendingIntent(
                    R.id.increment_button,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context, Uri.parse("counterdemo://increment")
                    )
                )
                setOnClickPendingIntent(
                    R.id.theme_toggle_button,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context, Uri.parse("counterdemo://toggletheme")
                    )
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}