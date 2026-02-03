import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .library
    @EnvironmentObject private var soundViewModel: SoundLibraryViewModel
    
    enum Tab {
        case library
        case player
        case favorite
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content Area
            contentSection
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Fixed Tab Bar
            tabBarSection
        }
        .background(
            Image("Loading")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.8)
        )
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
    }
    
    private var contentSection: some View {
        ZStack {
            switch selectedTab {
            case .library:
                SoundLibraryView(
                    onSoundSelected: { sound in
                        soundViewModel.selectSound(sound.id)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .player
                        }
                    }
                )
            case .player:
                if let activeSound = soundViewModel.selectedSound {
                    SoundPlayerView(sound: activeSound)
                } else {
                    noActiveSoundView
                }
            case .favorite:
                FavoritesView(
                    onSoundSelected: { sound in
                        soundViewModel.selectSound(sound.id)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .player
                        }
                    }
                )
            }
        }
    }
    
    private var tabBarSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(DesignSystem.Colors.accentRed.opacity(0.35))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                tabButton(tab: .library, title: "Library", icon: "Icon_library")
                tabButton(tab: .player, title: "Player", icon: "Icon_player")
                tabButton(tab: .favorite, title: "Favorite", icon: "Icon_favorite")
            }
            .padding(.top, 12)
            .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 12)
        }
        .background(
            DesignSystem.Colors.tabBarBackground
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func tabButton(tab: Tab, title: String, icon: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image("\(icon)_\(selectedTab == tab ? "on" : "off")")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 26, height: 26)
                
                Text(title)
                    .font(DesignSystem.Fonts.poppinsMedium(size: 11))
                    .foregroundColor(selectedTab == tab ? DesignSystem.Colors.tabSelected : DesignSystem.Colors.tabUnselected)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var noActiveSoundView: some View {
        VStack(spacing: 0) {
            headerView(title: "Player")
            
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
                    
                    Text("Select a sound from Library to play")
                        .font(DesignSystem.Fonts.poppinsRegular(size: 18))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func headerView(title: String) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(DesignSystem.Fonts.poppinsBold(size: 22))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var safeAreaInsets: EdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let insets = window.windows.first?.safeAreaInsets else {
            return EdgeInsets()
        }
        return EdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
    }
}

#Preview("iPhone 15 Pro") {
    MainTabView()
        .environmentObject(SoundLibraryViewModel())
}

#Preview("iPhone SE") {
    MainTabView()
        .environmentObject(SoundLibraryViewModel())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}
