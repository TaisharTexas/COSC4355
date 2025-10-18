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
            //: the info that stays in the cache is put up here
            VStack(alignment: .leading) {
                Text(city.name)
                    .appFont(.largeTitle)
                    .foregroundColor(Color.wTextHeader)
                Text(city.country)
                    .appFont(.subheadline)
                    .foregroundColor(Color.wTextSubHeader)
                Text("\(city.latitude), \(city.longitude)")
                    .appFont(.footnote)
                    .foregroundColor(.wTextBody)
            }//: end Vstack
            Spacer()
            
            // loading circle
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .scaleEffect(1.2)
                    .tint(.wTextHeader)
            }
        }//: end Hstack
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
