//
//  ContentView.swift
//  API_Generator
//
//  Created by Mert on 10/16/25.
//

import SwiftUI

// Simple dog breed model to match our API
struct DogBreed: Codable, Identifiable {
    let id: Int
    let name: String
    let origin: String
    let imageUrl: String
    let description: String
}

struct ContentView: View {
    @State private var dogBreeds: [DogBreed] = []
    @State private var isLoading = false
    @State private var statusMessage = "Tap 'Load Dogs' to fetch from API"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Dog Breeds API")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(statusMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if isLoading {
                    ProgressView("Loading...")
                }
                
                Button("Load Dogs") {
                    loadDogs()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                if !dogBreeds.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dog Breeds (\(dogBreeds.count))")
                            .font(.headline)
                        
                        ForEach(dogBreeds) { dog in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(dog.name)
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                
                                Text("Origin: \(dog.origin)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Text(dog.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func loadDogs() {
        isLoading = true
        statusMessage = "Loading dogs..."
        
        guard let url = URL(string: "http://localhost:8080/dogs") else {
            statusMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    statusMessage = "No data received"
                    return
                }
                
                do {
                    dogBreeds = try JSONDecoder().decode([DogBreed].self, from: data)
                    statusMessage = "Loaded \(dogBreeds.count) dog breeds successfully!"
                } catch {
                    statusMessage = "Failed to decode dogs: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
