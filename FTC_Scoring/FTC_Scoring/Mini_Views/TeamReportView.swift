//
//  TeamReportView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/26/25.
//

import SwiftUI

struct SessionItem: Identifiable {
    let id = UUID()
    let title: String
    var isIncluded: Bool
}

struct TeamReportView: View{
    
    @State private var sessions = [
        SessionItem(title: "9.20.25 Champ Practice runs", isIncluded: true),
        SessionItem(title: "9.19.25 test runs", isIncluded: false),
        SessionItem(title: "9.15.25 Practices", isIncluded: true),
        SessionItem(title: "9.14.25 Practices", isIncluded: true),
        SessionItem(title: "testing drivetrain with turret", isIncluded: false)
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Team Number:")
                .font(.caption)
            Text("8668")
                .font(.title)
        }
        .padding(.horizontal)
        
        Divider()
        
        HStack {
            Image(systemName: "pencil")
                .foregroundColor(.primary)
                .font(.title3)
            
            Text("Session")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("Include")
                .font(.title2)
                .fontWeight(.semibold)
        }//: end Hstack
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        
        ScrollView{
            VStack(spacing: 0) {
                ForEach(sessions.indices, id: \.self) { index in
                    HStack {
                        Text(sessions[index].title)
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $sessions[index].isIncluded)
                            .labelsHidden()
                            .tint(.orange)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    
                    if index < sessions.count - 1 {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }//: end Vstack
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()
        }//: end scroll view
        
    }
}

