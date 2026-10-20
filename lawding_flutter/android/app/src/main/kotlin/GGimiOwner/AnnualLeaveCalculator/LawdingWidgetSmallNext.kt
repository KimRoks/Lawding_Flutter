package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetSmallNext : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetSmallNext::class.java))
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
        val next = UpcomingLeaves.load(HomeWidgetPlugin.getData(context)).firstOrNull()

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_next)
        views.setTextViewText(R.id.widget_next_date, next?.date ?: "--")
        views.setTextViewText(R.id.widget_next_type, next?.type ?: "--")
        views.setTextViewText(R.id.widget_next_dday, next?.dDay() ?: "--")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
