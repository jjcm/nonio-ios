import Foundation

struct URLValidator {

    static func validate(_ value: String) -> Bool {
        let pattern = "^[a-zA-Z0-9\\-\\._]*$"
        if !value.matches(pattern) {
            return false
        } else {
            return true
        }
    }
}

private extension String {
    func matches(_ pattern: String) -> Bool {
        if let _ = self.range(of: pattern, options: .regularExpression) {
            return true
        }
        return false
    }
}
