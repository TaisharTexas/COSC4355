//
//  EventView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct TeamItem: Identifiable{
    let id = UUID()
    let teamName: String
    let teamNum: String
    var rating: CompatibilityRating = .Good
}

enum CompatibilityRating{
    case Poor, Good, Ideal
}

struct EventView: View {
    
    @StateObject private var matchData = MatchData()
    
    
    /**
     TEMP
     */
    @State private var teams = [
        TeamItem(teamName: "Thunderbolts", teamNum: "18140", rating: .Good),
        TeamItem(teamName: "Dark Matter",teamNum: "9730", rating: .Poor),
        TeamItem(teamName: "Error 404",teamNum: "17355", rating: .Ideal),
        TeamItem(teamName: "Green Machine",teamNum: "29150", rating: .Poor),
        TeamItem(teamName: "Ironclad",teamNum: "8080", rating: .Ideal)
        
    ]
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Text("Selected Event:")
                    .font(.title2)
                    .foregroundColor(.ftcOrange)
                HStack{
                    Text("Worlds Championship 2025")
                        .font(.title)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                    Spacer()
                    NavigationLink(destination: SelectEvent()){
                        Text("Select Event")
                            .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(minWidth: 100, minHeight: 40)
                                .background(Color.ftcOrange)
                                .cornerRadius(20)
                    }
                    .padding()
                    
                    
                }
            }
            .padding()
            
            ScrollView{
                VStack(spacing: 0) {
                    ForEach(teams.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading){
                                Text(teams[index].teamNum)
                                    .font(.title)
                                    .foregroundColor(.primary)
                                Text(teams[index].teamName)
                                    .font(.title2.bold())
                                    .foregroundColor(.ftcOrange)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }//: end vstack
                            
                            Spacer()
                            
                            let ratingStr = String(describing: teams[index].rating)
                            Text(ratingStr)
                                .font(.title2)
                                .foregroundColor(.primary)
                            NavigationLink(destination: TeamAnalysisView_Event(
                                teamNum: teams[index].teamNum,
                                teamName: teams[index].teamName
                            )) {
                                Image(systemName: "chevron.compact.right")
                                    .foregroundColor(.ftcOrange)
                                    .font(.system(size: 30))
                            }
                            .padding(.horizontal, 5)
                            
                            
                        }//: end hstack - teams at event
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        
                        if index < teams.count - 1 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }//: end Vstack
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
            }//: end scroll view
            
            Spacer()
            
            
        }
        
    }
}



#Preview {
    EventView()
}
