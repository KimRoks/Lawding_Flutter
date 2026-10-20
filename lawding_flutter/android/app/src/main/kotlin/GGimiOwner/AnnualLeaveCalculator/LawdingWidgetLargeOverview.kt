package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetLargeOverview : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetLargeOverview::class.java))
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

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val d = HomeWidgetPlugin.getData(context)

        val days = d.getString("widgetDays", null)
        val totalDays = d.getString("widgetLargeTotalDays", null)
        val usageRate = d.getString("widgetLargeUsageRate", null)
        val progressPct = d.getInt("widgetLargeProgressPct", 0)
        val period = d.getString("widgetLargePeriod", null)
        val expiry = d.getString("widgetLargeExpiry", null)
        val nextDateIso = UpcomingLeaves.load(d).firstOrNull()?.startIso

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_large)

        views.setTextViewText(R.id.widget_large_days, if (days != null) "${days}일" else "--일")
        views.setTextViewText(R.id.widget_large_total_days, if (totalDays != null) "${totalDays}일" else "--일")
        views.setTextViewText(R.id.widget_large_usage_rate, usageRate ?: "--")
        views.setProgressBar(R.id.widget_large_progress, 100, progressPct.coerceIn(0, 100), false)
        views.setTextViewText(R.id.widget_large_period, "사용 기간 : ${period ?: "--"}")
        views.setTextViewText(R.id.widget_large_expiry, "다음 소멸 : ${expiry ?: "--"}")
        views.setTextViewText(R.id.widget_large_next_date, "다음 연차 : ${nextDateIso ?: "--"}")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
