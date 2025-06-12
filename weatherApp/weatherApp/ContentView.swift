//
//  ContentView.swift
//  weatherApp
//
//  Created by Harry Feng - 448 on 2025-02-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var WeatherApp = Weather()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select City", selection: $WeatherApp.selectedCity) {
                    ForEach(WeatherApp.cities, id: \..self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(WeatherApp.weatherData, id: \..day) { forecast in
                            DayForecastView(forecast: forecast)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weather App")
            .onAppear {
                WeatherApp.fetchWeather()
            }
        }
    }
}

struct DayForecastView: View {
    let forecast: DayForecast
    
    var body: some View {
        VStack {
            Text(forecast.day)
                .font(.headline)
                .foregroundStyle(.primary)
            Image(systemName: forecast.Rain ? "cloud.rain.fill" : "sun.max.fill")
                .foregroundStyle(forecast.Rain ? Color.blue : Color.yellow)
                .font(.largeTitle)
                .animation(.easeInOut, value: forecast.Rain)
            Text("High: \(forecast.high)°")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Low: \(forecast.low)°")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 5))
        .padding(.vertical, 5)
    }
}

class Weather: ObservableObject {
    @Published var weatherData: [DayForecast] = []
    @Published var selectedCity: String = "Richmond" {
        didSet { fetchWeather() }
    }
    
    let cities = ["Richmond", "Vancouver"]
    
    func fetchWeather() {
        // Mock Data - Replace with real API call later
        let sampleData = [
            DayForecast(day: "Mon", Rain: Bool.random(), high: Int.random(in: 0...40), low: Int.random(in: 0...25)),
            DayForecast(day: "Tue", Rain: Bool.random(), high: Int.random(in: 0...40), low: Int.random(in: 0...25)),
            DayForecast(day: "Wed", Rain: Bool.random(), high: Int.random(in: 0...40), low: Int.random(in: 0...25)),
            DayForecast(day: "Thu", Rain: Bool.random(), high: Int.random(in: 0...40), low: Int.random(in: 0...25)),
            DayForecast(day: "Fri", Rain: Bool.random(), high: Int.random(in: 0...40), low: Int.random(in: 0...25))
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.weatherData = sampleData
        }
    }
}

struct DayForecast: Identifiable {
    let id = UUID()
    let day: String
    let Rain: Bool
    let high: Int
    let low: Int
}

#Preview {
    ContentView()
}
