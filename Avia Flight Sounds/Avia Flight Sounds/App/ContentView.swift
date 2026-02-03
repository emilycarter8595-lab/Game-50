import SwiftUI

struct ContentView: View {
    @State private var isShowingLoading = true
    @StateObject private var soundViewModel = SoundLibraryViewModel()
    
    var body: some View {
        ZStack {
            if isShowingLoading {
                LoadingView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                MainTabView()
                    .environmentObject(soundViewModel)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            FontRegistrar.registerFonts()
            isShowingLoading = false
        }
    }
}

#Preview {
    ContentView()
}
