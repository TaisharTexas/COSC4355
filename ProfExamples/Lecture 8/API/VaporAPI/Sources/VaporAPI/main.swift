import Vapor

// Simple dog breed model
struct DogBreed: Content {
    let id: Int
    let name: String
    let origin: String
    let imageUrl: String
    let description: String
}

// Sample data - just 2 dog breeds
var dogBreeds: [DogBreed] = [
    DogBreed(
        id: 1, 
        name: "Golden Retriever", 
        origin: "Scotland", 
        imageUrl: "https://example.com/golden.jpg", 
        description: "Friendly and intelligent dog breed"
    ),
    DogBreed(
        id: 2, 
        name: "German Shepherd", 
        origin: "Germany", 
        imageUrl: "https://example.com/german.jpg", 
        description: "Loyal and protective working dog"
    )
]

func routes(_ app: Application) throws {
    // Get all dog breeds
    app.get("dogs") { req -> [DogBreed] in
        return dogBreeds
    }
    
    // Get a specific dog breed by ID
    app.get("dogs", ":id") { req -> DogBreed in
        guard let idString = req.parameters.get("id"),
              let id = Int(idString),
              let dog = dogBreeds.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Dog breed not found")
        }
        return dog
    }
}

@main
struct VaporAPIApp {
    static func main() async throws {
        let app = Application(.development)
        defer { app.shutdown() }
        
        try routes(app)
        
        try await app.run()
    }
}
