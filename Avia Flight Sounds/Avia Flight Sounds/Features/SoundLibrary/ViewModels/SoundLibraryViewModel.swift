import SwiftUI
import Combine

@MainActor
class SoundLibraryViewModel: ObservableObject {
    @Published var sounds: [SoundElement] = [
        SoundElement(title: "Boeing 737 Takeoff", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "takeoff_boeing.mp3"),
        SoundElement(title: "Mountain Wind 3000m", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "wind_mountain.mp3"),
        SoundElement(title: "Drone Flight Buzz", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "drone_buzz.mp3"),
        SoundElement(title: "Silence at Altitude", duration: "02:00:00", isPlaying: false, iconName: "icon_cloud", fileName: "silence_altitude.mp3"),
        SoundElement(title: "Turbine Takeoff Close", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "turbine_takeoff.mp3"),
        SoundElement(title: "Cockpit During Flight", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "cockpit_flight.mp3"),
        SoundElement(title: "Open Window Breeze", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "window_breeze.mp3"),
        SoundElement(title: "Propeller Hum", duration: "02:00:00", isPlaying: false, iconName: "icon_storm", fileName: "propeller_hum.mp3"),
        SoundElement(title: "Stratosphere Rumble", duration: "02:00:00", isPlaying: false, iconName: "icon_cloud", fileName: "stratosphere_rumble.mp3"),
        SoundElement(title: "Wind at 200 km/h", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "wind_fast.mp3"),
        SoundElement(title: "Airflow Over Wing", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "airflow_wing.mp3"),
        SoundElement(title: "Silence in Clouds", duration: "02:00:00", isPlaying: false, iconName: "icon_cloud", fileName: "silence_clouds.mp3"),
        SoundElement(title: "ATC Radio Chatter", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "atc_chatter.mp3"),
        SoundElement(title: "Business Class Ventilation", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "ventilation_business.mp3"),
        SoundElement(title: "Desert Wind High", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "wind_desert.mp3"),
        SoundElement(title: "Helicopter Idle", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "helicopter_idle.mp3"),
        SoundElement(title: "Pressure at Altitude", duration: "02:00:00", isPlaying: false, iconName: "icon_cloud", fileName: "pressure_altitude.mp3"),
        SoundElement(title: "Rain on Fuselage", duration: "02:00:00", isPlaying: false, iconName: "icon_storm", fileName: "rain_fuselage.mp3"),
        SoundElement(title: "Landing Sequence", duration: "02:00:00", isPlaying: false, iconName: "icon_plane", fileName: "landing_sequence.mp3"),
        SoundElement(title: "Jet Stream", duration: "02:00:00", isPlaying: false, iconName: "icon_wind_outline", fileName: "jet_takeoff.mp3")
    ]
    
    @Published var selectedSoundId: UUID?
    @Published var elapsedSeconds: Int = 0
    @Published var remainingSeconds: Int = 0
    private var timerCancellable: AnyCancellable?
    private var countdownCancellable: AnyCancellable?
    
    private let favoritesKey = "UserFavorites_v1"
    
    var selectedSound: SoundElement? {
        guard let id = selectedSoundId else { return nil }
        return sounds.first { $0.id == id }
    }
    
    init() {
        loadFavorites()
        startTimer()
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.sounds.contains(where: { $0.isPlaying }) {
                    self.elapsedSeconds += 1
                }
            }
    }
    
    func selectSound(_ soundID: UUID) {
        selectedSoundId = soundID
    }
    
    func togglePlay(for soundID: UUID, minutes: Int? = nil) {
        if let index = sounds.firstIndex(where: { $0.id == soundID }) {
            let wasPlaying = sounds[index].isPlaying
            
            for i in 0..<sounds.count {
                if sounds[i].id != soundID {
                    sounds[i].isPlaying = false
                }
            }
            
            sounds[index].isPlaying = !wasPlaying
            
            if sounds[index].isPlaying {
                // Sync Player Tab
                selectedSoundId = soundID
                
                elapsedSeconds = 0
                SoundService.shared.playSound(sounds[index].fileName)
                
                let timerMins = minutes ?? sounds[index].savedTimerMinutes ?? 30
                startCountdown(for: soundID, minutes: timerMins)
            } else {
                SoundService.shared.stopSound()
                stopCountdown()
            }
        }
    }
    
    func updateTimer(for soundID: UUID, minutes: Int) {
        if let index = sounds.firstIndex(where: { $0.id == soundID }) {
            // Update the source of truth
            sounds[index].savedTimerMinutes = minutes
            
            // If this sound is currently playing, update the active countdown
            if sounds[index].isPlaying {
                // We restart the countdown with the new duration, but we don't restart playback
                startCountdown(for: soundID, minutes: minutes)
            }
            saveFavorites()
        }
    }
    
    private func startCountdown(for soundID: UUID, minutes: Int) {
        stopCountdown()
        remainingSeconds = minutes * 60
        
        countdownCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.remainingSeconds -= 1
                if self.remainingSeconds <= 0 {
                    self.togglePlay(for: soundID)
                }
            }
    }
    
    private func stopCountdown() {
        countdownCancellable?.cancel()
        countdownCancellable = nil
        remainingSeconds = 0
    }
    
    func toggleFavorite(for soundID: UUID, withTimerMinutes: Int? = nil) {
        if let index = sounds.firstIndex(where: { $0.id == soundID }) {
            sounds[index].isFavorite.toggle()
            if sounds[index].isFavorite && withTimerMinutes != nil {
                sounds[index].savedTimerMinutes = withTimerMinutes
            }
            saveFavorites()
        }
    }
    
    // MARK: - Persistence
    private func saveFavorites() {
        // Map: FileName -> TimerMinutes (Int?)
        var favoritesMap: [String: Int?] = [:]
        
        for sound in sounds where sound.isFavorite {
            favoritesMap[sound.fileName] = sound.savedTimerMinutes
        }
        
        if let data = try? JSONEncoder().encode(favoritesMap) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let favoritesMap = try? JSONDecoder().decode([String: Int?].self, from: data) else {
            return
        }
        
        for i in 0..<sounds.count {
            let fileName = sounds[i].fileName
            if let _ = favoritesMap[fileName] { // Key exists means it was favorite (even if value is nil)
                sounds[i].isFavorite = true
                // Determine if the dictionary actually contains a value for the key
                // Checking keys explicitly is safer given 'Int?' value
                if favoritesMap.keys.contains(fileName) {
                    sounds[i].savedTimerMinutes = favoritesMap[fileName] ?? nil
                }
            }
        }
    }
    
    var formattedElapsedTime: String {
        let total = remainingSeconds > 0 ? remainingSeconds : elapsedSeconds
        let hours = total / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60
        
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }
}
