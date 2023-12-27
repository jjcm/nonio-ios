import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(GetPostParams)
    case getTags
    case getComments(id: String)
    case login(user: String, password: String)
    case userInfo(user: String)
    case addVote(post: String, tag: String)
    case removeVote(post: String, tag: String)
    case getVotes
    case getCommentVotes(post: String)
}

extension NonioAPI: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return Configuration.API_HOST
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
        case .addVote:
            return "posttag/add-vote"
        case .removeVote:
            return "posttag/remove-vote"
        case .getVotes:
            return "votes"
        case .getCommentVotes:
            return "comment-votes"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags, .getComments, .userInfo, .getVotes, .getCommentVotes:
            return .get
        case .login, .addVote, .removeVote:
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
        case .getTags, .userInfo, .getVotes:
            return .requestPlain
        case .login(let user, let password):
            let params = [
                "email": user,
                "password": password
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .addVote(let post, let tag), .removeVote(let post, let tag):
            let params = [
                "post": post,
                "tag": tag
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getCommentVotes(let post):
            return .requestParameters(parameters: ["post": post], encoding: JSONEncoding.default)
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
        case .userInfo, .getVotes, .addVote, .removeVote, .getCommentVotes:
            return .bearer
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getPosts, .getTags, .getComments, .login, .userInfo, .addVote, .removeVote, .getVotes, .getCommentVotes:
            return Data()
        }
    }
}
