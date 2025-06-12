//
//  ContentView.swift
//  OnBoardingFlow
//
//  Created by Harry Feng - 448 on 2025-03-10.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        TabView {
            WelcomePage()
            FeatureCard()
        }
        .tabViewStyle(.page)
    }
}


#Preview {
    ContentView()
}
