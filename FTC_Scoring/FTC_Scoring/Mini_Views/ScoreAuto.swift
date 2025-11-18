//
//  ScoreAuto.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct ScoreAuto: View{
    @ObservedObject var matchData: MatchData
    
    var body: some View{
        HStack{
            Spacer()
            VStack{
                Text("Overflow Artifacts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack{
                    Button(action: { if matchData.overflowArtifactsAuto > 0 { matchData.overflowArtifactsAuto -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.overflowArtifactsAuto)")
                        .font(.title2)
                        .frame(width: 20)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.overflowArtifactsAuto += 1 }) {
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
                    Button(action: { if matchData.classifiedArtifactsAuto > 0 { matchData.classifiedArtifactsAuto -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.classifiedArtifactsAuto)")
                        .font(.title2)
                        .frame(width: 20)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.classifiedArtifactsAuto += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                }
            }//: end classified artifacts Vstack
            Spacer()
        }//: end artifact counter Hstack
        .padding(.horizontal)
        
        
        ScrollView{
            VStack(spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    HStack {
                        
                        Text("Gate \(index + 1)")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        
                        
                        HStack(spacing: 20) {
                            // Green Ball Button
                            Button(action: {
                                // Toggle: if already green, set to none; otherwise set to green
                                matchData.gateStatesAuto[index] =
                                matchData.gateStatesAuto[index] == .green ? .none : .green
                            }) {
                                Image(systemName: matchData.gateStatesAuto[index] == .green ? "tennisball.fill" : "tennisball")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                            
                            // Purple Ball Button
                            Button(action: {
                                // Toggle: if already purple, set to none; otherwise set to purple
                                matchData.gateStatesAuto[index] =
                                matchData.gateStatesAuto[index] == .purple ? .none : .purple
                            }) {
                                Image(systemName: matchData.gateStatesAuto[index] == .purple ? "tennisball.fill" : "tennisball")
                                    .font(.system(size: 40))
                                    .foregroundColor(.purple)
                            }
                        }//: end hstack
                        
                    }
                    .padding(.horizontal)
                }
            }//: end vstack (list of gates)
            
        }//: end gate toggle ScrollView
        
        // Robot Leave Toggles
        HStack(spacing: 40) {
            HStack {
                Text("Robot 1 Leave")
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $matchData.robot1Leave)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .ftcOrange))
            }
            
            HStack {
                Text("Robot 2 Leave")
                    .fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $matchData.robot2Leave)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .ftcOrange))
            }
        }//: end robot leave Hstack
        .padding(.horizontal)
    }
    
}
