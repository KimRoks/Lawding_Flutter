import WidgetKit
import SwiftUI

private let appGroupId = "group.com.lawding.annualleavecalculator"

extension View {
    // 위젯 전체(시스템 여백 포함)를 지정 색으로 채운다. iOS 16은 콘텐츠 배경으로 폴백.
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { color }
        } else {
            background(color)
        }
    }
}

struct LawdingEntry: TimelineEntry {
    let date: Date
    // 2×2 small
    let days: String?
    let totalHours: Int?
    // 4×2 medium
    let nextDate: String?
    let nextType: String?
    let afterNextDate: String?
    let afterNextType: String?
    // 4×2 calendar
    let nextDDay: String?
    let afterNextDDay: String?
    // 4×4 large (3rd event)
    let thirdDate: String?
    let thirdType: String?
    let thirdDDay: String?
    // 4×4 large (stats)
    let totalDays: String?
    let usageRate: String?
    let progressPct: Int?
    let period: String?
    let expiry: String?
    let nextDateIso: String?
}

struct LawdingProvider: TimelineProvider {
    func placeholder(in context: Context) -> LawdingEntry {
        LawdingEntry(
            date: Date(),
            days: nil, totalHours: nil,
            nextDate: nil, nextType: nil,
            afterNextDate: nil, afterNextType: nil,
            nextDDay: nil, afterNextDDay: nil,
            thirdDate: nil, thirdType: nil, thirdDDay: nil,
            totalDays: nil, usageRate: nil, progressPct: nil,
            period: nil, expiry: nil, nextDateIso: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LawdingEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LawdingEntry>) -> Void) {
        let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        )!
        completion(Timeline(entries: [loadEntry()], policy: .after(midnight)))
    }

    private func computeDDay(isoDateStr: String?) -> String? {
        guard let str = isoDateStr else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let eventDate = fmt.date(from: String(str.prefix(10))) else { return nil }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let event = cal.startOfDay(for: eventDate)
        let diff = cal.dateComponents([.day], from: today, to: event).day ?? 0
        return diff == 0 ? "D-Day" : "D-\(diff)"
    }

    // 빈 문자열은 "값 없음"으로 간주 (iOS home_widget이 null을 못 넣어 Dart가 ""를 저장함)
    private func strVal(_ d: UserDefaults?, _ key: String) -> String? {
        guard let v = d?.string(forKey: key), !v.isEmpty else { return nil }
        return v
    }

    private func loadEntry() -> LawdingEntry {
        let d = UserDefaults(suiteName: appGroupId)
        return LawdingEntry(
            date: Date(),
            days: strVal(d, "widgetDays"),
            totalHours: d?.object(forKey: "widgetTotalHours") as? Int,
            nextDate: strVal(d, "widgetMediumNextDate"),
            nextType: strVal(d, "widgetMediumNextType"),
            afterNextDate: strVal(d, "widgetMediumAfterNextDate"),
            afterNextType: strVal(d, "widgetMediumAfterNextType"),
            nextDDay: computeDDay(isoDateStr: strVal(d, "widgetNextDateIso"))
                ?? strVal(d, "widgetCalNextDDay"),
            afterNextDDay: computeDDay(isoDateStr: strVal(d, "widgetAfterNextDateIso"))
                ?? strVal(d, "widgetCalAfterDDay"),
            thirdDate: strVal(d, "widgetThirdDate"),
            thirdType: strVal(d, "widgetThirdType"),
            thirdDDay: computeDDay(isoDateStr: strVal(d, "widgetThirdDateIso")),
            totalDays: strVal(d, "widgetLargeTotalDays"),
            usageRate: strVal(d, "widgetLargeUsageRate"),
            progressPct: d?.object(forKey: "widgetLargeProgressPct") as? Int,
            period: strVal(d, "widgetLargePeriod"),
            expiry: strVal(d, "widgetLargeExpiry"),
            nextDateIso: strVal(d, "widgetNextDateIso")
        )
    }
}

// MARK: - 2×2 Small View

struct LawdingSmallView: View {
    let entry: LawdingEntry

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 23)
                Text("잔여 연차")
                    .font(.custom("Pretendard-Bold", size: 15))
                    .foregroundColor(Color("WidgetTextPrimary"))
            }
            Spacer()
            Text(entry.days.map { "\($0)일" } ?? "--일")
                .font(.custom("Pretendard-Bold", size: 36))
                .foregroundColor(Color("WidgetTextPrimary"))
            Spacer()
            Text(entry.totalHours.map { "\($0)시간" } ?? "--시간")
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(Color("WidgetAccent"))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("WidgetPillBlue")))
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(Color("WidgetBackground"))
    }
}

// MARK: - 4×2 Medium View

struct LawdingMediumView: View {
    let entry: LawdingEntry

    var nextDateText: String { entry.nextDate ?? "--" }
    var nextTypeText: String { entry.nextType ?? "--" }
    var afterNextText: String {
        guard let d = entry.afterNextDate else { return "다음 예정된 연차 없음" }
        let t = entry.afterNextType ?? ""
        return "다음 일정 \(d) \(t)".trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 23)
                Text("다음 예정 연차")
                    .font(.custom("Pretendard-Bold", size: 15))
                    .foregroundColor(Color("WidgetTextPrimary"))
            }
            .frame(height: 24)

            Text(nextDateText)
                .font(.custom("Pretendard-Bold", size: 26))
                .foregroundColor(Color("WidgetTextPrimary"))
                .padding(.top, 6)

            Text(nextTypeText)
                .font(.custom("Pretendard-SemiBold", size: 13))
                .foregroundColor(Color("WidgetTextSecondary"))
                .padding(.top, 4)

            Rectangle()
                .fill(Color("WidgetDivider"))
                .frame(height: 1)
                .padding(.top, 8)
                .padding(.bottom, 8)

            Text(afterNextText)
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("WidgetTextSecondary"))
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetBackground(Color("WidgetBackground"))
    }
}

// MARK: - Entry View

struct LawdingWidgetView: View {
    let entry: LawdingEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            LawdingMediumView(entry: entry)
        default:
            LawdingSmallView(entry: entry)
        }
    }
}

// MARK: - Next Leave Widget View (2×2)

struct LawdingNextView: View {
    let entry: LawdingEntry

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 23)
                Text("다음 연차")
                    .font(.custom("Pretendard-Bold", size: 15))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 24)

            Text(entry.nextDate ?? "--")
                .font(.custom("Pretendard-Bold", size: 30))
                .foregroundColor(Color("WidgetTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 9)

            Text(entry.nextType ?? "--")
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("WidgetTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 8)

            Text(entry.nextDDay ?? "--")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(Color("WidgetAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("WidgetPillBlue")))
                .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .widgetBackground(Color("WidgetBackground"))
    }
}

// MARK: - Next Leave Widget

struct LawdingNextWidget: Widget {
    let kind = "LawdingNextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LawdingProvider()) { entry in
            LawdingNextView(entry: entry)
        }
        .configurationDisplayName("다음 예정 연차")
        .description("다음 연차 일정과 D-day를 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Calendar Widget View

struct LawdingCalendarView: View {
    let entry: LawdingEntry

    private var nextDateText: String { entry.nextDate ?? "--" }
    private var nextTypeText: String { entry.nextType ?? "--" }
    private var nextDDayText: String { entry.nextDDay ?? "--" }
    private var afterDateText: String { entry.afterNextDate ?? "--" }
    private var afterTypeText: String { entry.afterNextType ?? "--" }
    private var afterDDayText: String { entry.afterNextDDay ?? "--" }

    private func ddayPill(text: String, isNext: Bool) -> some View {
        Text(text)
            .font(.custom("Pretendard-Bold", size: 14))
            .foregroundColor(isNext ? Color("WidgetAccent") : Color("WidgetTextSecondary"))
            .padding(.horizontal, 10)
            .frame(height: 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isNext ? Color("WidgetPillBlue") : Color("WidgetPillGray"))
            )
    }

    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 예정 연차
            VStack(alignment: .leading, spacing: 0) {
                Text("예정 연차")
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
                    .frame(height: 24)
                Text(nextDateText)
                    .font(.custom("Pretendard-Bold", size: 22))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 6)
                Text(nextTypeText)
                    .font(.custom("Pretendard-SemiBold", size: 13))
                    .foregroundColor(Color("WidgetTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.top, 4)
                ddayPill(text: nextDDayText, isNext: true)
                    .padding(.top, 8)
            }
            .padding(.leading, 14)
            .padding(.trailing, 12)

            // 구분선
            Rectangle()
                .fill(Color("WidgetDivider"))
                .frame(width: 1)
                .padding(.vertical, 4)

            // 이후 예정 연차 (컨텐츠 크기만큼만 차지)
            VStack(alignment: .leading, spacing: 0) {
                Text("이후 예정 연차")
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(height: 24)
                Text(afterDateText)
                    .font(.custom("Pretendard-Bold", size: 22))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 6)
                Text(afterTypeText)
                    .font(.custom("Pretendard-SemiBold", size: 13))
                    .foregroundColor(Color("WidgetTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.top, 4)
                ddayPill(text: afterDDayText, isNext: false)
                    .padding(.top, 8)
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)

            // flexible spacer
            Spacer(minLength: 0)

            // 캘린더 추가 버튼
            Link(destination: URL(string: "ggimiowner.annualleavecalculator://add-calendar")!) {
                ZStack {
                    Circle()
                        .fill(Color("WidgetAccent"))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(Color("WidgetBackground"))
    }
}

// MARK: - Calendar Widget

struct LawdingCalendarWidget: Widget {
    let kind = "LawdingCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LawdingProvider()) { entry in
            LawdingCalendarView(entry: entry)
        }
        .configurationDisplayName("연차 캘린더")
        .description("예정된 연차 일정을 확인하고 추가하세요.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget

struct LawdingWidget: Widget {
    let kind = "LawdingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LawdingProvider()) { entry in
            LawdingWidgetView(entry: entry)
        }
        .configurationDisplayName("잔여연차")
        .description("남은 연차 일수를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 4×4 Large Widget View

struct LawdingLargeView: View {
    let entry: LawdingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더: statistics_ic + 연차 종합현황
            HStack(spacing: 6) {
                Image("statistics_ic")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 25, height: 23)
                Text("연차 종합현황")
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(Color("WidgetTextPrimary"))
            }

            // 잔여 연차 (큰 숫자)
            Text(entry.days.map { "\($0)일" } ?? "--일")
                .font(.custom("Pretendard-Bold", size: 55))
                .foregroundColor(Color("WidgetTextPrimary"))
                .padding(.top, 14)

            // 총 발생 연차
            Text("총 발생 연차")
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("WidgetTextMuted"))
                .padding(.top, 12)
            Text(entry.totalDays.map { "\($0)일" } ?? "--일")
                .font(.custom("Pretendard-Bold", size: 24))
                .foregroundColor(Color("WidgetTextMuted"))
                .padding(.top, 2)

            // 연차 사용률 + 비율
            HStack {
                Text("연차 사용률")
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(Color("WidgetAccent"))
                Spacer()
                Text(entry.usageRate ?? "--")
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(Color("WidgetAccent"))
            }
            .padding(.top, 12)

            // 프로그레스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 17)
                        .fill(Color("WidgetProgressTrack"))
                    if let pct = entry.progressPct, pct > 0 {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color("WidgetAccent"))
                            .frame(width: geo.size.width * Double(min(pct, 100)) / 100.0)
                    }
                }
            }
            .frame(height: 10)
            .padding(.top, 6)

            Spacer(minLength: 10)

            // 하단 정보 3줄
            infoLine("사용 기간", entry.period ?? "--")
            infoLine("다음 소멸", entry.expiry ?? "--")
                .padding(.top, 12)
            infoLine("다음 연차", entry.nextDateIso ?? "--")
                .padding(.top, 12)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetBackground(Color("WidgetBackground"))
    }

    private func infoLine(_ label: String, _ value: String) -> some View {
        Text("\(label) : \(value)")
            .font(.custom("Pretendard-SemiBold", size: 16))
            .foregroundColor(Color("WidgetTextMuted"))
    }
}

// MARK: - Large Widget

struct LawdingLargeWidget: Widget {
    let kind = "LawdingLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LawdingProvider()) { entry in
            LawdingLargeView(entry: entry)
        }
        .configurationDisplayName("연차 종합")
        .description("잔여 연차와 예정 연차 목록을 한눈에 확인하세요.")
        .supportedFamilies([.systemLarge])
    }
}
