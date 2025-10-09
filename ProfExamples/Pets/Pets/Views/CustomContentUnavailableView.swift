//
//  CustomContentUnavailableView.swift
//  Pets
//
//  Created by Ioannis Pavlidis on 9/15/25.
//

import SwiftUI

struct CustomContentUnavailableView: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        // Apple's built-in empty state layout
        ContentUnavailableView {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96)
            
            Text(title)
                .font(.title)
        } description: {
            Text(description)
        }
        .foregroundStyle(.tertiary)
    }
}

#Preview {
    CustomContentUnavailableView(icon: "dog.circle", title: "No pets", description: "Add a new pet to get started")
}
