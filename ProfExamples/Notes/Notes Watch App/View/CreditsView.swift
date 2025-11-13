//
//  CreditsView.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

import SwiftUI

struct CreditsView: View {
    // MARK: - PROPERTY
    
    
    // MARK: - BODY
    
    var body: some View {
        VStack(spacing: 3) {
            // PROFILE IMAGE
            Image("Instructor")
                .resizable()
                .scaledToFit()
                // Gives this view a higher claim on available space than its siblings (default priority is 0). Practical effect: in a tight HStack/VStack, SwiftUI will try harder to give the image the room it “wants” before compressing it or truncating neighboring views.
                .layoutPriority(1)
            // HEADER
            HeaderView(title: "Credits")
            
            // CONTENT
            Text("Ioannis Pavlidis")
                .foregroundColor(.primary)
                .fontWeight(.bold)
            
            Text("Instructor")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fontWeight(.light)
        } //: VSTACK
    }
}

#Preview {
    CreditsView()
}
