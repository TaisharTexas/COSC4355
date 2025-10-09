//
//  TeamView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct TeamView: View {
    var body: some View {
        ScrollView{
            VStack(spacing:20){
                Error404Block(
                    pageName: "Team Data",
                    message: "Page coming soon",
                    size: .large
                )
            }
        }
        .navigationTitle("Event Data")
    }
}

#Preview {
    TeamView()
}
