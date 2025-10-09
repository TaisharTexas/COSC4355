import Foundation

struct QuizOption: Identifiable {
    let id = UUID()
    let record: BreedRecord
}

struct QuizState {
    var options: [QuizOption] = []
    var correctKey: String = ""
    var photoURL: URL?
    var status: Status = .idle
    var pickedKey: String = ""

    enum Status { case idle, loading, question, correct, wrong, error }
}
