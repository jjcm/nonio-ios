import Foundation
import Moya

extension MoyaError {
    var errorMessage: String {
        switch self {
        case .imageMapping(let response),
                .jsonMapping(let response),
                .stringMapping(let response),
                .objectMapping(_, let response),
                .statusCode(let response):
            return getError(from: response)
        case .underlying(_, let response):
            if let response {
                return getError(from: response)
            }
        case .requestMapping, .parameterEncoding, .encodableMapping:
            return localizedDescription
        }
        return self.localizedDescription
    }

    private func getError(from response: Moya.Response) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
               let errorString = json["error"] as? String {
                return errorString
            } else {
                return localizedDescription
            }
        } catch {
            return localizedDescription
        }
    }
}
