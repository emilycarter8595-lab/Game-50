import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var viewModel: SoundLibraryViewModel
    let onSoundSelected: (SoundElement) -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var favoriteSounds: [SoundElement] {
        viewModel.sounds.filter { $0.isFavorite }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if favoriteSounds.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image("icon_cloud")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 48, height: 48)
                        .foregroundColor(DesignSystem.Colors.accentRed)
                    
                    VStack(spacing: 4) {
                        Text("Empty")
                            .font(DesignSystem.Fonts.poppinsBold(size: 28))
                            .foregroundColor(.white)
                        
                        Text("Save your first sound")
                            .font(DesignSystem.Fonts.poppinsRegular(size: 18))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(favoriteSounds) { sound in
                            FavoriteCardView(
                                sound: sound,
                                onCardTap: {
                                    onSoundSelected(sound)
                                },
                                onPlayToggle: {
                                    viewModel.togglePlay(for: sound.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("Favorites")
                .font(DesignSystem.Fonts.poppinsBold(size: 22))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

struct FavoriteCardView: View {
    let sound: SoundElement
    @EnvironmentObject var viewModel: SoundLibraryViewModel
    let onCardTap: () -> Void
    let onPlayToggle: () -> Void
    
    var body: some View {
        Button(action: onCardTap) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sound.title)
                        .font(DesignSystem.Fonts.poppinsSemibold(size: 17))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(sound.isPlaying ? viewModel.formattedElapsedTime : sound.duration)
                        .font(DesignSystem.Fonts.poppinsRegular(size: 14))
                        .foregroundColor(sound.isPlaying ? DesignSystem.Colors.playingStroke : DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                HStack {
                    Image(sound.iconName)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(sound.isPlaying ? DesignSystem.Colors.playingStroke : DesignSystem.Colors.tabSelected)
                    
                    Spacer()
                    
                    Button(action: onPlayToggle) {
                        Image(sound.isPlaying ? "pause" : "play")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(18)
            .frame(height: 150)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(sound.isPlaying ? DesignSystem.Colors.playingStroke : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            withAnimation {
                viewModel.toggleFavorite(for: sound.id)
            }
        }
    }
}
