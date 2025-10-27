//
//  ScoreEndgame.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct ScoreEndgame: View{
    @ObservedObject var matchData: MatchData
    
    var body: some View{
        VStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { index in
                HStack {
                    Text("Robot \(index + 1) Base")
                        .font(.headline)
                        .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { matchData.robotBaseState[index] = .partial }) {
                            Text("Partial")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .partial ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .partial ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { matchData.robotBaseState[index] = .full }) {
                            Text("Full")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .full ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .full ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { matchData.robotBaseState[index] = .none }) {
                            Text("None")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .none ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .none ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }//: end hstack
                .padding(.horizontal)
            }//: end for loop
            
            Divider()
            
            HStack{
                
                Spacer()
                Button("Save Match", action: {
                    print("save match button pressed")
                    //eventually need to pop up match summary/confirm save button and then save a match record to the memory (non volitile)
                })
                .buttonStyle(.glassProminent)
                Spacer()
            }
            
        }//: end Vstack
    }
}
