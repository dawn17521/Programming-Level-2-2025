//
//  ContentView.swift
//  Weather_Report
//
//  Created by Harry Feng - 448 on 2025-02-27.
//

import SwiftUI

struct ContentView: View {
    @State private var temperature: String = "20"
    @State private var weatherMessage: String = ""
    
   
    var body: some View {
        VStack {
            TextField("Enter temperature", text: $temperature)
                .padding()
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                
                if let temp = Int(temperature) {
                  
                    switch temp {
                    case Int.min..<0:
                        weatherMessage = "It's freezing!"
                    case 0..<15:
                        weatherMessage = "It's cold!"
                  
               
                    default:
                        weatherMessage = "It's extremely hot!"
                    }
                }
            }) {
                Text("Check Weather")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(weatherMessage)
                .font(.title2)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
