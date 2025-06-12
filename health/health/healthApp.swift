//
//  healthApp.swift
//  health
//
//  Created by Harry Feng - 448 on 2025-05-15.
//

import SwiftUI
import UserNotifications
import Foundation

// Add to AppState class
class AppState: ObservableObject {
    @Published var steps = 0
    @Published var waterIntake = 0
    @Published var mood = "😊"
    @Published var notificationsEnabled = true
    @Published var darkModeEnabled = false
    @Published var notificationFrequency = 1
    @Published var sharedPlans: [ExercisePlan] = []
    @State private var completions: [DailyCompletion] = loadCompletions()


    @Published var achievements: [Achievement] = [
        Achievement(title: "10K Steps", description: "Walked 10,000 steps in a day", imageName: "figure.walk"),
        Achievement(title: "Hydration Master", description: "Drank 2L of water in a day", imageName: "drop.fill")
    ]
}

struct ExercisePlan: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: PlanCategory
    let duration: Int // in minutes
    let difficulty: String
    let creator: String
    let dateCreated: Date
    var likes: Int = 0
    var comments: [Comment] = []
}

struct Comment: Identifiable, Codable {
    let id = UUID()
    let author: String
    let content: String
    let date: Date
}

enum PlanCategory: String, CaseIterable, Codable {
    case fitness = "Fitness"
    case health = "Health"
    case fatLoss = "Lose Fat"
}

// New Views for the feature
struct CommunityPlansView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: PlanCategory? = nil
    @State private var showingAddPlan = false
    
    var filteredPlans: [ExercisePlan] {
        if let category = selectedCategory {
            return appState.sharedPlans.filter { $0.category == category }
        }
        return appState.sharedPlans
    }
    
    var body: some View {
        VStack {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button("All") {
                        selectedCategory = nil
                    }
                    .padding()
                    .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(selectedCategory == nil ? .white : .primary)
                    .cornerRadius(12)
                    
                    ForEach(PlanCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            selectedCategory = category
                        }
                        .padding()
                        .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            
            // Plans list
            List(filteredPlans) { plan in
                NavigationLink(destination: PlanDetailView(plan: plan)) {
                    VStack(alignment: .leading) {
                        Text(plan.title)
                            .font(.headline)
                        Text(plan.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(plan.duration) min • \(plan.difficulty)")
                            .font(.caption)
                        Text("By \(plan.creator)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Community Plans")
        .toolbar {
            Button {
                showingAddPlan = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddPlan) {
            AddPlanView()
                .environmentObject(appState)
        }
    }
}

struct PlanDetailView: View {
    @EnvironmentObject var appState: AppState
    var plan: ExercisePlan
    @State private var newComment = ""
    @State private var currentPlan: ExercisePlan
    
    init(plan: ExercisePlan) {
        self.plan = plan
        _currentPlan = State(initialValue: plan)
    }
    
    var body: some View {
        ScrollView {
            // ... existing plan details code ...
            
            HStack {
                TextField("Add a comment", text: $newComment)
                Button("Post") {
                    let comment = Comment(
                        author: "User", // Replace with actual username
                        content: newComment,
                        date: Date()
                    )
                    currentPlan.comments.append(comment)
                    newComment = ""
                    
                    // Update the plan in sharedPlans
                    if let index = appState.sharedPlans.firstIndex(where: { $0.id == plan.id }) {
                        appState.sharedPlans[index] = currentPlan
                    }
                }
                .disabled(newComment.isEmpty)
            }
        }
        .navigationTitle("Plan Details")
    }
}

struct AddPlanView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = PlanCategory.fitness
    @State private var duration = 30
    @State private var difficulty = "Beginner"
    let difficultyLevels = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Plan Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PlanCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 5...180, step: 5)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newPlan = ExercisePlan(
                            title: title,
                            description: description,
                            category: selectedCategory,
                            duration: duration,
                            difficulty: difficulty,
                            creator: "User",
                            dateCreated: Date()
                        )
                        appState.sharedPlans.append(newPlan)
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
}


@main
struct HealthyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .preferredColorScheme(appState.darkModeEnabled ? .dark : .light)
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        requestNotificationPermission()
        return true
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: String? = "Trends"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(destination: DashboardView().environmentObject(appState), tag: "Trends", selection: $selectedTab) {
                    Label("Trends", systemImage: "heart.fill")
                        .foregroundColor(.pink)
                }
                NavigationLink(destination: SettingsView().environmentObject(appState), tag: "Settings", selection: $selectedTab) {
                    Label("Settings", systemImage: "gearshape.fill")
                        .foregroundColor(.blue)
                }
                NavigationLink(destination: StatisticsView().environmentObject(appState), tag: "Progress", selection: $selectedTab) {
                    Label("Progress", systemImage: "chart.bar.fill")
                        .foregroundColor(.purple)
                }
                NavigationLink(destination: CommunityPlansView().environmentObject(appState), tag: "Plan", selection: $selectedTab) {
                    Label("Plan", systemImage: "bell.fill")
                        .foregroundColor(.orange)
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Health")
            .background(Color.white.opacity(0.9))
        } detail: {
            if selectedTab == "Trends" {
                DashboardView()
                    .environmentObject(appState)
            } else if selectedTab == "Settings" {
                SettingsView()
                    .environmentObject(appState)
            } else if selectedTab == "Progress" {
                StatisticsView()
                    .environmentObject(appState)
            } else if selectedTab == "Plan" {
                CommunityPlansView()
                    .environmentObject(appState)
            }
        }
    }
}

struct DailyCompletion: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var completed: Bool
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .shadow(radius: 10)
            Toggle(isOn: $appState.notificationsEnabled) {
                Label("Enable Notifications", systemImage: "bell.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            Toggle(isOn: $appState.darkModeEnabled) {
                Label("Enable Dark Mode", systemImage: "moon.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                Label("Notification Frequency", systemImage: "calendar")
                Picker("Frequency", selection: $appState.notificationFrequency) {
                    Text("Daily").tag(1)
                    Text("Weekly").tag(2)
                    Text("Monthly").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 5)
            
            Button("Reset Progress") {
                appState.steps = 0
                appState.waterIntake = 0
                appState.mood = "😊"
            }
            .padding()
            .background(Color.red.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .padding()
    }
}

struct StatisticsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeFrame = "Week"
    let timeFrames = ["Day", "Week", "Month", "Year"]
    
    var body: some View {
        VStack {
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(12)
                .shadow(radius: 10)
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(timeFrames, id: \.self) { frame in
                    Text(frame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Steps chart
            VStack {
                Text("Steps")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 200)
                    .foregroundColor(.gray.opacity(0.2))
                    .overlay(
                        Text("\(appState.steps) steps")
                            .font(.title)
                    )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            
            // Water intake chart
            VStack {
                Text("Water Intake")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 200)
                    .foregroundColor(.gray.opacity(0.2))
                    .overlay(
                        Text("\(appState.waterIntake) ml")
                            .font(.title)
                    )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
        }
        .padding()
    }
}

struct RemindersView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text("Plan")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .background(Color.orange.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 10)
    }
}

import HealthKit

class HealthManager {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success)
        }
    }
    
    func fetchSteps(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthStore.execute(query)
    }
}
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    var isUnlocked: Bool = false
}

class AchievementManager {
    static let shared = AchievementManager()
    
    func checkAchievements(steps: Int, waterIntake: Int, appState: AppState) {
        var achievements = appState.achievements
        
        if steps >= 10000 && !achievements[0].isUnlocked {
            achievements[0].isUnlocked = true
        }
        
        if waterIntake >= 2000 && !achievements[1].isUnlocked {
            achievements[1].isUnlocked = true
        }
        
        appState.achievements = achievements
    }
}
struct RecommendationEngine {
    static func getRecommendation(basedOn steps: Int, waterIntake: Int, mood: String) -> String {
        if steps < 5000 {
            return "Try to walk more today! Aim for at least 5,000 steps."
        } else if waterIntake < 2000 {
            return "Don't forget to stay hydrated! Drink more water."
        } else if mood == "😞" || mood == "😢" {
            return "How about some light exercise to boost your mood?"
        } else {
            return "You're doing great! Keep it up!"
        }
    }
}
struct TrendDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
    let water: Int
}

struct DashboardView: View {

    @EnvironmentObject var appState: AppState
    @State private var healthAuth = false

    let motivationalQuotes = [
        "Keep pushing your limits!",
        "Stay positive, stay fighting!",
        "Believe you can and you're halfway there!",
        "Every day is a new opportunity to improve."
    ]
    enum TrendCategory: String, CaseIterable, Identifiable {
        case fitness = "Fitness"
        case standard = "Standard"
        case postSurgery = "After Surgery"
        
        var id: String { self.rawValue }
    }
    struct DailyCompletion: Identifiable, Codable {
        let id = UUID()
        let date: Date
        var completed: Bool
    }


    struct DailyPlan: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let category: TrendCategory
    }

    struct TrendDataPoint: Identifiable {
        let id = UUID()
        let day: String
        let steps: Int
        let water: Int
    }

    struct DashboardView: View {
        
        @EnvironmentObject var appState: AppState
        @State private var healthAuth = false
        @State private var selectedCategory: TrendCategory = .fitness

        let motivationalQuotes = [
            "Keep pushing your limits!",
            "Stay positive, stay fighting!",
            "Believe you can and you're halfway there!",
            "Every day is a new opportunity to improve."
        ]

        let trendData: [TrendDataPoint] = [
            .init(day: "Mon", steps: 6200, water: 1500),
            .init(day: "Tue", steps: 8700, water: 2000),
            .init(day: "Wed", steps: 4400, water: 1700),
            .init(day: "Thu", steps: 9600, water: 2100),
            .init(day: "Fri", steps: 11000, water: 2300),
            .init(day: "Sat", steps: 7000, water: 1600),
            .init(day: "Sun", steps: 5300, water: 1900)
        ]

        let dailyPlans: [DailyPlan] = [
            .init(title: "Morning Run", description: "Jog for 30 minutes", category: .fitness),
            .init(title: "Stretch Routine", description: "Gentle 15-minute stretch", category: .standard),
            .init(title: "Recovery Walk", description: "Slow 10-minute walk", category: .postSurgery),
            .init(title: "HIIT Workout", description: "20-minute high-intensity workout", category: .fitness),
            .init(title: "Yoga", description: "Calming 20-minute yoga session", category: .standard),
            .init(title: "Breathing & Steps", description: "Deep breathing and light walking", category: .postSurgery)
        ]

        var filteredPlans: [DailyPlan] {
            dailyPlans.filter { $0.category == selectedCategory }
        }

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Trends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(radius: 10)

                    if healthAuth {
                        Text("Today's Steps: \(appState.steps)")
                            .font(.title2)
                            .foregroundColor(.pink)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        Button("Connect Health Progress") {
                            HealthManager.shared.requestAuthorization { success in
                                healthAuth = success
                                if success {
                                    HealthManager.shared.fetchSteps { steps in
                                        appState.steps = Int(steps)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    

                    VStack(alignment: .leading) {
                        Text("Weekly Step Trend")
                            .font(.headline)
                            .padding(.leading)

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(trendData) { point in
                                VStack {
                                    Text("\(point.steps)")
                                        .font(.caption)
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.pink)
                                        .frame(width: 20, height: CGFloat(point.steps) / 100)
                                    Text(point.day)
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Weekly Water Intake")
                            .font(.headline)
                            .padding(.leading)

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(trendData) { point in
                                VStack {
                                    Text("\(point.water)ml")
                                        .font(.caption)
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.blue)
                                        .frame(width: 20, height: CGFloat(point.water) / 10)
                                    Text(point.day)
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Daily Exercise Plans")
                            .font(.headline)
                            .padding(.leading)

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(TrendCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        ForEach(filteredPlans) { plan in
                            VStack(alignment: .leading) {
                                Text(plan.title)
                                    .font(.headline)
                                Text(plan.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    Text(motivationalQuotes.randomElement() ?? "Stay Healthy!")
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .padding()
            }
            .onAppear {
                HealthManager.shared.requestAuthorization { success in
                    healthAuth = success
                    if success {
                        HealthManager.shared.fetchSteps { steps in
                            appState.steps = Int(steps)
                        }
                    }
                }
            }
        }
    }

    // Sample trend data
    let trendData: [TrendDataPoint] = [
        .init(day: "Mon", steps: 6200, water: 1500),
        .init(day: "Tue", steps: 8700, water: 2000),
        .init(day: "Wed", steps: 4400, water: 1700),
        .init(day: "Thu", steps: 9600, water: 2100),
        .init(day: "Fri", steps: 11000, water: 2300),
        .init(day: "Sat", steps: 7000, water: 1600),
        .init(day: "Sun", steps: 5300, water: 1900)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Trends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(radius: 10)

                if healthAuth {
                    Text("Today's Steps: \(appState.steps)")
                        .font(.title2)
                        .foregroundColor(.pink)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    Button("Connect Health Progress") {
                        HealthManager.shared.requestAuthorization { success in
                            healthAuth = success
                            if success {
                                HealthManager.shared.fetchSteps { steps in
                                    appState.steps = Int(steps)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }

                VStack(alignment: .leading) {
                    Text("Weekly Step Trend")
                        .font(.headline)
                        .padding(.leading)

                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(trendData) { point in
                            VStack {
                                Text("\(point.steps)")
                                    .font(.caption)
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.pink)
                                    .frame(width: 20, height: CGFloat(point.steps) / 100)
                                Text(point.day)
                                    .font(.caption2)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }

                VStack(alignment: .leading) {
                    Text("Weekly Water Intake")
                        .font(.headline)
                        .padding(.leading)

                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(trendData) { point in
                            VStack {
                                Text("\(point.water)ml")
                                    .font(.caption)
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue)
                                    .frame(width: 20, height: CGFloat(point.water) / 10)
                                Text(point.day)
                                    .font(.caption2)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }

                Text(motivationalQuotes.randomElement() ?? "Stay Healthy!")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
            .padding()
        }
        .onAppear {
            HealthManager.shared.requestAuthorization { success in
                healthAuth = success
                if success {
                    HealthManager.shared.fetchSteps { steps in
                        appState.steps = Int(steps)
                    }
                }
            }
        }
    }
}
func generateFakeCompletions() -> [DailyCompletion] {
    var data: [DailyCompletion] = []
    let today = Calendar.current.startOfDay(for: Date())
    for i in 0..<49 {
        if let date = Calendar.current.date(byAdding: .day, value: -i, to: today) {
            data.append(DailyCompletion(date: date, completed: Bool.random()))
        }
    }
    return data.reversed()
}

func saveCompletions(_ completions: [DailyCompletion]) {
    if let encoded = try? JSONEncoder().encode(completions) {
        UserDefaults.standard.set(encoded, forKey: "dailyCompletions")
    }
}

func loadCompletions() -> [DailyCompletion] {
    if let data = UserDefaults.standard.data(forKey: "dailyCompletions"),
       let decoded = try? JSONDecoder().decode([DailyCompletion].self, from: data) {
        return decoded
    } else {
        return generateFakeCompletions()
    }
}
