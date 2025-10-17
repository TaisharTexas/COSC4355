//
//  WeatherCardLoading.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/16/25.
//

import SwiftUI

/**
 This is the way the favorite card looks when its still loading content from the API
 It's all yoinked from canine explorer and adjusted to work for my cards
 */

struct FavCity_DetailsLoadingView: View {
    let city: City
    let isLoading: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(city.name)
                    .font(.largeTitle)
                    .foregroundColor(Color.wTextHeader)
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(Color.wTextSubHeader)
                Text("\(city.latitude), \(city.longitude)")
                    .font(.footnote)
                    .foregroundColor(.wTextBody)
            }
            Spacer()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .scaleEffect(1.2)
                    .tint(.wTextHeader)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
        )
        .cornerRadius(12)
    }
}
