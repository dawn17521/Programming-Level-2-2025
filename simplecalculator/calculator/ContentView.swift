//
//  ContentView.swift
//  calculator
//
//  Created by Harry Feng - 448 on 2025-02-18.
//

import SwiftUI

struct ContentView: View {
    @State private var numberOne: Int = 0
    @State private var numberTwo: Int = 0
    @State private var result: Int = 0
    
    // Define a function to add number one and two together
    //store the sum in the result variable
    func calculateSum() {
        result = numberOne + numberTwo
    }
    
    var body: some View {
        VStack {
            //Label
            Text("number 1:")
            
            TextField("Enter first number", value:  $numberOne, format: .number)
                .textFieldStyle(.roundedBorder)
                .padding()
                .shadow(radius:10)
            
            TextField("Enter first number", value:  $numberTwo, format: .number)
                .textFieldStyle(.roundedBorder)
                .padding()
                .shadow(radius:10)
            
            Button(action: calculateSum) {
                Text("calculateSum")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Result:  \(result)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
