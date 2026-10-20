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

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val leaves = UpcomingLeaves.load(HomeWidgetPlugin.getData(context))
        val next = leaves.getOrNull(0)
        val afterNext = leaves.getOrNull(1)

        val views = RemoteViews(context.packageName, R.layout.lawding_widget_calendar)

        views.setTextViewText(R.id.widget_cal_left_date, next?.date ?: "--")
        views.setTextViewText(R.id.widget_cal_left_type, next?.type ?: "--")
        views.setTextViewText(R.id.widget_cal_left_dday, next?.dDay() ?: "--")

        views.setTextViewText(R.id.widget_cal_right_date, afterNext?.date ?: "--")
        views.setTextViewText(R.id.widget_cal_right_type, afterNext?.type ?: "--")
        views.setTextViewText(R.id.widget_cal_right_dday, afterNext?.dDay() ?: "--")

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
