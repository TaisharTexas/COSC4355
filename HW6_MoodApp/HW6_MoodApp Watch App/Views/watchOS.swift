
import SwiftUI
import WatchKit
import Combine

// ============================================
// 1. DATA PERSISTENCE WITH USERDEFAULTS
// ============================================

// Saving simple data
func saveString() {
    UserDefaults.standard.set("Hello", forKey: "greeting")
}

// Saving complex data with Codable
struct Task: Codable {
    let title: String
    let isComplete: Bool
}

func saveTask() {
    let task = Task(title: "Study", isComplete: false)
    if let encoded = try? JSONEncoder().encode(task) {
        UserDefaults.standard.set(encoded, forKey: "currentTask")
    }
}

func loadTask() -> Task? {
    guard let data = UserDefaults.standard.data(forKey: "currentTask") else { return nil }
    return try? JSONDecoder().decode(Task.self, from: data)
}

// ============================================
// 2. OBSERVABLE OBJECT & PUBLISHED PROPERTIES
// ============================================

class CounterStore: ObservableObject {
    @Published var count: Int = 0
    @Published var history: [Int] = []
    
    func increment() {
        count += 1
        history.append(count)
        saveCount()
    }
    
    func reset() {
        count = 0
        history.removeAll()
        saveCount()
    }
    
    private func saveCount() {
        UserDefaults.standard.set(count, forKey: "counter")
    }
    
    func loadCount() {
        count = UserDefaults.standard.integer(forKey: "counter")
    }
}

// ============================================
// 3. @STATEOBJECT VS @OBSERVEDOBJECT
// ============================================

// Parent View - Creates and OWNS the data source
struct ParentView: View {
    @StateObject private var store = CounterStore() // Use StateObject here!
    
    var body: some View {
        VStack {
            Text("Count: \(store.count)")
            ChildView(store: store) // Pass to child
        }
    }
}

// Child View - OBSERVES the data source (doesn't own it)
struct ChildView: View {
    @ObservedObject var store: CounterStore // Use ObservedObject here!
    
    var body: some View {
        Button("Increment") {
            store.increment()
        }
    }
}

// ============================================
// 4. HAPTIC FEEDBACK
// ============================================

struct HapticExamples: View {
    var body: some View {
        VStack {
            Button("Success") {
                WKInterfaceDevice.current().play(.success)
            }
            
            Button("Failure") {
                WKInterfaceDevice.current().play(.failure)
            }
            
            Button("Click") {
                WKInterfaceDevice.current().play(.click)
            }
            
            Button("Start") {
                WKInterfaceDevice.current().play(.start)
            }
            
            Button("Stop") {
                WKInterfaceDevice.current().play(.stop)
            }
        }
    }
}

// ============================================
// 5. SENSORY FEEDBACK
// ============================================

struct SensoryFeedbackExamples: View {
    @State private var counter = 0
    @State private var isSelected = false
    
    var body: some View {
        VStack {
            // Triggers when counter changes
            Button("Count: \(counter)") {
                counter += 1
            }
            .sensoryFeedback(.selection, trigger: counter)
            
            // Triggers on success
            Button("Toggle") {
                isSelected.toggle()
            }
            .sensoryFeedback(.success, trigger: isSelected)
            
            // Impact feedback
            Button("Impact") {
                counter += 1
            }
            .sensoryFeedback(.impact, trigger: counter)
        }
    }
}

// ============================================
// 6. SCENE PHASE & LIFECYCLE
// ============================================

struct LifecycleExample: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var lastActiveTime = Date()
    
    var body: some View {
        VStack {
            Text("Last active:")
            Text(lastActiveTime, style: .time)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                print("App is active")
                lastActiveTime = Date()
                // Resume timers, refresh data
            case .inactive:
                print("App is inactive")
                // Pause work
            case .background:
                print("App in background")
                // Save state, stop timers
            @unknown default:
                break
            }
        }
        .onAppear {
            print("View appeared")
        }
        .onDisappear {
            print("View disappeared")
        }
    }
}

// ============================================
// 7. TIMER MANAGEMENT
// ============================================

struct TimerExample: View {
    @State private var counter = 0
    @State private var timer: Timer?
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Text("Counter: \(counter)")
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    startTimer()
                } else {
                    stopTimer()
                }
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            counter += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// ============================================
// 8. GEOMETRY READER FOR RESPONSIVE LAYOUTS
// ============================================

struct GeometryExample: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Use geometry.size to make responsive layouts
                Rectangle()
                    .fill(.blue)
                    .frame(width: geometry.size.width * 0.8,
                           height: geometry.size.height * 0.3)
                
                HStack(spacing: 5) {
                    // Divide width equally among 4 items
                    ForEach(0..<4) { i in
                        Rectangle()
                            .fill(.red)
                            .frame(width: (geometry.size.width - 15) / 4,
                                   height: 50)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

// ============================================
// 9. DATE FORMATTING
// ============================================

func todayKey() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func formatFull(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// ============================================
// 10. CUSTOM BUTTON STYLES
// ============================================

struct CustomButtonExample: View {
    var body: some View {
        VStack(spacing: 10) {
            // Plain style (no background)
            Button("Plain") {
                print("Tapped")
            }
            .buttonStyle(.plain)
            
            // Bordered style
            Button("Bordered") {
                print("Tapped")
            }
            .buttonStyle(.bordered)
            
            // Borderedprominent style
            Button("Prominent") {
                print("Tapped")
            }
            .buttonStyle(.borderedProminent)
            
            // Custom frame with minimum touch target
            Button {
                print("Tapped")
            } label: {
                Text("Custom")
                    .font(.caption)
            }
            .frame(minWidth: 44, minHeight: 44) // Minimum for accessibility
        }
    }
}

// ============================================
// 11. ANIMATIONS
// ============================================

struct AnimationExample: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            // Simple animation
            Circle()
                .fill(.blue)
                .frame(width: 50, height: 50)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 0.3), value: scale)
                .onTapGesture {
                    scale = scale == 1.0 ? 1.5 : 1.0
                }
            
            // Spring animation
            Rectangle()
                .fill(.red)
                .frame(width: 50, height: 50)
                .offset(x: offset)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: offset)
                .onTapGesture {
                    offset = offset == 0 ? 50 : 0
                }
            
            // Opacity fade
            Text("Fade")
                .opacity(opacity)
                .animation(.linear(duration: 0.5), value: opacity)
                .onTapGesture {
                    opacity = opacity == 1.0 ? 0.3 : 1.0
                }
        }
    }
}

// ============================================
// 12. NAVIGATIONSTACK
// ============================================

struct NavigationExample: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Go to Detail") {
                    DetailView()
                }
                NavigationLink("Go to Settings") {
                    SettingsView()
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail View")
            .navigationTitle("Detail")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .navigationTitle("Settings")
    }
}

// ============================================
// 13. SCROLLVIEW WITH PROPER SPACING
// ============================================

struct ScrollViewExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(0..<20) { i in
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Item \(i)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

// ============================================
// 14. ENUM WITH CODABLE
// ============================================

enum Status: String, Codable, CaseIterable {
    case pending
    case inProgress = "in_progress"
    case completed
    case failed
}

// Can iterate over all cases
func showAllStatuses() {
    for status in Status.allCases {
        print(status.rawValue)
    }
}

// ============================================
// 15. COMBINING MULTIPLE CONCEPTS
// ============================================

// Complete example: Counter app with persistence, haptics, and animations
struct CompleteCounterApp: View {
    @StateObject private var store = CounterStore()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Counter App")
                    .font(.headline)
                
                Text("\(store.count)")
                    .font(.system(size: 60))
                    .monospacedDigit()
                    .animation(.spring(), value: store.count)
                
                HStack(spacing: 15) {
                    Button {
                        store.increment()
                        WKInterfaceDevice.current().play(.success)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(.borderedProminent)
                    .sensoryFeedback(.selection, trigger: store.count)
                    
                    Button {
                        store.reset()
                        WKInterfaceDevice.current().play(.click)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                    }
                    .buttonStyle(.bordered)
                }
                
                // History visualization
                GeometryReader { geometry in
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(store.history.suffix(10).indices, id: \.self) { index in
                            let value = store.history.suffix(10)[index]
                            let maxValue = store.history.suffix(10).max() ?? 1
                            
                            Rectangle()
                                .fill(.blue)
                                .frame(
                                    width: (geometry.size.width - 18) / 10,
                                    height: CGFloat(value) / CGFloat(maxValue) * 100
                                )
                                .animation(.easeInOut, value: store.history.count)
                        }
                    }
                }
                .frame(height: 100)
            }
            .padding()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                store.loadCount()
            }
        }
        .onAppear {
            store.loadCount()
        }
    }
}

// ============================================
// 16. OBJECTWILLCHANGE FOR MANUAL UPDATES
// ============================================

class DataStore: ObservableObject {
    var internalData: [String] = []
    
    func addItem(_ item: String) {
        internalData.append(item)
        // Manually trigger view update
        objectWillChange.send()
    }
    
    func clearAll() {
        internalData.removeAll()
        objectWillChange.send()
    }
}

// ============================================
// 17. MONOSPACEDDIGIT FOR CONSISTENT NUMBERS
// ============================================

struct MonospacedExample: View {
    @State private var number = 0
    
    var body: some View {
        VStack {
            // Without monospaced - numbers shift
            Text("\(number)")
                .font(.largeTitle)
            
            // With monospaced - numbers stay aligned
            Text("\(number)")
                .font(.largeTitle)
                .monospacedDigit()
            
            Button("Increment") {
                number += 1
            }
        }
    }
}

// ============================================
// 18. DICTIONARY DATA STRUCTURES
// ============================================

class DataTracker: ObservableObject {
    @Published var dailyData: [String: [String: Int]] = [:]
    
    func addEntry(date: String, category: String) {
        if dailyData[date] == nil {
            dailyData[date] = [:]
        }
        
        let currentCount = dailyData[date]?[category] ?? 0
        dailyData[date]?[category] = currentCount + 1
    }
    
    func getCount(date: String, category: String) -> Int {
        return dailyData[date]?[category] ?? 0
    }
    
    func getTotalForDate(date: String) -> Int {
        return dailyData[date]?.values.reduce(0, +) ?? 0
    }
}

// ============================================
// 19. ERROR HANDLING WITH TRY-CATCH
// ============================================

func saveDataSafely<T: Codable>(_ data: T, key: String) {
    do {
        let encoded = try JSONEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: key)
        print("Saved successfully")
    } catch {
        print("Failed to save: \(error.localizedDescription)")
    }
}

func loadDataSafely<T: Codable>(key: String) -> T? {
    guard let data = UserDefaults.standard.data(forKey: key) else {
        print("No data found")
        return nil
    }
    
    do {
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    } catch {
        print("Failed to decode: \(error)")
        // Clean up corrupted data
        UserDefaults.standard.removeObject(forKey: key)
        return nil
    }
}

// ============================================
// 20. CONDITIONAL MODIFIERS
// ============================================

struct ConditionalModifierExample: View {
    @State private var isActive = false
    
    var body: some View {
        Text("Hello")
            .foregroundColor(isActive ? .green : .gray)
            .font(isActive ? .title : .body)
            .padding(isActive ? 20 : 10)
    }
}
