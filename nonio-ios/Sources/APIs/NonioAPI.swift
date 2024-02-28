import Foundation
import Moya
import Combine

enum NonioAPI {
    case getPosts(RequestParamsType)
    case getTags
    case getComments(id: String)
    case login(user: String, password: String)
    case userInfo(user: String)
    
    case addVote(post: String, tag: String)
    case removeVote(post: String, tag: String)
    case getVotes

    case addCommentVote(commentID: Int, vote: Bool)
    case getCommentVotes(post: String)
    case addComment(content: String, post: String, parent: Int?)

    case getNotifications(unread: Bool?)
    case getNotificationsUnreadCount
    case markNotificationRead(id: Int)
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
        case .addCommentVote:
            return "comment/add-vote"
        case .addComment:
            return "comment/create"
        case .getNotifications:
            return "notifications"
        case .getNotificationsUnreadCount:
            return "notifications/unread-count"
        case .markNotificationRead:
            return "notification/mark-read"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPosts, .getTags, .getComments, .userInfo, .getVotes, .getCommentVotes, .getNotifications, .getNotificationsUnreadCount:
            return .get
        case .login, .addVote, .removeVote, .addCommentVote, .addComment, .markNotificationRead:
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
        case .getTags, .userInfo, .getVotes, .getNotificationsUnreadCount:
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
            return .requestParameters(parameters: ["post": post], encoding: URLEncoding.default)
        case .addCommentVote(let commentID, let vote):
            return .requestParameters(
                parameters: ["id": commentID, "upvoted": vote],
                encoding: JSONEncoding.default
            )
        case .addComment(let content, let post, let parent):
            var params: [String: Any] = [
                "content": content,
                "post": post
            ]
            params["parent"] = parent
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getNotifications(let unread):
            var params: [String: Any] = [:]
            params["unread"] = unread
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .markNotificationRead(let id):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)

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
        case .userInfo, .getVotes, .addVote, .removeVote, .getCommentVotes, .addCommentVote, .addComment, .getNotifications, .getNotificationsUnreadCount, .markNotificationRead:
            return .bearer
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
