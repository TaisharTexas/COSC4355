import SwiftUI

struct QuizView: View {
    @EnvironmentObject var service: DogAPIService
    @EnvironmentObject var favorites: FavoritesStore

    @State private var quiz = QuizState()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                switch quiz.status {
                case .idle:
                    Button(action: startQuiz) {
                        Label("New quiz", systemImage: "arrow.triangle.2.circlepath")
                    }.buttonStyle(.borderedProminent)
                    Text("We'll fetch a random photo for a hidden breed and give you four choices.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                case .loading:
                    ProgressView("Loading quiz image…")
                case .question, .correct, .wrong:
                    AsyncImageView(url: quiz.photoURL)
                        .frame(maxWidth: .infinity, maxHeight: 360)

                    // Choices (do NOT disable buttons; show feedback with color and checkmarks)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(quiz.options) { opt in
                            Button {
                                if quiz.status == .question {
                                    answer(opt: opt)
                                }
                            } label: {
                                HStack {
                                    Text(opt.record.label).frame(maxWidth: .infinity, alignment: .leading)
                                    if quiz.status != .question {
                                        if opt.record.key == quiz.correctKey {
                                            Image(systemName: "checkmark.circle.fill")
                                        } else if opt.record.key == quiz.pickedKey {
                                            Image(systemName: "xmark.circle")
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(tint(for: opt))
                        }
                    }

                    // Result banner
                    if quiz.status == .correct {
                        Label("Correct!", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else if quiz.status == .wrong {
                        Label("Not quite — highlighted answer is correct.", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }

                    HStack {
                        Button("Next", action: startQuiz).buttonStyle(.borderedProminent)
                        Button {
                            favorites.toggle(quiz.photoURL)
                        } label: {
                            Label(favorites.contains(quiz.photoURL) ? "Unfavorite photo" : "Save this photo",
                                  systemImage: favorites.contains(quiz.photoURL) ? "heart.fill" : "heart")
                        }.buttonStyle(.bordered)
                    }
                case .error:
                    Text("Could not load quiz. Try again.")
                    Button("Retry", action: startQuiz).buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Guess the Breed")
        }
    }

    func startQuiz() {
        Task {
            // Ensure we have breeds
            if service.allBreeds.count < 4 {
                await service.loadBreeds()
            }
            guard service.allBreeds.count >= 4 else { quiz.status = .error; return }

            quiz.status = .loading
            let options = Array(service.allBreeds.shuffled().prefix(4)).map { QuizOption(record: $0) }
            let correct = options.randomElement()!.record
            // Fetch image for correct
            await service.fetchRandom(breed: correct.breed, sub: correct.subBreed)

            quiz = QuizState(
                options: options,
                correctKey: correct.key,
                photoURL: service.lastImageURL,
                status: .question,
                pickedKey: ""
            )
        }
    }

    func answer(opt: QuizOption) {
        quiz.pickedKey = opt.record.key
        if opt.record.key == quiz.correctKey {
            quiz.status = .correct
        } else {
            quiz.status = .wrong
        }
    }

    func tint(for opt: QuizOption) -> Color {
        switch quiz.status {
        case .correct:
            return opt.record.key == quiz.correctKey ? .green : .gray
        case .wrong:
            if opt.record.key == quiz.correctKey { return .green }
            if opt.record.key == quiz.pickedKey { return .red }
            return .gray
        default:
            return .accentColor
        }
    }
}
