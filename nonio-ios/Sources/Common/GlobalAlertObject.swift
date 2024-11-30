import Foundation
import SwiftUI

class GlobalAlertObject: ObservableObject {
    @Published var alert: Alert? {
        didSet {
            isShowingAlert = alert != nil
        }
    }
    @Published var isShowingAlert = false
}
