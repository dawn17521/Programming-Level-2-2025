//
//  ContentView.swift
//  profilolabel
//
//  Created by Harry Feng - 448 on 2025-01-31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing:20) {
            Image("profilecard")
                .resizable()
                .scaledToFit()
                .frame(width:150,height:150)
                .clipShape(Circle())
                .shadow(radius:10)
            
            Text("welcome Swift Learner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
                }
        .padding()
        
        let birthyear: Int
        birthyear = 2008
        print(birthyear)
    }
}

#Preview {
    ContentView()
}
