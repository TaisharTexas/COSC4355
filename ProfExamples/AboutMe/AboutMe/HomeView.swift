//
//  HomeView.swift
//  AboutMe
//
//  Created by Ioannis Pavlidis on 9/14/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("All About")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Image(information.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(40)
            
            Text(information.name)
                .font(.title)
                
                
                
                
        }
    }
}

#Preview {
    HomeView()
}
