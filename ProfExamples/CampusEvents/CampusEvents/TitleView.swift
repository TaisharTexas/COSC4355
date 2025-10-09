//
//  TitleView.swift
//  CampusEvents
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct TitleView: View {
    @State private var isRotated = false
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Campus Events")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("What's Happening this week")
                    .font(.title3)
                    .fontWeight(.light)
            }
            
            Spacer()
            
            Circle()
                .strokeBorder(AngularGradient.init(gradient: Gradient(colors: [.red, .teal]), center: .center), lineWidth: 15)
                .rotationEffect(Angle(degrees: isRotated ? 360 : 0))
                .onTapGesture {
                    withAnimation(.linear(duration: 1)) {
                        self.isRotated.toggle()
                    }
                }
                .frame(width: 80, height: 80)
        }
        .padding()
    }
}

#Preview {
    TitleView()
}
