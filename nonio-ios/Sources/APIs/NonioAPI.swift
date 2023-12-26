import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(GetPostParams)
    case getTags
    case getComments(id: String)
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
        case .getComments:
            return "comments"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags, .getComments:
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
        case .getComments(let id):
            return .requestParameters(parameters: ["post": id], encoding: URLEncoding.default)
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
        case .getPosts, .getTags, .getComments:
            return Data()
        }
    }
}
