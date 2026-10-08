import WidgetKit
import SwiftUI

@main
struct LawdingWidgetBundle: WidgetBundle {
    var body: some Widget {
        LawdingNextWidget()
        LawdingWidget()
        LawdingCalendarWidget()
        LawdingLargeWidget()
        LawdingCalendarLargeWidget()
    }
}
