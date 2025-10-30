//
//  SelectEvent.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/28/25.
//

import SwiftUI

/**
 Need to actually build this to set a state variable to the ID of the chosen event
 */

struct EventItem: Identifiable{
    let id = UUID()
    let eventName: String
}

/**
 TEMP data 
 */
let events = [
    EventItem(eventName: "World Champs 2025"),
    EventItem(eventName: "Texas South State Regionals 2025"),
    EventItem(eventName: "SE Texas Invitational Qualifier"),
    EventItem(eventName: "Hoston League Championship 2025")
]

struct SelectEvent: View{

    var body: some View{
        VStack(spacing: 0) {
            
            Text("~~ Super temp view ~~")
                .padding()
            
            ForEach(events.indices, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading){
                        Text(events[index].eventName)
                            .font(.title)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }//: end vstack
                    Spacer()
                    Button("Select", action: {
                        print("selected \(events[index].eventName) to query")
                    })
                    .buttonStyle(.glassProminent)
                    
                }//: end hstack - teams at event
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                if index < events.count - 1 {
                    Divider()
                        .padding(.leading, 20)
                }
            }
        }//: end Vstack
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
        
        Spacer()
    }
}

#Preview {
    SelectEvent()
}
