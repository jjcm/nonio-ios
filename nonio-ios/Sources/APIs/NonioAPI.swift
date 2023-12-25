import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(GetPostParams)
    case getTags
    case getComments(id: String)
    case login(user: String, password: String)
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
        case .login:
            return "user/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags, .getComments:
            return .get
        case .login:
            return .post
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
        case .login(let user, let password):
            let params = [
                "email": user,
                "password": password
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
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
        case .getPosts, .getTags, .getComments, .login:
            return Data()
        }
    }
}
