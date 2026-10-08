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
import org.json.JSONObject
import java.util.Calendar

class LawdingWidgetLargeCalendar : AppWidgetProvider() {

    // 날짜는 yyyyMMdd 정수로 비교한다.
    private data class Item(
        val start: Int,
        val end: Int,
        val type: Int,
        val sortKey: Int,
        val title: String,
        val sub: String,
        val cellLabel: String,
        val badge: String?,
    )

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_DATE_CHANGED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LawdingWidgetLargeCalendar::class.java))
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
        val items = loadItems(context)
        val today = Calendar.getInstance()
        val year = today.get(Calendar.YEAR)
        val month = today.get(Calendar.MONTH)
        val todayKey = dayKey(today)

        val first = Calendar.getInstance().apply {
            clear()
            set(year, month, 1)
        }
        val offset = first.get(Calendar.DAY_OF_WEEK) - Calendar.SUNDAY
        val weeks = (offset + first.getActualMaximum(Calendar.DAY_OF_MONTH) + 6) / 7

        // 진행 중인 일정은 오늘 날짜로 취급해 정렬한다. 6주인 달은 공간이 부족해 1개만.
        val upcoming = items
            .filter { it.end >= todayKey }
            .sortedWith(compareBy({ maxOf(it.start, todayKey) }, { it.type }, { it.sortKey }))
            .take(if (weeks >= 6) 1 else 2)

        // 다가오는 일정이 없으면 리스트 없이 달력이 위젯을 채우는 전용 레이아웃을 쓴다.
        val calendarOnly = upcoming.isEmpty()
        val views = RemoteViews(
            context.packageName,
            if (calendarOnly) R.layout.lawding_widget_cal_large_full else R.layout.lawding_widget_cal_large
        )
        val cellLayout = if (calendarOnly) R.layout.lawding_widget_cal_cell_full else R.layout.lawding_widget_cal_cell
        views.setTextViewText(R.id.cal_title, "${year}년 ${month + 1}월")

        views.removeAllViews(R.id.cal_grid)
        val cursor = (first.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, -offset) }
        repeat(weeks) {
            val row = RemoteViews(context.packageName, R.layout.lawding_widget_cal_row)
            for (col in 0 until 7) {
                row.addView(R.id.cal_row, buildCell(context, cellLayout, cursor, col, month, todayKey, items))
                cursor.add(Calendar.DAY_OF_MONTH, 1)
            }
            views.addView(R.id.cal_grid, row)
        }

        if (!calendarOnly) {
            views.removeAllViews(R.id.cal_list)
            upcoming.forEachIndexed { i, item ->
                views.addView(R.id.cal_list, buildListItem(context, item, isLast = i == upcoming.lastIndex))
            }
        }

        val openCalendar = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("ggimiowner.annualleavecalculator://add-calendar")
        ).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, openCalendar,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.cal_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun buildCell(
        context: Context,
        layoutId: Int,
        date: Calendar,
        col: Int,
        month: Int,
        todayKey: Int,
        items: List<Item>
    ): RemoteViews {
        val cell = RemoteViews(context.packageName, layoutId)
        val day = date.get(Calendar.DAY_OF_MONTH).toString()

        // 앞뒤 달 날짜는 숫자만 표시 (디자인)
        if (date.get(Calendar.MONTH) != month) {
            cell.setTextViewText(R.id.cal_day, day)
            return cell
        }

        val key = dayKey(date)
        val dayItems = items
            .filter { key in it.start..it.end }
            .sortedWith(compareBy({ it.type }, { it.sortKey }))
        val holiday = dayItems.firstOrNull { it.type == TYPE_HOLIDAY }

        // 오늘은 파란 원 위 흰 숫자 (일요일·공휴일이어도 흰색)
        val dayViewId = when {
            key == todayKey -> R.id.cal_day_today
            col == 0 || holiday != null -> R.id.cal_day_red
            else -> R.id.cal_day
        }
        cell.setTextViewText(dayViewId, day)
        if (dayViewId != R.id.cal_day) {
            cell.setViewVisibility(R.id.cal_day, View.GONE)
            cell.setViewVisibility(dayViewId, View.VISIBLE)
        }
        if (key == todayKey) cell.setViewVisibility(R.id.cal_today, View.VISIBLE)

        // 공휴일 라벨이 있으면 3번째 바가 라벨과 겹치므로 최대 2개
        val bars = dayItems.take(if (holiday != null) 2 else 3)
        BAR_IDS.forEachIndexed { i, id ->
            if (i < bars.size) {
                cell.setImageViewResource(id, barRes(bars[i].type))
                cell.setViewVisibility(id, View.VISIBLE)
            }
        }

        if (holiday != null) {
            cell.setTextViewText(R.id.cal_label, holiday.cellLabel)
            cell.setViewVisibility(R.id.cal_label, View.VISIBLE)
        }
        return cell
    }

    private fun buildListItem(context: Context, item: Item, isLast: Boolean): RemoteViews {
        val row = RemoteViews(context.packageName, R.layout.lawding_widget_cal_item)
        row.setImageViewResource(R.id.cal_item_bar, listBarRes(item.type))
        row.setTextViewText(R.id.cal_item_title, item.title)
        if (item.sub.isEmpty()) {
            row.setViewVisibility(R.id.cal_item_sub, View.GONE)
        } else {
            row.setTextViewText(R.id.cal_item_sub, item.sub)
        }
        if (item.badge != null) {
            row.setTextViewText(R.id.cal_item_badge, item.badge)
            row.setViewVisibility(R.id.cal_item_badge, View.VISIBLE)
        }
        if (!isLast) row.setViewVisibility(R.id.cal_item_divider, View.VISIBLE)
        return row
    }

    private fun loadItems(context: Context): List<Item> {
        val raw = HomeWidgetPlugin.getData(context).getString(DATA_KEY, null)
        if (raw.isNullOrEmpty()) return emptyList()
        return try {
            val arr = JSONObject(raw).getJSONArray("items")
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                Item(
                    start = o.getString("s").replace("-", "").toInt(),
                    end = o.getString("e").replace("-", "").toInt(),
                    type = o.getInt("t"),
                    sortKey = o.optInt("k"),
                    title = o.optString("title"),
                    sub = o.optString("sub"),
                    cellLabel = o.optString("cell"),
                    badge = o.optString("badge").ifEmpty { null },
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun dayKey(c: Calendar): Int =
        c.get(Calendar.YEAR) * 10000 + (c.get(Calendar.MONTH) + 1) * 100 + c.get(Calendar.DAY_OF_MONTH)

    private fun barRes(type: Int) = when (type) {
        TYPE_HOLIDAY -> R.drawable.widget_cal_bar_holiday
        TYPE_LEAVE -> R.drawable.widget_cal_bar_leave
        else -> R.drawable.widget_cal_bar_other
    }

    private fun listBarRes(type: Int) = when (type) {
        TYPE_HOLIDAY -> R.drawable.widget_cal_list_bar_holiday
        TYPE_LEAVE -> R.drawable.widget_cal_list_bar_leave
        else -> R.drawable.widget_cal_list_bar_other
    }

    companion object {
        private const val DATA_KEY = "widgetCalendarData"
        private const val TYPE_HOLIDAY = 0
        private const val TYPE_LEAVE = 1
        private val BAR_IDS = intArrayOf(R.id.cal_bar1, R.id.cal_bar2, R.id.cal_bar3)
    }
}
