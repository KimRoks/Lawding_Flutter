import WidgetKit
import SwiftUI

private let appGroupId = "group.com.lawding.annualleavecalculator"

@available(iOS 17.0, *)
private struct IgnoreWidgetContentMargins: ViewModifier {
    @Environment(\.widgetContentMargins) private var margins

    func body(content: Content) -> some View {
        content
            .padding(.top, -margins.top)
            .padding(.bottom, -margins.bottom)
            .padding(.leading, -margins.leading)
            .padding(.trailing, -margins.trailing)
    }
}

extension View {
    /// 시스템이 자동으로 넣는 콘텐츠 여백(iOS 17+)을 이 뷰에서만 상쇄해 위젯 가장자리 기준으로 그린다.
    /// 같은 위젯 설정을 쓰는 다른 크기(family)의 여백에는 영향이 없다.
    @ViewBuilder
    func ignoringWidgetContentMargins() -> some View {
        if #available(iOS 17.0, *) {
            modifier(IgnoreWidgetContentMargins())
        } else {
            self
        }
    }

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

    private func parseDay(_ iso: String?) -> Date? {
        guard let iso else { return nil }
        let fmt = DateFormatter()
        // 기기 달력이 일본력·불교력이어도 ISO 날짜를 양력으로 읽도록 고정
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: String(iso.prefix(10))) else { return nil }
        return Calendar.current.startOfDay(for: date)
    }

    /// 시작 전이면 D-n, 시작일~종료일 사이(진행 중)면 D-Day
    private func computeDDay(isoDateStr: String?) -> String? {
        guard let event = parseDay(isoDateStr) else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: today, to: event).day ?? 0
        return diff <= 0 ? "D-Day" : "D-\(diff)"
    }

    private struct UpcomingLeave {
        let date: String
        let type: String?
        let startIso: String?
    }

    /// 대시보드가 저장한 다음 연차 세 칸에서 완전히 지난 일정(종료일 < 오늘)을 빼고 앞으로 당긴다.
    /// 앱을 열지 않아 데이터가 갱신되지 않아도 지난 일정을 보여주지 않기 위함.
    private func upcomingLeaves(_ d: UserDefaults?) -> [UpcomingLeave] {
        let slots = [
            ("widgetMediumNextDate", "widgetMediumNextType", "widgetNextDateIso", "widgetNextEndIso"),
            ("widgetMediumAfterNextDate", "widgetMediumAfterNextType", "widgetAfterNextDateIso", "widgetAfterNextEndIso"),
            ("widgetThirdDate", "widgetThirdType", "widgetThirdDateIso", "widgetThirdEndIso"),
        ]
        let today = Calendar.current.startOfDay(for: Date())
        return slots.compactMap { dateKey, typeKey, startKey, endKey in
            guard let date = strVal(d, dateKey) else { return nil }
            let startIso = strVal(d, startKey)
            // 종료일이 없는 예전 데이터는 시작일로 판단
            if let end = parseDay(strVal(d, endKey) ?? startIso), end < today { return nil }
            return UpcomingLeave(date: date, type: strVal(d, typeKey), startIso: startIso)
        }
    }

    // 빈 문자열은 "값 없음"으로 간주 (iOS home_widget이 null을 못 넣어 Dart가 ""를 저장함)
    private func strVal(_ d: UserDefaults?, _ key: String) -> String? {
        guard let v = d?.string(forKey: key), !v.isEmpty else { return nil }
        return v
    }

    private func loadEntry() -> LawdingEntry {
        let d = UserDefaults(suiteName: appGroupId)
        let leaves = upcomingLeaves(d)
        let next = leaves.indices.contains(0) ? leaves[0] : nil
        let afterNext = leaves.indices.contains(1) ? leaves[1] : nil
        let third = leaves.indices.contains(2) ? leaves[2] : nil
        return LawdingEntry(
            date: Date(),
            days: strVal(d, "widgetDays"),
            totalHours: d?.object(forKey: "widgetTotalHours") as? Int,
            nextDate: next?.date,
            nextType: next?.type,
            afterNextDate: afterNext?.date,
            afterNextType: afterNext?.type,
            nextDDay: computeDDay(isoDateStr: next?.startIso),
            afterNextDDay: computeDDay(isoDateStr: afterNext?.startIso),
            thirdDate: third?.date,
            thirdType: third?.type,
            thirdDDay: computeDDay(isoDateStr: third?.startIso),
            totalDays: strVal(d, "widgetLargeTotalDays"),
            usageRate: strVal(d, "widgetLargeUsageRate"),
            progressPct: d?.object(forKey: "widgetLargeProgressPct") as? Int,
            period: strVal(d, "widgetLargePeriod"),
            expiry: strVal(d, "widgetLargeExpiry"),
            nextDateIso: next?.startIso
        )
    }
}

// MARK: - 2×2 Small View

struct LawdingSmallView: View {
    let entry: LawdingEntry

    // 디자인 원본 크기(pt). 이 크기로 측정 위치에 그린 뒤 기기 위젯 크기에 맞춰 균등 확대/축소한다.
    private static let designSide: CGFloat = 170

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width, geo.size.height) / Self.designSide
            design
                .frame(width: Self.designSide, height: Self.designSide)
                .scaleEffect(scale)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoringWidgetContentMargins()
        .widgetBackground(Color("WidgetBackground"))
    }

    private var design: some View {
        ZStack {
            HStack(spacing: 9.5) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 24)
                Text("잔여 연차")
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(Color("WidgetTextPrimary"))
            }
            .position(x: 80.4, y: 30.6)

            // 소수점 일수(예: 1.875일)는 폭을 넘을 때만 줄어든다
            Text(entry.days.map { "\($0)일" } ?? "--일")
                .font(.custom("Pretendard-Bold", size: 45))
                .foregroundColor(Color("WidgetTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 146)
                .position(x: 84.5, y: 82.7)

            Text(entry.totalHours.map { "\($0)시간" } ?? "--시간")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(Color("WidgetAccent"))
                .lineLimit(1)
                .padding(.horizontal, 16)
                .frame(height: 30)
                .background(Capsule().fill(Color("WidgetPillBlue")))
                .position(x: 84.5, y: 137.4)
        }
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

    // 디자인 원본 크기(pt). 이 크기로 측정 위치에 그린 뒤 기기 위젯 크기에 맞춰 균등 확대/축소한다.
    private static let designSide: CGFloat = 170

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width, geo.size.height) / Self.designSide
            design
                .frame(width: Self.designSide, height: Self.designSide)
                .scaleEffect(scale)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoringWidgetContentMargins()
        .widgetBackground(Color("WidgetBackground"))
    }

    private var design: some View {
        ZStack {
            HStack(spacing: 10) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 24)
                Text("다음 연차")
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(Color("WidgetTextPrimary"))
                    .lineLimit(1)
            }
            .position(x: 80.25, y: 29.9)

            // 긴 날짜(예: 12월 25일)는 폭을 넘을 때만 줄어든다
            Text(entry.nextDate ?? "--")
                .font(.custom("Pretendard-Bold", size: 30))
                .foregroundColor(Color("WidgetTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 150)
                .position(x: 84.4, y: 69.9)

            Text(entry.nextType ?? "--")
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color("WidgetTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 150)
                .position(x: 84.4, y: 104.6)

            Text(entry.nextDDay ?? "--")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(Color("WidgetAccent"))
                .lineLimit(1)
                .padding(.horizontal, 14.5)
                .frame(height: 30)
                .background(Capsule().fill(Color("WidgetPillBlue")))
                .position(x: 84.4, y: 137.8)
        }
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
            .foregroundColor(isNext ? Color("WidgetAccent") : Color("WidgetPillGrayText"))
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
