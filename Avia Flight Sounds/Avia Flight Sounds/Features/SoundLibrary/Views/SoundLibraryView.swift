import SwiftUI

struct SoundLibraryView: View {
    @EnvironmentObject var viewModel: SoundLibraryViewModel
    let onSoundSelected: (SoundElement) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(viewModel.sounds) { sound in
                        SoundCardView(
                            sound: sound,
                            onCardTap: {
                                onSoundSelected(sound)
                            },
                            onPlayToggle: {
                                viewModel.togglePlay(for: sound.id)
                            },
                            onLikeToggle: {
                                withAnimation {
                                    viewModel.toggleFavorite(for: sound.id, withTimerMinutes: 30)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("Sound Library")
                .font(DesignSystem.Fonts.poppinsBold(size: 22))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

struct SoundCardView: View {
    let sound: SoundElement
    @EnvironmentObject var viewModel: SoundLibraryViewModel
    let onCardTap: () -> Void
    let onPlayToggle: () -> Void
    let onLikeToggle: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    onLikeToggle()
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await MainActor.run {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
                }) {
                    Image(sound.isFavorite ? "like_on" : "like_off")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 32, height: 32)
                }
                .padding(.trailing, 24)
            }
            .frame(height: 72)
            .background(DesignSystem.Colors.swipeBackground)
            .cornerRadius(24)
            
            // Main Card Content
            ZStack {
                HStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(sound.iconName)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(sound.isPlaying ? DesignSystem.Colors.playingStroke : DesignSystem.Colors.tabSelected)
                            .frame(width: 26, height: 26)
                        
                        Text(sound.title)
                            .font(DesignSystem.Fonts.poppinsSemibold(size: 17))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onPlayToggle()
                    }) {
                        Image(sound.isPlaying ? "pause" : "play")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .frame(height: 72)
                .background(DesignSystem.Colors.cardBackground)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(sound.isPlaying ? DesignSystem.Colors.playingStroke : Color.clear, lineWidth: 2)
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if offset != 0 {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                } else {
                    onCardTap()
                }
            }
            .offset(x: offset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { gesture in
                        if abs(gesture.translation.width) > abs(gesture.translation.height) {
                            if gesture.translation.width < 0 {
                                offset = gesture.translation.width
                            }
                        }
                    }
                    .onEnded { gesture in
                        if abs(gesture.translation.width) > abs(gesture.translation.height) {
                            withAnimation(.spring()) {
                                if gesture.predictedEndTranslation.width < -30 || gesture.translation.width < -30 {
                                    offset = -80
                                } else {
                                    offset = 0
                                }
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
        }
    }
}
