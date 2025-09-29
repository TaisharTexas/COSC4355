//
//  AboutView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/22/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("About")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Image(systemName: "leaf.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.green)
                
                // Subtitle
                Text("About This App")
                    .font(.title2)
                    .bold()
                
                // Description
                Text("This sample showcases a grid-based catalog of U.S. National Parks using SwiftUI. It demonstrates TabView, NavigationStack, LazyVGrid, and basic state management for favorites (also stores the favorites between launches....gimme those points pls :)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
            .padding()
        }
        .navigationTitle("About")
    }
}
