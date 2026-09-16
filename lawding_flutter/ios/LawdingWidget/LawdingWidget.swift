import WidgetKit
import SwiftUI

private let appGroupId = "group.com.lawding.annualleavecalculator"

struct LawdingEntry: TimelineEntry {
    let date: Date
    let days: String?
    let totalHours: Int?
}

struct LawdingProvider: TimelineProvider {
    func placeholder(in context: Context) -> LawdingEntry {
        LawdingEntry(date: Date(), days: "8.125", totalHours: 65)
    }

    func getSnapshot(in context: Context, completion: @escaping (LawdingEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LawdingEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [loadEntry()], policy: .after(next)))
    }

    private func loadEntry() -> LawdingEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let days = defaults?.string(forKey: "widgetDays")
        let hours = defaults?.object(forKey: "widgetTotalHours") as? Int
        return LawdingEntry(date: Date(), days: days, totalHours: hours)
    }
}

struct LawdingWidgetView: View {
    let entry: LawdingEntry

    var daysText: String {
        guard let d = entry.days else { return "--일" }
        return "\(d)일"
    }

    var hoursText: String {
        guard let h = entry.totalHours else { return "--시간" }
        return "\(h)시간"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image("calendar_tabbar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 23)
                Text("잔여 연차")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0x11/255, green: 0x11/255, blue: 0x11/255))
            }

            Spacer()

            Text(daysText)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color(red: 0x11/255, green: 0x11/255, blue: 0x11/255))

            Spacer()

            Text(hoursText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0x00/255, green: 0x57/255, blue: 0xB8/255))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0xCF/255, green: 0xE6/255, blue: 0xFF/255))
                )
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct LawdingWidget: Widget {
    let kind = "LawdingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LawdingProvider()) { entry in
            LawdingWidgetView(entry: entry)
        }
        .configurationDisplayName("연차계산기")
        .description("남은 연차를 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}
