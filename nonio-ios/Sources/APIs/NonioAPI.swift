import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(GetPostParams)
    case getTags
}

extension NonioAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.non.io")!
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "posts"
        case .getTags:
            return "tags"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getPosts(let params):
            return .requestParameters(
                parameters: params.toRequestParams, 
                encoding: URLEncoding.default
            )
        case .getTags:
            return .requestPlain

        }
    }
    
    var headers: [String: String]? {
        nil
    }

    var validationType: ValidationType {
        return .successCodes
    }
    
    var sampleData: Data {
        switch self {
        case .getPosts, .getTags:
            return Data()
        }
    }
}
