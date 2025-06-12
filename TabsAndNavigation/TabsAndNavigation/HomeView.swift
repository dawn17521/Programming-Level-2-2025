//
//  HomeView.swift
//  TabsAndNavigation
//
//  Created by Harry Feng - 448 on 2025-04-07.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {

        NavigationStack {

            List {
 
                NavigationLink(destination: DetailView(title: "Item 1")) {

                    Text("1")

                }

                NavigationLink(destination: DetailView(title: "Item 2")) {

                    Text("2")

                }

            }

            .navigationTitle("Home")

        }

    }

}

struct DetailView: View {
    
    let title: String
    
    var body: some View {
        
        Text("tab\(title)")
        
            .font(.largeTitle)
        
            .padding()
        
    }
}
