package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.TimeUnit

class LawdingWidgetLargeProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetLargeProvider::class.java))
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
        val days = widgetData.getString("widgetDays", null)
        val totalHours = widgetData.getInt("widgetTotalHours", -1)

        val date1 = widgetData.getString("widgetMediumNextDate", null)
        val type1 = widgetData.getString("widgetMediumNextType", null)
        val dday1 = computeDDay(widgetData.getString("widgetNextDateIso", null))
            ?: widgetData.getString("widgetCalNextDDay", null)

        val date2 = widgetData.getString("widgetMediumAfterNextDate", null)
        val type2 = widgetData.getString("widgetMediumAfterNextType", null)
        val dday2 = computeDDay(widgetData.getString("widgetAfterNextDateIso", null))
            ?: widgetData.getString("widgetCalAfterDDay", null)

        val date3 = widgetData.getString("widgetThirdDate", null)
        val type3 = widgetData.getString("widgetThirdType", null)
        val dday3 = computeDDay(widgetData.getString("widgetThirdDateIso", null))

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_large)

        views.setTextViewText(R.id.widget_large_days, if (days != null) "${days}일" else "--일")
        views.setTextViewText(R.id.widget_large_hours, if (totalHours >= 0) "${totalHours}시간" else "--시간")

        views.setTextViewText(R.id.widget_large_date1, date1 ?: "--")
        views.setTextViewText(R.id.widget_large_type1, type1 ?: "--")
        views.setTextViewText(R.id.widget_large_dday1, dday1 ?: "--")

        val show2 = date2 != null
        views.setViewVisibility(R.id.widget_large_divider2, if (show2) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_large_row2, if (show2) View.VISIBLE else View.GONE)
        if (show2) {
            views.setTextViewText(R.id.widget_large_date2, date2 ?: "--")
            views.setTextViewText(R.id.widget_large_type2, type2 ?: "--")
            views.setTextViewText(R.id.widget_large_dday2, dday2 ?: "--")
        }

        val show3 = date3 != null
        views.setViewVisibility(R.id.widget_large_divider3, if (show3) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_large_row3, if (show3) View.VISIBLE else View.GONE)
        if (show3) {
            views.setTextViewText(R.id.widget_large_date3, date3 ?: "--")
            views.setTextViewText(R.id.widget_large_type3, type3 ?: "--")
            views.setTextViewText(R.id.widget_large_dday3, dday3 ?: "--")
        }

        val addIntent = Intent(Intent.ACTION_VIEW,
            Uri.parse("ggimiowner.annualleavecalculator://add-calendar")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, addIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_add_large, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
