//
//  AboutView.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
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
                
                Image(systemName: "pawprint.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                
                // Subtitle
                Text("PetCare Companion helps you explore different pets and save your favorites")
                    .font(.title2)
                    .bold()
                
                // Description
                Text("Built with SwiftUI: grids, navigation stacks, and tab views.")
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
