package com.example.flutter_application_1

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ClockWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // 遍历所有 widget 实例进行更新
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        // 更新 widget 的内部方法
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // 从 HomeWidget 获取存储的数据
            val widgetData = HomeWidgetPlugin.getData(context)
            val time = widgetData.getString("widget_time", getCurrentTime())
            val date = widgetData.getString("widget_date", getCurrentDate())
            val title = widgetData.getString("widget_title", "时钟小组件")

            // 构建 RemoteViews
            val views = RemoteViews(context.packageName, R.layout.clock_widget).apply {
                setTextViewText(R.id.widget_time, time)
                setTextViewText(R.id.widget_date, date)
                setTextViewText(R.id.widget_title, title)
            }

            // 更新 widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // 获取当前时间
        private fun getCurrentTime(): String {
            val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
            return sdf.format(Date())
        }

        // 获取当前日期
        private fun getCurrentDate(): String {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date())
        }
    }

    override fun onEnabled(context: Context) {
        // 首次创建 widget 时调用
    }

    override fun onDisabled(context: Context) {
        // 最后一个 widget 被删除时调用
    }
}
