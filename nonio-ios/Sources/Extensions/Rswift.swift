import SwiftUI
import RswiftResources

public extension RswiftResources.ImageResource {
    var image: Image {
        Image(name, bundle: Bundle.main)
    }
}
