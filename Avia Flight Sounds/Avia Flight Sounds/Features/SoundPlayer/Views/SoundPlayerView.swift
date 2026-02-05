import SwiftUI

struct SoundPlayerView: View {
    let sound: SoundElement
    @EnvironmentObject var viewModel: SoundLibraryViewModel
    @State private var durationMinutes: Double = 30
    @State private var rotationAngle: Double = 0
    @State private var isInitializingSlider: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    turbineView
                    
                    durationPickerCard
                    
                    startButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text(sound.title)
                .font(DesignSystem.Fonts.poppinsBold(size: 22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
            
            Button(action: {
                viewModel.toggleFavorite(for: sound.id, withTimerMinutes: Int(durationMinutes))
            }) {
                Image(sound.isFavorite ? "like_on" : "like_off")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var turbineView: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.playingStroke.opacity(0.1), lineWidth: 1)
                .frame(width: 300, height: 300)
            Circle()
                .stroke(DesignSystem.Colors.playingStroke.opacity(0.05), lineWidth: 1)
                .frame(width: 350, height: 350)
            
            Image("Turbine")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(rotationAngle))
                .onChange(of: sound.isPlaying) { isPlaying in
                    if isPlaying {
                        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    } else {
                        withAnimation(.default) {
                            rotationAngle = 0
                        }
                    }
                }
                .onAppear {
                    if sound.isPlaying {
                        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                }
            
            VStack {
                Spacer()
                Button(action: {
                    Task {
                        if !sound.isPlaying {
                            viewModel.togglePlay(for: sound.id)
                            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                            if sound.isPlaying {
                                viewModel.togglePlay(for: sound.id)
                            }
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        Text("PREVIEW")
                            .font(DesignSystem.Fonts.poppinsBold(size: 16))
                            .tracking(1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(DesignSystem.Colors.cardBackground)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(DesignSystem.Colors.playingStroke.opacity(0.2), lineWidth: 1)
                    )
                }
                .foregroundColor(.white)
                .padding(.bottom, 10)
            }
            .frame(height: 350)
        }
    }
    
    private var durationPickerCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DURATION PICKER")
                .font(DesignSystem.Fonts.poppinsBold(size: 15))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .tracking(1.5)
            
            HStack {
                Text(sound.isPlaying ? viewModel.formattedElapsedTime : formattedDuration)
                    .font(DesignSystem.Fonts.poppinsMedium(size: 20))
                    .foregroundColor(sound.isPlaying ? DesignSystem.Colors.playingStroke : .white)
                Spacer()
            }
            .padding(20)
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)
            
            VStack(spacing: 12) {
                Slider(value: $durationMinutes, in: 1...120, step: 1)
                    .accentColor(DesignSystem.Colors.tabSelected)
                    .onChange(of: durationMinutes) { newValue in
                        if !isInitializingSlider {
                            viewModel.updateTimer(for: sound.id, minutes: Int(newValue))
                        }
                    }
                    .onAppear {
                        isInitializingSlider = true
                        if let saved = sound.savedTimerMinutes {
                            durationMinutes = Double(saved)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isInitializingSlider = false
                        }
                    }
                    .onChange(of: sound.id) { _ in
                        isInitializingSlider = true
                        if let saved = sound.savedTimerMinutes {
                            durationMinutes = Double(saved)
                        } else {
                            durationMinutes = 30
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isInitializingSlider = false
                        }
                    }
                
                HStack {
                    Text("0h 01m")
                        .font(DesignSystem.Fonts.poppinsRegular(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                    Text("2h 00m")
                        .font(DesignSystem.Fonts.poppinsRegular(size: 13))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Text("Selected playback length for takeoff sequence loop.")
                .font(DesignSystem.Fonts.poppinsRegular(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(DesignSystem.Colors.playingStroke.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var startButton: some View {
        Button(action: {
            viewModel.togglePlay(for: sound.id, minutes: Int(durationMinutes))
        }) {
            HStack(spacing: 12) {
                Image(sound.isPlaying ? "pause" : "start")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 28, height: 28)
                Text(sound.isPlaying ? "STOP" : "START")
                    .font(DesignSystem.Fonts.poppinsBold(size: 22))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(DesignSystem.Colors.playingStroke)
            .foregroundColor(.black)
            .cornerRadius(32)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formattedDuration: String {
        let hours = Int(durationMinutes) / 60
        let mins = Int(durationMinutes) % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}
