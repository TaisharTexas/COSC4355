//
//  MessagesView.swift
//  Greetings2
//
//  Created by Ioannis Pavlidis on 8/27/25.
//


import SwiftUI

struct MessagesView: View {
    let messages: [DataItemModel] = [
        .init(text: "Hello there!",
              fgColor: Color(hex: "3338A0"),
              bgColor: Color(hex: "FCC61D"),
              shadowColor:
                  Color(hex: "C59560"),
             ),
        .init(text: "Hi!",
             fgColor: Color(hex: "FCC61D"),
             bgColor: Color(hex: "3338A0"),
             shadowColor:
                Color(hex: "C59560"),
            ),
        .init(text: "How are you?",
              fgColor: Color(hex: "3338A0"),
              bgColor: Color(hex: "FCC61D"),
              shadowColor:
                Color(hex: "C59560"),
             ),
        .init(text: "I am fine.",
              fgColor: Color(hex: "FCC61D"),
              bgColor: Color(hex: "3338A0"),
              shadowColor:
                Color(hex: "C59560"),
             )
    ]

var body: some View {
    VStack(alignment: .leading) {
        ForEach(messages) {dataItem in TextView(
            text: dataItem.text,
            fgColor: dataItem.fgColor,
            bgColor: dataItem.bgColor,
            shadowColor: dataItem.shadowColor)
        
            Spacer()}
    }
}
}

#Preview {
MessagesView()
}
