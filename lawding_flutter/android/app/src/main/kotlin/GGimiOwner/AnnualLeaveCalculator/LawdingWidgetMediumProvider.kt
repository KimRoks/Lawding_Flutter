package com.lawding.annualleavecalculator

import GGimiOwner.AnnualLeaveCalculator.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LawdingWidgetMediumProvider : AppWidgetProvider() {

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
        val afterNextDate = widgetData.getString("widgetMediumAfterNextDate", null)
        val afterNextType = widgetData.getString("widgetMediumAfterNextType", null)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_medium)

        views.setTextViewText(R.id.widget_medium_next_date, nextDate ?: "--")
        views.setTextViewText(R.id.widget_medium_next_type, nextType ?: "--")
        val afterText = if (afterNextDate != null) "다음 일정 $afterNextDate ${afterNextType ?: ""}".trim() else "다음 예정된 연차 없음"
        views.setTextViewText(R.id.widget_medium_after_next, afterText)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
