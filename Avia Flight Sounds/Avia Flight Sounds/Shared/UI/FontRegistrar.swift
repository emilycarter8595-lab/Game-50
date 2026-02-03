import Foundation
import CoreText

enum FontRegistrar {
    static func registerFonts() {
        let fonts = [
            "Poppins-Bold.ttf",
            "Poppins-SemiBold.ttf",
            "Poppins-Medium.ttf",
            "Poppins-Regular.ttf"
        ]
        
        for font in fonts {
            guard let url = Bundle.main.url(forResource: font, withExtension: nil) else {
                print("Failed to find font: \(font)")
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                print("Failed to register font: \(font), error: \(String(describing: error))")
            }
        }
    }
}
