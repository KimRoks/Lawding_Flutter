package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetMediumSchedule : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetMediumSchedule::class.java))
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
        val leaves = UpcomingLeaves.load(HomeWidgetPlugin.getData(context))
        val next = leaves.getOrNull(0)
        val afterNext = leaves.getOrNull(1)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_medium)

        views.setTextViewText(R.id.widget_medium_next_date, next?.date ?: "--")
        views.setTextViewText(R.id.widget_medium_next_type, next?.type ?: "--")
        val afterText = if (afterNext != null) "다음 일정 ${afterNext.date} ${afterNext.type ?: ""}".trim() else "다음 예정된 연차 없음"
        views.setTextViewText(R.id.widget_medium_after_next, afterText)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
