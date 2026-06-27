import WidgetKit
import SwiftUI
import AppIntents

private let appGroupId = "group.com.example.homewidgetcounterdemo"

@available(iOS 17.0, *)
struct IncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment"
    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: appGroupId)
        let n = Int(d?.string(forKey: "counter_value") ?? "0") ?? 0
        d?.set("\(n + 1)", forKey: "counter_value")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

@available(iOS 17.0, *)
struct DecrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Decrement"
    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: appGroupId)
        let n = Int(d?.string(forKey: "counter_value") ?? "0") ?? 0
        d?.set("\(max(n - 1, 0))", forKey: "counter_value")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

@available(iOS 17.0, *)
struct ToggleThemeIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Theme"
    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: appGroupId)
        let isDark = d?.bool(forKey: "is_dark_mode") ?? false
        d?.set(!isDark, forKey: "is_dark_mode")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let count: Int
    let isDark: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), count: 0, isDark: false)
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(read())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [read()], policy: .atEnd))
    }
    private func read() -> SimpleEntry {
        let d = UserDefaults(suiteName: appGroupId)
        let n = Int(d?.string(forKey: "counter_value") ?? "0") ?? 0
        let isDark = d?.bool(forKey: "is_dark_mode") ?? false
        return SimpleEntry(date: Date(), count: n, isDark: isDark)
    }
}

struct CounterWidgetExtensionEntryView: View {
    var entry: SimpleEntry

    var fg: Color { entry.isDark ? .white : .black }
    var bg: Color { entry.isDark ? .black : .white }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                if #available(iOS 17.0, *) {
                    Button(intent: ToggleThemeIntent()) {
                        Image(systemName: entry.isDark ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 16))
                            .foregroundColor(fg)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Counter")
                .font(.caption)
                .foregroundColor(fg)

            Text("\(entry.count)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(fg)

            if #available(iOS 17.0, *) {
                HStack(spacing: 24) {
                    Button(intent: DecrementIntent()) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(fg)
                    }
                    .buttonStyle(.plain)

                    Button(intent: IncrementIntent()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(fg)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bg)
    }
}

struct CounterWidgetExtension: Widget {
    let kind: String = "CounterWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CounterWidgetExtensionEntryView(entry: entry)
                    .containerBackground(
                        entry.isDark ? Color.black : Color.white,
                        for: .widget
                    )
            } else {
                CounterWidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background(entry.isDark ? Color.black : Color.white)
            }
        }
        .configurationDisplayName("Counter")
        .description("Tap +/- to change the counter.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CounterWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, count: 7, isDark: false)
}