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
    
    var selectedSound: SoundElement? {
        guard let id = selectedSoundId else { return nil }
        return sounds.first { $0.id == id }
    }
    
    init() {
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
