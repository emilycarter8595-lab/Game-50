import Foundation
import AVFoundation
import MediaPlayer

class SoundService {
    static let shared = SoundService()
    private var audioPlayer: AVAudioPlayer?
    private var currentFileName: String?
    
    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.audioPlayer?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.audioPlayer?.pause()
            return .success
        }
        
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.stopSound()
            return .success
        }
    }
    
    func playSound(_ filename: String) {
        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        
        if currentFileName == filename && audioPlayer != nil {
            audioPlayer?.play()
            setupNowPlaying(filename: filename)
            return
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) ?? 
                        Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Sounds") else {
            print("Sound file not found: \(filename)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop infinitely
            audioPlayer?.play()
            currentFileName = filename
            setupNowPlaying(filename: filename)
        } catch {
            print("Could not play sound file: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentFileName = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func pauseSound() {
        audioPlayer?.pause()
    }
    
    private func setupNowPlaying(filename: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = filename
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Avia Flight Sounds"
        
        if let player = audioPlayer {
             nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
             nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
