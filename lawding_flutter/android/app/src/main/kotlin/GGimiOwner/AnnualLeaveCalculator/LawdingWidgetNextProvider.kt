package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetNextProvider : AppWidgetProvider() {

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
        val nextDate = widgetData.getString("widgetMediumNextDate", null)
        val nextType = widgetData.getString("widgetMediumNextType", null)
        val nextDDay = widgetData.getString("widgetCalNextDDay", null)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_next)
        views.setTextViewText(R.id.widget_next_date, nextDate ?: "--")
        views.setTextViewText(R.id.widget_next_type, nextType ?: "--")
        views.setTextViewText(R.id.widget_next_dday, nextDDay ?: "--")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
