//
//  TextView.swift
//  Greetings2
//
//  Created by Ioannis Pavlidis on 8/27/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b)
            return
        }
        self = .black
    }
}



struct TextView: View {
        let text: String
        let fgColor: Color
        let bgColor: Color
        let shadowColor: Color
    
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundStyle(fgColor)
            .padding()
            .background(bgColor)
            .cornerRadius(20)
            .shadow(color: shadowColor, radius: 5, x: 5, y: 5)
        
    }
}

#Preview {
    VStack(alignment: .leading)
    {
        TextView(
                    text: "Hello there!",
                    fgColor: Color(hex: "3338A0"),
                    bgColor: Color(hex: "FCC61D"),
                    shadowColor:
                        Color(hex: "C59560")
                )
        
        TextView(text: "Hi!",
                 fgColor: Color(hex: "3338A0"),
                 bgColor: Color(hex: "FCC61D"),
                 shadowColor:
                     Color(hex: "C59560")
                 )
        
        TextView(text: "How are you?",
                 fgColor: Color(hex: "FCC61D"),
                 bgColor: Color(hex: "3338A0"),
                 shadowColor:
                     Color(hex: "C59560")
                 )
        
        TextView(text: "I am fine.",
                 fgColor: Color(hex: "FCC61D"),
                 bgColor: Color(hex: "3338A0"),
                 shadowColor:
                     Color(hex: "C59560")
                 )
    }
             
}
