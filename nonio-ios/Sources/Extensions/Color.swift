import SwiftUI

extension UIColor {
    var color: Color {
        Color(uiColor: self)
    }
}

extension Color {
    static func dynamicColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            let color = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(color)
        })
    }
}
