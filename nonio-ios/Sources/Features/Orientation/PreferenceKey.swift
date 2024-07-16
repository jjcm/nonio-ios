import SwiftUI

struct SupportedOrientationsPreferenceKey: PreferenceKey {
    static var defaultValue: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }

    static func reduce(value: inout UIInterfaceOrientationMask, nextValue: () -> UIInterfaceOrientationMask) {
        value.formIntersection(nextValue())
    }
}
