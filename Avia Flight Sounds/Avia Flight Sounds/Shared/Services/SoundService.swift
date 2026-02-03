import Foundation
import AVFoundation

class SoundService {
    static let shared = SoundService()
    private var audioPlayer: AVAudioPlayer?
    private var currentFileName: String?
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    func playSound(_ filename: String) {
        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        
        if currentFileName == filename && audioPlayer != nil {
            audioPlayer?.play()
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
        } catch {
            print("Could not play sound file: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentFileName = nil
    }
    
    func pauseSound() {
        audioPlayer?.pause()
    }
}
