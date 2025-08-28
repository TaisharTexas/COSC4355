//
//  EventCardView.swift
//  CampusEvents
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct EventCardView: View{
    let event: EventItemModel

    var body: some View {
        HStack {
            //accent circle
            Circle()
                .fill(event.accent)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading){
                Text(event.title)
                Text(event.time)
                Text(event.location)
            }
            .background(Color(event.fill))
            .padding(10)
            .shadow(color: Color(event.shadow), radius: 10, x: 5, y: 5)
            .cornerRadius(10)

        }
        .padding()
    }
    
}

let events = [
    EventItemModel(
        title: "Class Lecture",
        location: "SEC 103",
        time: "Thu, 8:30a-9:50a",
        accent: .teal,
        fill: .gray,
        shadow: .teal
    ),
    EventItemModel(
        title: "Class Lecture",
        location: "SEC 103",
        time: "Tue, 8:30a-9:50a",
        accent: .teal,
        fill: .gray,
        shadow: .teal
    ),
    EventItemModel(
        title: "Professor Office Hours",
        location: "Teams Meeting",
        time: "Wed/Fri, 10a-11a",
        accent: .teal,
        fill: .gray,
        shadow: .teal
    ),
    EventItemModel(
        title: "TA Office Hours",
        location: "Teams or Library (on request)",
        time: "Tue/Thu/Fri from 4p to 5p",
        accent: .teal,
        fill: .gray,
        shadow: .teal
    ),
    EventItemModel(
        title: "Exam 1",
        location: "SEC 103",
        time: "Feb 9th, 8:30a-9:50a",
        accent: .teal,
        fill: .gray,
        shadow: .teal
    )
]

#Preview {
    ForEach(events) { event in
        EventCardView(event: event)
    }
}
