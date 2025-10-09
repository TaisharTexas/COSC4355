//
//  TitleView.swift
//  Greetings2
//
//  Created by Ioannis Pavlidis on 8/27/25.
//

import SwiftUI

struct TitleView: View {
    @State private var isRotated = false
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Greetings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Circle()
                .strokeBorder(AngularGradient.init(gradient: Gradient(colors: [.red, .blue]), center: .center), lineWidth: 15)
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
