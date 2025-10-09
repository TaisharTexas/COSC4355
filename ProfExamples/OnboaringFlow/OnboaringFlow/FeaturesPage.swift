//
//  FeaturesPage.swift
//  OnboaringFlow
//
//  Created by Andrew Lee on 9/4/25.
//

import SwiftUI

struct FeaturesPage: View {
    var body: some View {
        VStack{
            
            Text("Features")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom)
                .padding(.top, 100)
            
            FeatureCard(
                iconName: "person.2.crop.square.stack.fill",
                description: "A helpful description of the feature"
            )
            FeatureCard(
                iconName: "quote.bubble.fill",
                description: "short summary of this other feature"
            )
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    FeaturesPage()
}
