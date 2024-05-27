import Foundation

struct CreatePostParams: RequestParamsType {
    var content: String
    var title: String
    var type: String
    var url: String
    var link: String?
    var tags: [String]

    var toRequestParams: [String : Any] {
        var params: [String : Any] = [
            "content": content,
            "title": title,
            "type": type,
            "url": url,
            "tags": tags,
        ]
        params["link"] = link
        return params
    }
}
