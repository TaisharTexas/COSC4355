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
                    Button(action: { if matchData.overflowArtifacts > 0 { matchData.overflowArtifacts -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.overflowArtifacts)")
                        .font(.title2)
                        .frame(width: 25)
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
                        .frame(width: 25)
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
            VStack{
                Text("Depot Artifacts")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack{
                    Button(action: { if matchData.depotArtifacts > 0 { matchData.classifiedArtifacts -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 37, height: 37)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.ftcOrange)
                            .cornerRadius(8)
                    }
                    Text("\(matchData.depotArtifacts)")
                        .font(.title2)
                        .frame(width: 25)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button(action: { matchData.depotArtifacts += 1 }) {
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
                        Text("Gate \(index + 1)")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { matchData.gateStatesTele[index] = .green }) {
                                Text("Green")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesTele[index] == .green ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesTele[index] == .green ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { matchData.gateStatesTele[index] = .purple }) {
                                Text("Purple")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesTele[index] == .purple ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesTele[index] == .purple ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { matchData.gateStatesTele[index] = .none }) {
                                Text("None")
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(matchData.gateStatesTele[index] == .none ? Color.orange : Color.gray.opacity(0.2))
                                    .foregroundColor(matchData.gateStatesTele[index] == .none ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
            }
        }//: end gate toggle ScrollView
    }
}
