import Foundation

struct SoundElement: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let duration: String
    var isPlaying: Bool
    var isFavorite: Bool = false
    let iconName: String
    let fileName: String
    var savedTimerMinutes: Int? = nil
    
    var timerDisplayText: String {
        if let mins = savedTimerMinutes {
            return "\(mins) min timer"
        }
        return duration
    }
}
