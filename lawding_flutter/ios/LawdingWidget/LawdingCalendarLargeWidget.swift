import WidgetKit
import SwiftUI

// Flutter CalendarWidgetSync가 저장하는 항목. 날짜 계산은 그리는 시점에 수행한다.
struct CalendarWidgetItem: Decodable {
    let s: String
    let e: String
    let t: Int
    let k: Int
    let title: String
    let sub: String
    let cell: String?
    let badge: String?

    var start: Int { Int(s.replacingOccurrences(of: "-", with: "")) ?? 0 }
    var end: Int { Int(e.replacingOccurrences(of: "-", with: "")) ?? 0 }
}

private struct CalendarWidgetPayload: Decodable {
    let items: [CalendarWidgetItem]
}

struct CalendarLargeEntry: TimelineEntry {
    let date: Date
    let items: [CalendarWidgetItem]
}

struct CalendarLargeProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarLargeEntry {
        CalendarLargeEntry(date: Date(), items: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarLargeEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarLargeEntry>) -> Void) {
        let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        )!
        completion(Timeline(entries: [loadEntry()], policy: .after(midnight)))
    }

    private func loadEntry() -> CalendarLargeEntry {
        let raw = UserDefaults(suiteName: "group.com.lawding.annualleavecalculator")?
            .string(forKey: "widgetCalendarData") ?? ""
        let items = (try? JSONDecoder().decode(CalendarWidgetPayload.self, from: Data(raw.utf8)))?.items ?? []
        return CalendarLargeEntry(date: Date(), items: items)
    }
}

// MARK: - Model

private struct CalendarMonthModel {
    struct Day: Identifiable {
        let id: Int
        let day: Int
        let isToday: Bool
        let isRed: Bool
        let bars: [Int]
        let label: String?
    }

    static let typeHoliday = 0

    let title: String
    let weeks: [[Day]]
    let upcoming: [CalendarWidgetItem]

    init(today: Date, items: [CalendarWidgetItem]) {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.dateComponents([.year, .month, .day], from: today)
        let year = now.year!, month = now.month!
        let todayKey = year * 10000 + month * 100 + now.day!
        title = "\(year)년 \(month)월"

        let first = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        let offset = cal.component(.weekday, from: first) - 1
        let daysInMonth = cal.range(of: .day, in: .month, for: first)!.count
        let weekCount = (offset + daysInMonth + 6) / 7

        weeks = (0..<weekCount).map { w in
            (0..<7).map { col in
                let index = w * 7 + col
                let date = cal.date(byAdding: .day, value: index - offset, to: first)!
                let c = cal.dateComponents([.year, .month, .day], from: date)
                // 앞뒤 달 날짜는 숫자만 표시 (디자인)
                guard c.month == month else {
                    return Day(id: index, day: c.day!, isToday: false, isRed: false, bars: [], label: nil)
                }
                let key = c.year! * 10000 + c.month! * 100 + c.day!
                let dayItems = items
                    .filter { $0.start <= key && key <= $0.end }
                    .sorted { ($0.t, $0.k) < ($1.t, $1.k) }
                let holiday = dayItems.first { $0.t == Self.typeHoliday }
                // 공휴일 라벨이 있으면 3번째 바가 라벨과 겹치므로 최대 2개
                let bars = dayItems.prefix(holiday == nil ? 3 : 2).map(\.t)
                return Day(
                    id: index,
                    day: c.day!,
                    isToday: key == todayKey,
                    isRed: col == 0 || holiday != nil,
                    bars: Array(bars),
                    label: holiday?.cell
                )
            }
        }

        // 진행 중인 일정은 오늘 날짜로 취급해 정렬한다. 6주인 달은 공간이 부족해 1개만.
        upcoming = Array(
            items
                .filter { $0.end >= todayKey }
                .sorted { (max($0.start, todayKey), $0.t, $0.k) < (max($1.start, todayKey), $1.t, $1.k) }
                .prefix(weekCount >= 6 ? 1 : 2)
        )
    }
}

// MARK: - View

struct LawdingCalendarLargeView: View {
    let entry: CalendarLargeEntry

    // 디자인 원본 크기. 이 크기로 그린 뒤 기기 위젯 크기에 맞춰 균등 축소/확대한다.
    private static let designSize = CGSize(width: 364, height: 382)

    /// 디자인 측정값(pt). 행 안의 위치는 행 위쪽 기준이며 숫자 중심은 12.
    private struct Layout {
        let headerCenter: CGFloat
        let arrowLeading: CGFloat
        let arrowTrailing: CGFloat
        let titleSize: CGFloat
        let weekdayCenter: CGFloat
        let gridInset: CGFloat
        let gridTop: CGFloat
        let rowHeight: CGFloat
        let barInset: CGFloat
        let barCenter: CGFloat
        let labelCenter: CGFloat
        let labelSize: CGFloat

        static let withList = Layout(
            headerCenter: 26.5, arrowLeading: 33, arrowTrailing: 34.5, titleSize: 17,
            weekdayCenter: 66, gridInset: 25, gridTop: 74, rowHeight: 38.35,
            barInset: 2.7, barCenter: 19.6, labelCenter: 29.5, labelSize: 8
        )

        /// 다가오는 일정이 없을 때의 별도 디자인. 마지막 주 아래 여백(21.5)을 유지하고
        /// 남는 높이를 주끼리 나눈다 (5주면 디자인과 같은 55.08).
        static func calendarOnly(weeks: Int) -> Layout {
            Layout(
                headerCenter: 36.2, arrowLeading: 40.6, arrowTrailing: 39.9, titleSize: 15,
                weekdayCenter: 75, gridInset: 32.3, gridTop: 85.1,
                rowHeight: (382 - 85.1 - 21.5) / CGFloat(weeks),
                barInset: 3, barCenter: 24.1, labelCenter: 32.1, labelSize: 6
            )
        }
    }

    private let primary = Color("WidgetTextPrimary")
    private let secondary = Color("WidgetTextSecondary")
    private let accent = Color("WidgetAccent")

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / Self.designSize.width, geo.size.height / Self.designSize.height)
            content(CalendarMonthModel(today: entry.date, items: entry.items))
                .frame(width: Self.designSize.width, height: Self.designSize.height)
                .scaleEffect(scale)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .widgetBackground(Color("WidgetBackground"))
        .widgetURL(URL(string: "ggimiowner.annualleavecalculator://add-calendar"))
    }

    private func content(_ model: CalendarMonthModel) -> some View {
        // 다가오는 일정이 없으면 리스트 없이 달력만 위젯을 채우는 디자인을 쓴다.
        let l = model.upcoming.isEmpty ? Layout.calendarOnly(weeks: model.weeks.count) : Layout.withList
        let colWidth = (Self.designSize.width - l.gridInset * 2) / 7
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                Chevron(pointsLeft: true, color: primary)
                Spacer(minLength: 0)
                Text(model.title)
                    .font(.custom("Pretendard-Bold", size: l.titleSize))
                    .foregroundColor(primary)
                Spacer(minLength: 0)
                Chevron(pointsLeft: false, color: primary)
            }
            .padding(.leading, l.arrowLeading)
            .padding(.trailing, l.arrowTrailing)
            .frame(height: 24)
            .padding(.top, l.headerCenter - 12)

            HStack(spacing: 0) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { label in
                    Text(label)
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(primary)
                        .frame(width: colWidth)
                }
            }
            .frame(height: 16)
            .padding(.top, l.weekdayCenter - 8 - (l.headerCenter + 12))

            VStack(spacing: 0) {
                ForEach(model.weeks.indices, id: \.self) { w in
                    HStack(spacing: 0) {
                        ForEach(model.weeks[w]) { day in
                            cell(day, layout: l, width: colWidth)
                        }
                    }
                }
            }
            .padding(.horizontal, l.gridInset)
            .padding(.top, l.gridTop - (l.weekdayCenter + 8))

            if !model.upcoming.isEmpty {
                // 달력과 리스트 사이 구분선(0.9 + 0.5)을 뺀 만큼 띄워 리스트 위치를 유지한다.
                list(model.upcoming).padding(.top, 1.4)
            }

            Spacer(minLength: 0)
        }
    }

    private func cell(_ day: CalendarMonthModel.Day, layout l: Layout, width: CGFloat) -> some View {
        ZStack(alignment: .top) {
            // 오늘: 숫자 중심(12)에 맞춘 지름 22 원 + 흰 숫자. 라이트·다크 동일.
            if day.isToday {
                Circle()
                    .fill(accent)
                    .frame(width: 22, height: 22)
                    .padding(.top, 1)
            }
            Text(String(day.day))
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundColor(day.isToday ? .white : day.isRed ? Color("WidgetHolidayText") : primary)
                .frame(height: 14)
                .padding(.top, 5)
            VStack(spacing: 1) {
                ForEach(Array(day.bars.enumerated()), id: \.offset) { _, type in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(barColor(type))
                        .frame(height: 2)
                }
            }
            .padding(.horizontal, l.barInset)
            .padding(.top, l.barCenter - 1)
            if let label = day.label {
                Text(label)
                    .font(.custom("Pretendard-SemiBold", size: l.labelSize))
                    .foregroundColor(Color("WidgetHolidayBar"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(height: 10)
                    .padding(.top, l.labelCenter - 5)
            }
        }
        .frame(width: width, height: l.rowHeight, alignment: .top)
    }

    private func list(_ items: [CalendarWidgetItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                listRow(item).padding(.top, 3)
                if index < items.count - 1 {
                    divider.padding(.top, 2.5)
                }
            }
        }
        .padding(.leading, 13.6)
        .padding(.trailing, 15.4)
    }

    private func listRow(_ item: CalendarWidgetItem) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(barColor(item.t))
                .frame(width: 7, height: 44)
            VStack(alignment: .leading, spacing: 0.2) {
                Text(item.title)
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(primary)
                    .lineLimit(1)
                    .frame(height: 18)
                if !item.sub.isEmpty {
                    Text(item.sub)
                        .font(.custom("Pretendard-SemiBold", size: 11))
                        .foregroundColor(secondary)
                        .lineLimit(1)
                        .frame(height: 18)
                }
            }
            .padding(.leading, 13.4)
            Spacer(minLength: 8)
            if let badge = item.badge {
                Text(badge)
                    .font(.custom("Pretendard-Bold", size: 8))
                    .foregroundColor(accent)
                    .padding(.horizontal, 8)
                    .frame(height: 14)
                    .background(Capsule().fill(Color("WidgetPillBlue")))
                    .padding(.trailing, 8.7)
            }
        }
        .frame(height: 44)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("WidgetDivider"))
            .frame(height: 0.5)
    }

    private func barColor(_ type: Int) -> Color {
        switch type {
        case CalendarMonthModel.typeHoliday: return Color("WidgetHolidayBar")
        case 1: return accent
        default: return Color("WidgetEventBar")
        }
    }
}

private struct Chevron: View {
    let pointsLeft: Bool
    let color: Color

    var body: some View {
        Path { p in
            if pointsLeft {
                p.move(to: CGPoint(x: 7, y: 1))
                p.addLine(to: CGPoint(x: 1.2, y: 6.5))
                p.addLine(to: CGPoint(x: 7, y: 12))
            } else {
                p.move(to: CGPoint(x: 1, y: 1))
                p.addLine(to: CGPoint(x: 6.8, y: 6.5))
                p.addLine(to: CGPoint(x: 1, y: 12))
            }
        }
        .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
        .frame(width: 8, height: 13)
    }
}

// MARK: - Widget

struct LawdingCalendarLargeWidget: Widget {
    let kind = "LawdingCalendarLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarLargeProvider()) { entry in
            LawdingCalendarLargeView(entry: entry)
        }
        .configurationDisplayName("월간 캘린더")
        .description("이번 달 공휴일과 다가오는 일정을 한눈에 확인하세요.")
        .supportedFamilies([.systemLarge])
        // 디자인 좌표가 위젯 가장자리 기준이라 시스템 기본 여백을 끈다.
        .contentMarginsDisabled()
    }
}
