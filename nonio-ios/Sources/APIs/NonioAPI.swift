import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(GetPostParams)
    case getTags
    case getComments(id: String)
    case login(user: String, password: String)
    case userInfo(user: String)
}

extension NonioAPI: TargetType, AccessTokenAuthorizable {
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
        case .userInfo(let user):
            return "users/\(user)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags, .getComments, .userInfo:
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
        case .getTags, .userInfo:
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
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .userInfo:
            return .bearer
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getPosts, .getTags, .getComments, .login, .userInfo:
            return Data()
        }
    }
}
