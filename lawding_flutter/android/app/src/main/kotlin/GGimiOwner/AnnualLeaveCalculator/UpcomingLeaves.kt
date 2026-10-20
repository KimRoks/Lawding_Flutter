package com.lawding.annualleavecalculator

import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.TimeUnit

/**
 * 대시보드가 저장한 다음 연차 세 칸(다음·그다음·세 번째)에서
 * 완전히 지난 일정(종료일 < 오늘)을 빼고 남은 일정을 앞으로 당긴다.
 * 앱을 열지 않아 데이터가 갱신되지 않아도 위젯이 지난 일정을 보여주지 않게 하기 위함.
 */
object UpcomingLeaves {

    /** [date]: "10월 12일" 같은 표시용, [startIso]: "2026-10-12" */
    class Leave(val date: String, val type: String?, val startIso: String?) {
        private val start = startIso?.let(::parseDay)

        /** 시작 전이면 D-n, 시작일~종료일 사이면 D-Day. 시작일을 모르면 null. */
        fun dDay(today: Calendar = startOfToday()): String? {
            val s = start ?: return null
            val diff = TimeUnit.MILLISECONDS.toDays(s.timeInMillis - today.timeInMillis)
            return if (diff <= 0) "D-Day" else "D-$diff"
        }
    }

    // 표시 날짜 · 종류 · 시작일 · 종료일 키
    private val SLOTS = listOf(
        listOf("widgetMediumNextDate", "widgetMediumNextType", "widgetNextDateIso", "widgetNextEndIso"),
        listOf("widgetMediumAfterNextDate", "widgetMediumAfterNextType", "widgetAfterNextDateIso", "widgetAfterNextEndIso"),
        listOf("widgetThirdDate", "widgetThirdType", "widgetThirdDateIso", "widgetThirdEndIso"),
    )

    fun load(data: SharedPreferences): List<Leave> {
        val today = startOfToday()
        return SLOTS.mapNotNull { (dateKey, typeKey, startKey, endKey) ->
            val date = data.str(dateKey) ?: return@mapNotNull null
            val startIso = data.str(startKey)
            // 종료일이 없는 예전 데이터는 시작일로 판단
            val end = (data.str(endKey) ?: startIso)?.let(::parseDay)
            if (end != null && end.before(today)) null else Leave(date, data.str(typeKey), startIso)
        }
    }

    private fun SharedPreferences.str(key: String): String? = getString(key, null)?.ifEmpty { null }

    private fun parseDay(iso: String): Calendar? = try {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { isLenient = false }
        val date = sdf.parse(iso.take(10)) ?: throw IllegalArgumentException()
        Calendar.getInstance().apply { time = date }.startOfDay()
    } catch (e: Exception) {
        null
    }

    private fun startOfToday(): Calendar = Calendar.getInstance().startOfDay()

    private fun Calendar.startOfDay(): Calendar = apply {
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }
}
