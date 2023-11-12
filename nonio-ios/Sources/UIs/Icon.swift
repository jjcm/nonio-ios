import SwiftUI

enum IconSize {
    case small, big, medium, large
    
    var size: CGFloat {
        switch self {
        case .small: 16
        case .big: 20
        case .medium: 24
        case .large: 30
        }
    }
}

struct Icon: View {
    var image: Image
    var size: IconSize
    
    var body: some View {
        image
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width: size.size, height: size.size)
    }
}
