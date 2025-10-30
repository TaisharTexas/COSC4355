//
//  TeamAnalysisView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/26/25.
//

import SwiftUI

/**
 Need to redefine button style to use orange
 
 Add ranking points calc to stats. distingush between small and large triangle scores

 */

/**
 Probably also temp design
 */
private struct DataCard: View {
    let title: String
    let data: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(data)
                .font(.title.bold())
                .foregroundColor(.ftcOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.ftcGray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}//: end DataCard element

struct TeamAnalysisView_Self: View{
    
    var body: some View {

            
        Divider()
        
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                DataCard(title: "Avg Auto", data: "23")
                DataCard(title: "Avg Tele", data: "69")
                DataCard(title: "Avg End", data: "15")
                DataCard(title: "Med Score", data: "72")
            }//: end Hstack (data cards)
            HStack(spacing: 12){
                DataCard(title: "Strengths", data: "placeholder")
                DataCard(title: "Weaknesses", data: "placeholder")
            }
            
            // Field map
            Image("ftc_map")
                .resizable()
                .scaledToFit()
                .background(Color(.systemGray5))
                .cornerRadius(12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
        .padding()
    }//: end body view

}

#Preview{
    TeamAnalysisView_Self()
}
