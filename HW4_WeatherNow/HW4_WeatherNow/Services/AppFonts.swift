//
//  AppFonts.swift
//  HW4_WeatherNow
//
//  Created by Andrew Lee on 10/18/25.
//

import SwiftUI

enum AppFont {
        // Super Big Header
        case display
        // Regular Headers
        case largeTitle
        case title
        case title2
        case title3
        // Body stuff
        case headline
        case body
        case callout
        
        // Labels
        case subheadline
        case footnote
        case caption
        case caption2
        
        // Misc
        case temperature      // Large temperature display
        case temperatureSmall // Card temperature
        case coordinates      // lat/long display
    
    var font: Font {
        switch self {
        case .display:
            return .custom("Avenir Next", size: 48).weight(.bold)
        case .largeTitle:
            return .custom("Avenir Next", size: 34).weight(.bold)
        case .title:
            return .custom("Avenir Next", size: 28).weight(.semibold)
        case .title2:
            return .custom("Avenir Next", size: 22).weight(.semibold)
        case .title3:
            return .custom("Avenir Next", size: 20).weight(.semibold)
        case .headline:
            return .custom("Avenir Next", size: 17).weight(.semibold)
        case .body:
            return .custom("Avenir Next", size: 17).weight(.regular)
        case .callout:
            return .custom("Avenir Next", size: 16).weight(.medium)
        case .subheadline:
            return .custom("Avenir Next", size: 15).weight(.regular)
        case .footnote:
            return .custom("Avenir Next", size: 13).weight(.regular)
        case .caption:
            return .custom("Avenir Next", size: 12).weight(.regular)
        case .caption2:
            return .custom("Avenir Next", size: 11).weight(.regular)
        case .temperature:
            return .custom("Avenir Next", size: 60).weight(.thin)
        case .temperatureSmall:
            return .custom("Avenir Next", size: 28).weight(.semibold)
        case .coordinates:
            return .custom("Menlo", size: 11).weight(.regular)
        }
    }
}

extension View {
    func appFont(_ style: AppFont) -> some View {
        self.font(style.font)
    }
}
