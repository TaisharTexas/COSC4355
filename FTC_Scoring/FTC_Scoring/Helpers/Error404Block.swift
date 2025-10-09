//
//  Error404Page.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct Error404Block: View {
    var pageName: String = "This Section"
    var message: String = "Under Construction"
    var size: PlaceholderSize = .medium
    
    enum PlaceholderSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 100
            case .large: return 140
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 42
            case .large: return 56
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 20
            case .large: return 28
            }
        }
    }
    
    var body: some View {
        VStack(spacing: size.spacing) {
            // 404 Icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: size.iconSize, height: size.iconSize)
                
                Text("404")
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(Color("ftc_orange"))
            }
            
            VStack(spacing: 6) {
                Text(pageName)
                    .font(size == .small ? .headline : .title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(size == .small ? .caption : .body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Optional decoration dots
            HStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 4)
        }
        .padding()
    }
}

#Preview {
    Error404Block()
}
