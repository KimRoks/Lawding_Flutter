package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.TimeUnit

class LawdingWidgetMediumPlus : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetMediumPlus::class.java))
            onUpdate(context, manager, ids)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun computeDDay(isoDate: String?): String? {
        if (isoDate == null) return null
        return try {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            sdf.isLenient = false
            val eventDate = sdf.parse(isoDate.take(10)) ?: return null
            val today = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
            }
            val event = Calendar.getInstance().apply {
                time = eventDate
                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
            }
            val diff = TimeUnit.MILLISECONDS.toDays(event.timeInMillis - today.timeInMillis)
            if (diff == 0L) "D-Day" else "D-$diff"
        } catch (e: Exception) {
            null
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val nextDate = widgetData.getString("widgetMediumNextDate", null)
        val nextType = widgetData.getString("widgetMediumNextType", null)
        val nextDDay = computeDDay(widgetData.getString("widgetNextDateIso", null))
            ?: widgetData.getString("widgetCalNextDDay", null)
        val afterDate = widgetData.getString("widgetMediumAfterNextDate", null)
        val afterType = widgetData.getString("widgetMediumAfterNextType", null)
        val afterDDay = computeDDay(widgetData.getString("widgetAfterNextDateIso", null))
            ?: widgetData.getString("widgetCalAfterDDay", null)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_calendar)

        views.setTextViewText(R.id.widget_cal_left_date, nextDate ?: "--")
        views.setTextViewText(R.id.widget_cal_left_type, nextType ?: "--")
        views.setTextViewText(R.id.widget_cal_left_dday, nextDDay ?: "--")

        views.setTextViewText(R.id.widget_cal_right_date, afterDate ?: "--")
        views.setTextViewText(R.id.widget_cal_right_type, afterType ?: "--")
        views.setTextViewText(R.id.widget_cal_right_dday, afterDDay ?: "--")

        val addIntent = Intent(Intent.ACTION_VIEW,
            Uri.parse("ggimiowner.annualleavecalculator://add-calendar")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, addIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_add_calendar, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
