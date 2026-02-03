import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            SplashGridView()
                .ignoresSafeArea()
                .opacity(0.15)
            
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320)
                    .blendMode(.screen)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SplashGridView: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 60
            let color = Color.white
            
            for x in stride(from: 0, through: size.width, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
            }
            
            for y in stride(from: 0, through: size.height, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    LoadingView()
}
