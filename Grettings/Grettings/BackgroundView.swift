//
//  BackgroundView.swift
//  Greetings2
//
//  Created by Ioannis Pavlidis on 8/27/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
