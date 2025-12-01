//
//  SettingsView.swift
//  Exam3_Lee_Andrew Watch App
//
//  Created by Andrew Lee on 11/20/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("recentLimit") var recentLimit: Int = 5
    @StateObject private var store = HabitStore()
    
    
    var body: some View {
        VStack(alignment: .center){
            Text("Adjust the number of items to display in recents:")
            Divider()
            HStack{
                Button{
                    if(recentLimit > 3){
                        recentLimit -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.title)
                }
                .padding(.horizontal)
                
                Text("\(recentLimit)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Button{
                    if(recentLimit < 10){
                        recentLimit += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .padding(.horizontal)
            }
            .padding()
            
        }
    }
}

#Preview {
    SettingsView(recentLimit: 7)
}
