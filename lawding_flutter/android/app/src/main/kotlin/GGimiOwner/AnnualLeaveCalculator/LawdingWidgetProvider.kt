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
        views.setTextViewText(R.id.widget_days, if (days != null) "${days}일" else "--일")
        views.setTextViewText(R.id.widget_hours, if (totalHours >= 0) "${totalHours}시간" else "--시간")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
