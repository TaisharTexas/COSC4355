//
//  ScoreTele.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct ScoreTele: View{
    @ObservedObject var matchData: MatchData
    
    var body: some View{
        
        HStack{
            VStack{
                Text("Overflow Artifacts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack{
                    Button(action: { if matchData.overflowArtifactsTele > 0 { matchData.overflowArtifactsTele -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.overflowArtifactsTele)")
                        .font(.title2)
                        .frame(width: 25)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.overflowArtifactsTele += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                }
            }//: end overflow artifacts Vstack
            Spacer()
            VStack{
                Text("Classified Artifacts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack{
                    Button(action: { if matchData.classifiedArtifactsTele > 0 { matchData.classifiedArtifactsTele -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.classifiedArtifactsTele)")
                        .font(.title2)
                        .frame(width: 25)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.classifiedArtifactsTele += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                }
            }//: end classified artifacts Vstack
            Spacer()
            VStack{
                Text("Depot Artifacts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack{
                    Button(action: { if matchData.depotArtifactsTele > 0 { matchData.classifiedArtifactsTele -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.depotArtifactsTele)")
                        .font(.title2)
                        .frame(width: 25)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.depotArtifactsTele += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                }
            }//: end classified artifacts Vstack
        }//: end artifact counter Hstack
        .padding(.horizontal)
        
        ScrollView{
            VStack(spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("Gate \(index + 1)")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        
                        
                        HStack(spacing: 20) {
                            // Green Ball Button
                            Button(action: {
                                // Toggle: if already green, set to none; otherwise set to green
                                matchData.gateStatesTele[index] =
                                matchData.gateStatesTele[index] == .green ? .none : .green
                            }) {
                                Image(systemName: matchData.gateStatesTele[index] == .green ? "tennisball.fill" : "tennisball")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                            
                            // Purple Ball Button
                            Button(action: {
                                // Toggle: if already purple, set to none; otherwise set to purple
                                matchData.gateStatesTele[index] =
                                matchData.gateStatesTele[index] == .purple ? .none : .purple
                            }) {
                                Image(systemName: matchData.gateStatesTele[index] == .purple ? "tennisball.fill" : "tennisball")
                                    .font(.system(size: 40))
                                    .foregroundColor(.purple)
                            }
                        }//: end hstack
                        
                        Spacer()

                    }
                    .padding(.horizontal)
                }
                
            }
        }//: end gate toggle ScrollView
    }
}
