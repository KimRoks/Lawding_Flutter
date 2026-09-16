package com.lawding.annualleavecalculator

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import GGimiOwner.AnnualLeaveCalculator.R
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetProvider : AppWidgetProvider() {

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
        val widgetData = HomeWidgetPlugin.getData(context)
        val days = widgetData.getString("widgetDays", null)
        val totalHours = widgetData.getInt("widgetTotalHours", -1)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget)
        if (days == null) {
            views.setTextViewText(R.id.widget_days, "8.125일")
            views.setTextViewText(R.id.widget_hours, "65시간")
        } else {
            views.setTextViewText(R.id.widget_days, "${days}일")
            views.setTextViewText(R.id.widget_hours, "${totalHours}시간")
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
