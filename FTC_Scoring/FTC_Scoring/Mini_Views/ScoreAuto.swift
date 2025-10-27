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
                    Button(action: { if matchData.overflowArtifacts > 0 { matchData.overflowArtifacts -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.overflowArtifacts)")
                        .font(.title2)
                        .frame(width: 20)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.overflowArtifacts += 1 }) {
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
                    Button(action: { if matchData.classifiedArtifacts > 0 { matchData.classifiedArtifacts -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.classifiedArtifacts)")
                        .font(.title2)
                        .frame(width: 20)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.classifiedArtifacts += 1 }) {
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
                ForEach(0..<8, id: \.self) { index in
                    HStack {
                        Text("Gate \(index + 1)")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { matchData.gateStatesAuto[index] = .green }) {
                                Text("Green")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesAuto[index] == .green ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesAuto[index] == .green ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { matchData.gateStatesAuto[index] = .purple }) {
                                Text("Purple")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesAuto[index] == .purple ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesAuto[index] == .purple ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { matchData.gateStatesAuto[index] = .none }) {
                                Text("None")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesAuto[index] == .none ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesAuto[index] == .none ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
            }
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
