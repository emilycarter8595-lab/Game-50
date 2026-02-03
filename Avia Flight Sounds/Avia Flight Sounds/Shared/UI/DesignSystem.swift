import SwiftUI

import SwiftUI

enum DesignSystem {
    enum Colors {
        static let background = Color(red: 0.04, green: 0.04, blue: 0.04)
        static let cardBackground = Color(red: 0.08, green: 0.11, blue: 0.09)
        static let swipeBackground = Color(red: 0.18, green: 0.22, blue: 0.20)
        static let playingStroke = Color(red: 0, green: 0.95, blue: 0.22)
        static let tabBarBackground = Color(red: 0.06, green: 0.08, blue: 0.07)
        static let tabSelected = Color(red: 1, green: 0.05, blue: 0.16)
        static let tabUnselected = Color(red: 0.60, green: 0.60, blue: 0.62)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.50)
        static let accentRed = Color(red: 1, green: 0.05, blue: 0.16)
        static let accentGreen = Color(red: 0, green: 0.95, blue: 0.22)
        static let accentOrange = Color(red: 1, green: 0.55, blue: 0)
    }
    
    enum Fonts {
        static func poppinsBold(size: CGFloat) -> Font {
            .custom("Poppins-Bold", size: size)
        }
        
        static func poppinsSemibold(size: CGFloat) -> Font {
            .custom("Poppins-SemiBold", size: size)
        }
        
        static func poppinsMedium(size: CGFloat) -> Font {
            .custom("Poppins-Medium", size: size)
        }
        
        static func poppinsRegular(size: CGFloat) -> Font {
            .custom("Poppins-Regular", size: size)
        }
    }
}
