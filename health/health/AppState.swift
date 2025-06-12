//
//  AppState.swift
//  health
//
//  Created by Harry Feng - 448 on 2025-05-27.
//

import Foundation

class AppState: ObservableObject {
    @Published var sharedPlans: [ExercisePlan] = loadPlans() {
        didSet { savePlans() }
    }
    
    private static func loadPlans() -> [ExercisePlan] {
        if let data = UserDefaults.standard.data(forKey: "sharedPlans"),
           let decoded = try? JSONDecoder().decode([ExercisePlan].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func savePlans() {
        if let encoded = try? JSONEncoder().encode(sharedPlans) {
            UserDefaults.standard.set(encoded, forKey: "sharedPlans")
        }
    }
}
