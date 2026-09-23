import WidgetKit
import SwiftUI

@main
struct LawdingWidgetBundle: WidgetBundle {
    var body: some Widget {
        LawdingWidget()
        LawdingNextWidget()
        LawdingCalendarWidget()
        LawdingLargeWidget()
    }
}
