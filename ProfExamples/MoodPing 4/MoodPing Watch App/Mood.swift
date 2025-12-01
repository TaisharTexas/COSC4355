import Foundation

enum Mood: Int, CaseIterable, Identifiable, Codable {
    case sad, meh, ok, happy
    var id: Int { rawValue }
    var emoji: String { ["😞","😐","🙂","😀"][rawValue] }
    var label: String { ["Sad","Meh","Ok","Happy"][rawValue] }
}
