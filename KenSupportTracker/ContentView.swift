//
//  ContentView.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)

                Text("IT Support Tickets")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create and track workplace IT issues.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("SupportDesk")
        }
    }
}
