import SwiftUI

class OrientationLockedController<Content: View>: UIHostingController<OrientationLockedController.Root<Content>> {
    var orientations: OrientationsHolder!

    class OrientationsHolder {
        var supportedOrientations: UIInterfaceOrientationMask

        init() {
            self.supportedOrientations = UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        orientations.supportedOrientations
    }

    init(rootView: Content) {
        let orientationsHolder = OrientationsHolder()
        let orientationRoot = Root(contentView: rootView, orientationsHolder: orientationsHolder)
        super.init(rootView: orientationRoot)
        self.orientations = orientationsHolder
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Root<Content: View>: View {
        let contentView: Content
        let orientationsHolder: OrientationsHolder

        var body: some View {
            contentView
                .onPreferenceChange(SupportedOrientationsPreferenceKey.self) {
                    orientationsHolder.supportedOrientations = $0
                }
        }
    }
}
