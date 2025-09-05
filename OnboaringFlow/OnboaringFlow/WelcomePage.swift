//
//  WelcomePage.swift
//  OnboaringFlow
//
//  Created by Andrew Lee on 9/4/25.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.purple)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.tint)
            
                Image(systemName: "person.3.sequence")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
                    
                
            }
            
            Text("Welcome to My App")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)
            Text("Description text")
                .font(.title2)
        }
        .padding()
    }
}

#Preview {
    WelcomePage()
}
